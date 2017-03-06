//
//  RssFeedTableViewController.m
//  RssReader
//
//  Created by evgeniy on 04/03/2017.
//  Copyright © 2017 evgeniy. All rights reserved.
//

#import "RssFeedTableViewController.h"
#import "RssEntryTableViewCell.h"
#import "RssSourceViewController.h"
#import "RssEntryViewController.h"
#import "RssFeedSectionHeaderView.h"
#import "RssFeed.h"
#import "RssEntry.h"

@interface RssFeedTableViewController () <RssFeedSectionHeaderViewDelegate>

@property (nonatomic, strong) NSString *headerIdentifier;
@property (nonatomic) NSInteger selectedFeedIndex;
@property (nonatomic, strong) NSMutableArray <RssFeed *> *rssFeeds;

@end

@implementation RssFeedTableViewController

const float RssFeedTableHeaderHeight = 38.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.headerIdentifier = @"FeedHeader";
    [self.tableView registerNib:[UINib nibWithNibName:@"RssFeedSectionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:self.headerIdentifier];
    
    self.rssFeeds = [[NSMutableArray alloc] init];
    [self addTestEntries];
}


// Just simple demonstration
- (void)addTestEntries {
    RssFeed *feed1 = [[RssFeed alloc] initWithTitle:@"test title" sourceURLString:@"http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"];
    RssFeed *feed2 = [[RssFeed alloc] initWithTitle:@"test title 2" sourceURLString:@"http://images.apple.com/main/rss/hotnews/hotnews.rss"];
    RssFeed *feed3 = [[RssFeed alloc] initWithTitle:@"test title 3" sourceURLString:@"ya.ru"];
    
    self.rssFeeds = [NSMutableArray arrayWithArray:@[feed1, feed2, feed3]];
}


- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"addRssFeed"]) {
        //set index to feeds count value for adding new rss feed
        self.selectedFeedIndex = self.rssFeeds.count;
    }
    
    if ([[segue identifier] isEqualToString:@"showRssEntry"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        RssEntry *rssEntry = [self rssEntryAtIndexPath:indexPath];
        RssEntryViewController *controller = (RssEntryViewController *)[segue destinationViewController];
        controller.rssEntry = rssEntry;
    }
}


#pragma mark - Actions

- (IBAction)unwindToRssFeedList:(UIStoryboardSegue *)sender {
    RssSourceViewController *controller = (RssSourceViewController *)([sender sourceViewController]);
    RssFeed *feed = controller.rssFeed;
    
    [feed refreshFeedWithCompletionHandler:^(BOOL success, NSError *error){
       
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView beginUpdates];
            
            // reload table sections
            if (0 <= self.selectedFeedIndex && self.selectedFeedIndex < self.rssFeeds.count) {
                //set updated item
                self.rssFeeds[self.selectedFeedIndex] = feed;
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.selectedFeedIndex]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                [self.rssFeeds insertObject:feed atIndex:0];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            [self.tableView endUpdates];
            [self reloadSectionHeaders];
              
            if (!success) {
                NSString *alertTitle = NSLocalizedString(@"Error", @"Error");
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                               message:error.localizedDescription
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:action];
                
                if (self.presentedViewController == nil) {
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
            
        });
    }];
}


- (IBAction)refreshFeedList:(id)sender {
    // disable user intetraction during sections updating
    [self disableUserInteraction];
    // simple flag for errors. In fact we can keep errors for each feed and log it into debug
    __block BOOL errorOccured;
    NSInteger count = self.rssFeeds.count;
    
    // use dispatch_group to increase refresh speed
    dispatch_group_t refreshGroup = dispatch_group_create();
    
    dispatch_apply(count, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(size_t i) {
        
        RssFeed *feed = self.rssFeeds[i];
        
        dispatch_group_enter(refreshGroup);
        [feed refreshFeedWithCompletionHandler:^(BOOL success, NSError *_error) {

            self.rssFeeds[i] = feed;
            
            if (_error) {
                errorOccured = YES;
            }
            
            dispatch_group_leave(refreshGroup);
        }];
    });
    
    dispatch_group_notify(refreshGroup, dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self reloadSectionHeaders];
        [self enableUserInteraction];
        
        if (errorOccured) {
            NSString *title = NSLocalizedString(@"Error", @"Error");
            NSString *description = NSLocalizedString(@"Refresh Error", @"Error occured during updating.");
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                           message:description
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action];
            
            if (self.presentedViewController == nil) {
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    });
}


#pragma mark - RssFeedSectionHeaderViewDelegate

- (void)sectionHeaderEditFeedAtIndex:(NSUInteger)index {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RssSourceViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"RssSourceViewController"];
    controller.rssFeed = self.rssFeeds[index];
    
    //keep feed index
    self.selectedFeedIndex = index;
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)sectionHeaderDeleteFeedAtIndex:(NSUInteger)index {
    [self.rssFeeds removeObjectAtIndex:index];
    [self.tableView beginUpdates];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self reloadSectionHeaders];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.rssFeeds.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    RssFeed *feed = self.rssFeeds[section];
    return feed.rssEntries.count;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    RssFeedSectionHeaderView *sectionHeader =
                (RssFeedSectionHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:self.headerIdentifier];
    
    RssFeed *feed = self.rssFeeds[section];
    sectionHeader.feedIndex = section;
    sectionHeader.titleLabel.text = feed.title;
    sectionHeader.delegate = self;
    return sectionHeader;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return RssFeedTableHeaderHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Table view cells are reused and should be dequeued using a cell identifier.
    NSString *cellIdentifier = @"RssEntryTableViewCell";
    RssEntry *rssEntry = [self rssEntryAtIndexPath:indexPath];
    
    RssEntryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = rssEntry.title;
    cell.descriptionLabel.text = rssEntry.shortDescription;
    cell.thumbnailImageView.image = rssEntry.thumbnailImage;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - Private methods

- (void)reloadSectionHeaders {
    NSInteger count = [self numberOfSectionsInTableView:self.tableView];
    
    for (NSInteger i = 0; i < count; ++i) {
        RssFeedSectionHeaderView *header = (RssFeedSectionHeaderView *)[self.tableView headerViewForSection:i];
        [self configureHeader:header forSection:i];
    }
}


- (void)configureHeader:(RssFeedSectionHeaderView *)header forSection:(NSInteger)section {
    // configure your header
    header.feedIndex = section;
}


- (void)enableUserInteraction {
    self.view.userInteractionEnabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}


- (void)disableUserInteraction {
    self.view.userInteractionEnabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}


- (RssEntry *)rssEntryAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.rssFeeds.count <= indexPath.section) {
        return nil;
    }
    
    RssFeed *feed = self.rssFeeds[indexPath.section];
    
    if (feed.rssEntries.count <= indexPath.row) {
        return nil;
    }
    
    return feed.rssEntries[indexPath.row];
}

@end
