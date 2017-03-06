//
//  RssFeedParseOperation.m
//  RssReader
//
//  Created by evgeniy on 05/03/2017.
//  Copyright © 2017 evgeniy. All rights reserved.
//

#import "RssFeedParseOperation.h"
#import "RssEntry.h"

@interface RssFeedParseOperation () <NSXMLParserDelegate>

@property (nonatomic) RssEntry *currentRssEntry;
@property (nonatomic) NSString *currentParseElement;
@property (nonatomic) NSMutableArray *currentParseBatch;

@property (nonatomic) NSMutableString *itemTitle;
@property (nonatomic) NSMutableString *itemLink;
@property (nonatomic) NSMutableString *itemDescription;

// a stack queue containing  elements as they are being parsed, used to detect malformed XML.
@property (nonatomic, strong) NSMutableArray *elementStack;

@end

@implementation RssFeedParseOperation

+ (NSString *)AddRssFeedsNotificationName {
    return @"AddRssFeedsNotif";
}


+ (NSString *)RssFeedsResultsKey {
    return @"RssFeedResultsKey";
}


+ (NSString *)RssFeedsErrorNotificationName {
    return @"RssFeedErrorNotif";
}


+ (NSString *)RssFeedsMessageErrorKey {
    return @"RssFeedsMsgErrorKey";
}


- (instancetype)init {
    
    NSAssert(NO, @"Invalid use of init; use initWithData to create RssFeedParser");
    return [self init];
}


- (instancetype)initWithData:(NSData *)parseData {
    self = [super init];
    
    if (self != nil && parseData != nil) {
        _rssFeedData = [parseData copy];
        _currentParseBatch = [[NSMutableArray alloc] init];
        _elementStack = [[NSMutableArray alloc] init];
        
    }
    
    return self;
}


- (void)rssFeedsParsed:(NSArray *)feedEntries {
    
    assert([NSThread isMainThread]);
    
    [self.delegate parseOperationEntriesDidParse:feedEntries];
}


// The main function for this NSOperation, to start the parsing.
- (void)main {
    /*
     It's also possible to have NSXMLParser download the data, by passing it a URL, 
     but it gives less control over the network
     */
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.rssFeedData];
    parser.delegate = self;
    [parser parse];
    
    if (self.currentParseBatch.count) {
        [self performSelectorOnMainThread:@selector(rssFeedsParsed:) withObject:self.currentParseBatch waitUntilDone:YES];
    }
}


#pragma mark - Parser constants
// Reduce potential parsing errors by using string constants declared in a single place.
static NSString *kEntryElementName        = @"item";
static NSString *kDescriptionElementTitle = @"title";
static NSString *kDescriptionElementDesc  = @"description";
static NSString *kDescriptionElementLink  = @"link";


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    // add the element to the state stack
    [self.elementStack addObject:elementName];
    
    self.currentParseElement = elementName;
     
    if ([elementName isEqualToString:kEntryElementName]) {
        self.itemTitle       = [[NSMutableString alloc] init];
        self.itemLink        = [[NSMutableString alloc] init];
        self.itemDescription = [[NSMutableString alloc] init];
    }
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([self.currentParseElement isEqualToString:kDescriptionElementTitle]) {
        [self.itemTitle appendString:string];
    }
    else if ([self.currentParseElement isEqualToString:kDescriptionElementLink]) {
        [self.itemLink appendString:string];
    }
    else if ([self.currentParseElement isEqualToString:kDescriptionElementDesc]) {
        [self.itemDescription appendString:string];
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    // check if the end element matches what's last on the element stack
    if ([elementName isEqualToString:self.elementStack.lastObject]) {
        // they match, remove it
        [self.elementStack removeLastObject];
    } else {
        // they don't match, we have malformed XML
        [self.elementStack removeAllObjects];
        [parser abortParsing];
    }
    
    if ([elementName isEqualToString:kEntryElementName]) {
        RssEntry *entry = [[RssEntry alloc] initWithTitle:self.itemTitle
                                              description:self.itemDescription
                                           thumbnailImage:nil
                                                urlSource:self.itemLink];
        [self.currentParseBatch addObject:entry];
    }
}


// An error occurred while parsing the rss feed data: post the error as an NSNotification to our app delegate.
- (void)handleRssFeedsError:(NSError *)parseError {
    
    assert([NSThread isMainThread]);

    [self.delegate parseOperationErrorDidOccur:parseError];
}


// An error occurred while parsing the rss feed data, pass the error to the main thread for handling.
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    
    if (parseError.code != NSXMLParserDelegateAbortedParseError) {
        [self.currentParseBatch removeAllObjects];
        [self performSelectorOnMainThread:@selector(handleRssFeedsError:) withObject:parseError waitUntilDone:NO];
    }
}


@end
