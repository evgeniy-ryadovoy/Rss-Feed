//
//  RssFeedSectionHeaderView.h
//  RssReader
//
//  Created by evgeniy on 04/03/2017.
//  Copyright © 2017 evgeniy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RssFeedSectionHeaderViewDelegate <NSObject>

- (void)sectionHeaderEditFeedAtIndex:(NSUInteger)index;
- (void)sectionHeaderDeleteFeedAtIndex:(NSUInteger)index;

@end

@interface RssFeedSectionHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) id <RssFeedSectionHeaderViewDelegate> delegate;
@property (nonatomic) NSUInteger feedIndex;

@end
