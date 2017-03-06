//
//  RssEntry.m
//  RssReader
//
//  Created by evgeniy on 04/03/2017.
//  Copyright © 2017 evgeniy. All rights reserved.
//

#import "RssEntry.h"

@interface RssEntry ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *fullDescription;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) NSString *urlSource;

@end

@implementation RssEntry

static int const RssEntryShortDescriptionLength = 50;

- (instancetype)initWithTitle:(NSString*)aTitle
                  description:(NSString*)aDescription
               thumbnailImage:(UIImage *)aThumbnailImage
                    urlSource:(NSString *)aUrlSource {
    
    if (self = [super init]) {
        _title           = (aTitle) ? : NSLocalizedString(@"Entry title", @"Item has no title");
        _fullDescription = (aDescription) ? : NSLocalizedString(@"Entry description", @"Item has no description");
        _thumbnailImage  = (aThumbnailImage) ? : [UIImage imageNamed:@"defaultItemImage"];
        _urlSource       = (aUrlSource) ? : NSLocalizedString(@"Entry url", @"Item has no url");
    }
    
    return self;
}


- (NSString *)shortDescription {
    
    if (self.fullDescription) {
        // if full description too short, return it, else return substr
        return (self.fullDescription.length <= RssEntryShortDescriptionLength) ?
        self.fullDescription : [self.fullDescription substringWithRange:NSMakeRange(0, RssEntryShortDescriptionLength)];
    
    }
    
    return nil;
}

@end
