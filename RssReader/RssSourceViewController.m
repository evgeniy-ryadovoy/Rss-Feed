//
//  RssSourceViewController.m
//  RssReader
//
//  Created by evgeniy on 04/03/2017.
//  Copyright © 2017 evgeniy. All rights reserved.
//

#import "RssSourceViewController.h"
#import "RssFeed.h"

@interface RssSourceViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation RssSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleTextField.delegate = self;
    self.urlTextField.delegate = self;
    
    if (self.rssFeed) {
        self.titleTextField.text = self.rssFeed.title;
        self.urlTextField.text = self.rssFeed.sourceURLString;
    }
    
    [self updateSaveButtonState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.saveButton.enabled = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self updateSaveButtonState];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    // Configure the destination view controller only when the save button is pressed.
    if (sender == self.saveButton) {
        NSString *title = self.titleTextField.text;
        NSString *url = self.urlTextField.text;
        
        // Set the feed to be passed to RssFeedsTableViewController after the unwind segue.
        self.rssFeed = [[RssFeed alloc] initWithTitle:title sourceURLString:url];
    }
}


- (void)updateSaveButtonState {
    // Disable the Save button if the text fields are empty.
    NSString *title = self.titleTextField.text;
    NSString *url = self.urlTextField.text;
    
    self.saveButton.enabled = (0 < title.length && 0 < url.length);
}

@end
