//
//  RssFeedSectionHeaderView.m
//  RssReader
//
//  Created by evgeniy on 04/03/2017.
//  Copyright © 2017 evgeniy. All rights reserved.
//

#import "RssFeedSectionHeaderView.h"

@implementation RssFeedSectionHeaderView

- (IBAction)edit:(id)sender {

    if (self.delegate) {
        [self.delegate sectionHeaderEditFeedAtIndex:self.feedIndex];
    }
}

- (IBAction)delete:(id)sender {
    
    if (self.delegate) {
        [self.delegate sectionHeaderDeleteFeedAtIndex:self.feedIndex];
    }
}


@end
