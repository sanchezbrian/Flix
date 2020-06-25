//
//  DetailsViewController.m
//  Flix
//
//  Created by Brian Sanchez on 6/24/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"


@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabe;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation DetailsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    
    NSString *posterURLString = self.movie[@"poster_path"];
    NSString *fullPosterURL = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURL];
    
    [self.posterView setImageWithURL:posterURL];
    NSString *backdropURLString = self.movie[@"backdrop_path"];
    NSString *fullBackdropURL = [baseURLString stringByAppendingString:backdropURLString];
    NSURL *BackDropURL = [NSURL URLWithString:fullBackdropURL];
    [self.backdropView setImageWithURL:BackDropURL];
    self.titleLabe.text = self.movie[@"title"];
    self.dateLabel.text = self.movie[@"release_date"];
    self.infoLabel.text = self.movie[@"overview"];
    
    [self.titleLabe sizeToFit];
    [self.infoLabel sizeToFit];
    
    [self.posterView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.posterView.layer setBorderWidth: 2.0];
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
