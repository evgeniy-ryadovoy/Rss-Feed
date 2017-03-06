//
//  RssEntryViewController.m
//  RssReader
//
//  Created by evgeniy on 04/03/2017.
//  Copyright © 2017 evgeniy. All rights reserved.
//

#import "RssEntryViewController.h"
#import "RssEntry.h"

@interface RssEntryViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *contentWebView;

@end

@implementation RssEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.contentWebView.delegate = self;
    
    if (self.rssEntry) {
        [self loadContent];
    }
}


- (void)loadContent {
    NSString *encodedString=[self.rssEntry.urlSource stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *requestURL = [NSURL URLWithString:encodedString];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    [self.contentWebView loadRequest:request];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.contentWebView.loading) {
        [self.contentWebView stopLoading];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - WebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self showError:error.localizedDescription];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


#pragma Mark - Private methods

- (void)showError:(NSString *)description {
    // Report the error inside the web view.
    NSString *localizedErrorMessage = NSLocalizedString(@"An error occured:", nil);
    NSString *errorFormatString = @"<!doctype html><html><body><div style=\"width: 100%%; text-align: center; font-size: 36pt;\">%@%@</div></body></html>";
    
    NSString *errorHTML = [NSString stringWithFormat:errorFormatString, localizedErrorMessage, description];
    [self.contentWebView loadHTMLString:errorHTML baseURL:nil];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)dealloc {
    self.contentWebView.delegate = nil;
}

@end
