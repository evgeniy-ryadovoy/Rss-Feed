//
//  RssFeedParseOperation.h
//  RssReader
//
//  Created by evgeniy on 05/03/2017.
//  Copyright © 2017 evgeniy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RssFeedParseOperationDelegate <NSObject>

// required methods
- (void)parseOperationEntriesDidParse:(NSArray *)parsedEntries;
- (void)parseOperationErrorDidOccur:(NSError *)error;

@end

@interface RssFeedParseOperation : NSOperation

@property (weak, nonatomic) id<RssFeedParseOperationDelegate> delegate;
@property (copy, readonly) NSData *rssFeedData;

- (instancetype)initWithData:(NSData *)parseData NS_DESIGNATED_INITIALIZER;

+ (NSString *)AddRssFeedsNotificationName;       // NSNotification name for sending feed data back to the app delegate
+ (NSString *)RssFeedsResultsKey;                 // NSNotification userInfo key for obtaining the feed data

+ (NSString *)RssFeedsErrorNotificationName;     // NSNotification name for reporting errors
+ (NSString *)RssFeedsMessageErrorKey;           // NSNotification userInfo key for obtaining the error message

@end
