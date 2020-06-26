//
//  TrailerViewController.m
//  Flix
//
//  Created by Brian Sanchez on 6/25/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "TrailerViewController.h"

@interface TrailerViewController ()
@property (nonatomic, strong) id key;
@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", self.urlString);
    NSURL *url = [NSURL URLWithString:self.urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               self.key = dataDictionary[@"results"][0][@"key"]; // gets movie key
               NSString *urlWebString = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", self.key];
               NSURL *urlTot = [NSURL URLWithString:urlWebString];
               NSURLRequest *requestWeb = [NSURLRequest requestWithURL:urlTot cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0]; // requests movie website
               [self.trailerView loadRequest:requestWeb]; // loads the web view
           }
       }];
    [task resume];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
