//
//  RssFeed.h
//  RssReader
//
//  Created by evgeniy on 04/03/2017.
//  Copyright © 2017 evgeniy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RssEntry.h"

typedef void(^RefreshCompletionBlock)(BOOL success, NSError *error);

@interface RssFeed : NSObject

@property (readonly) NSMutableArray <RssEntry *>*rssEntries;
@property (readonly) NSError *error;

@property (copy) NSString *title;
@property (copy) NSString *sourceURLString;

- (instancetype)initWithTitle:(NSString *)aTitle sourceURLString:(NSString *)aSourceURLString;
- (void)refreshFeedWithCompletionHandler:(RefreshCompletionBlock)completionHandler;

@end
