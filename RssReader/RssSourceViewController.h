//
//  RssSourceViewController.h
//  RssReader
//
//  Created by evgeniy on 04/03/2017.
//  Copyright © 2017 evgeniy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RssFeed;

@interface RssSourceViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;

@property (nonatomic) RssFeed *rssFeed;

@end
