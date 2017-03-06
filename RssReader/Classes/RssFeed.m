//
//  RssFeed.m
//  RssReader
//
//  Created by evgeniy on 04/03/2017.
//  Copyright © 2017 evgeniy. All rights reserved.
//

#import "RssFeed.h"
#import "RssFeedParseOperation.h"

@interface RssFeed () <RssFeedParseOperationDelegate>

@property (nonatomic) RefreshCompletionBlock completionBlock;
@property (nonatomic, strong) NSMutableArray <RssEntry *>*rssEntries;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, strong) NSURLSessionDataTask *sessionTask;

// queue that manages our NSOperation for parsing feed data
@property (nonatomic, strong) NSOperationQueue *parseQueue;

@end

@implementation RssFeed

- (instancetype)init {
    return [self initWithTitle:@"title" sourceURLString:@"URL"];
}

- (instancetype)initWithTitle:(NSString *)aTitle sourceURLString:(NSString *)aSourceURLString {
    
    if (self = [super init]) {
        _title = aTitle;
        _sourceURLString = aSourceURLString;
        _rssEntries = [[NSMutableArray alloc] init];
        _parseQueue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}


#pragma mark - RssFeedParseOperationDelegate
- (void)parseOperationEntriesDidParse:(NSArray *)parsedEntries {
    
    if (parsedEntries) {
        self.rssEntries = [NSMutableArray arrayWithArray:parsedEntries];
    }
    
    //Refreshing complete succesfully - use completion block
    if (self.completionBlock) {
        self.completionBlock(YES, nil);
    }
}


- (void)parseOperationErrorDidOccur:(NSError *)error {
    self.error = error;
    
    // refreshing complete with error - use completion block
    if (self.completionBlock) {
        self.completionBlock(NO, self.error);
    }
}


- (void)refreshFeedWithCompletionHandler:(RefreshCompletionBlock)completionHandler {
    // keep pointer completion block and use it later
    self.completionBlock = completionHandler;
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.sourceURLString]];
    
    // create an session data task to obtain and download the app icon
    self.sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                       
       [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
           
           // back on the main thread, check for errors, if no errors start the parsing
           if (error != nil && response == nil) {
               
               if (error.code == NSURLErrorAppTransportSecurityRequiresSecureConnection) {
                   
                   // if you get error NSURLErrorAppTransportSecurityRequiresSecureConnection (-1022),
                   // then your Info.plist has not been properly configured to match the target server.
                   //
                   NSAssert(NO, @"NSURLErrorAppTransportSecurityRequiresSecureConnection");
               } else {
                   self.error = error;
                   
                   // refreshing complete - use completion block
                   if (self.completionBlock) {
                       self.completionBlock(NO, self.error);
                   }
               }
           }
           
           // here we check for any returned NSError from the server,
           // "and" we also check for any http response errors check for any response errors
           if (response != nil) {
               
               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
               
               if ((httpResponse.statusCode/100) == 2) {
                   
                   if (data) {
                       /* Update the UI and start parsing the data,
                        Spawn an NSOperation to parse the feed data so that the UI is not
                        blocked while the application parses the XML data.
                        */
                       RssFeedParseOperation *parseOperation = [[RssFeedParseOperation alloc] initWithData:data];
                       parseOperation.delegate = self;
                       [self.parseQueue addOperation:parseOperation];
                   }
               
               } else {
                   NSString *errorString =
                   NSLocalizedString(@"HTTP Error", @"Error message displayed when receiving an error from the server.");
                   NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorString};
                   
                   self.error = [NSError errorWithDomain:@"HTTP"
                                                    code:httpResponse.statusCode
                                                userInfo:userInfo];
                   
                   // refreshing complete - use completion block
                   if (self.completionBlock) {
                       self.completionBlock(NO, self.error);
                   }
               }
           }
       }];
    }];
    
    [self.sessionTask resume];
}

@end
