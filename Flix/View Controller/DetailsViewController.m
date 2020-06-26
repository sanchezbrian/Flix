//
//  DetailsViewController.m
//  Flix
//
//  Created by Brian Sanchez on 6/24/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TrailerViewController.h"


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
    self.title = self.movie[@"title"];
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *lowResURlString = @"https://image.tmdb.org/t/p/w45";
    NSString *highResURLString = @"https://image.tmdb.org/t/p/original";
    
    NSString *posterURLString = self.movie[@"poster_path"];
    NSString *lowPosterURL = [lowResURlString stringByAppendingString:posterURLString];
    NSString *highPosterURL = [highResURLString stringByAppendingString:posterURLString];
    NSURL *lowposterURL = [NSURL URLWithString:lowPosterURL];
    NSURL *highposterURL = [NSURL URLWithString:highPosterURL];
    NSURLRequest *requestSmall = [NSURLRequest requestWithURL:lowposterURL];
    NSURLRequest *requestLarge = [NSURLRequest requestWithURL:highposterURL];

    __weak DetailsViewController *weakSelf = self;

    [self.posterView setImageWithURLRequest:requestSmall
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
                                       
                                       // smallImageResponse will be nil if the smallImage is already available
                                       // in cache (might want to do something smarter in that case).
                                       weakSelf.posterView.alpha = 0.0;
                                       weakSelf.posterView.image = smallImage;
                                       
                                       [UIView animateWithDuration:0.3
                                                        animations:^{
                                                            
                                                            weakSelf.posterView.alpha = 1.0;
                                                            
                                                        } completion:^(BOOL finished) {
                                                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                                                            // per ImageView. This code must be in the completion block.
                                                            [weakSelf.posterView setImageWithURLRequest:requestLarge
                                                                                  placeholderImage:smallImage
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                                                                                                weakSelf.posterView.image = largeImage;
                                                                                  }
                                                                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                               // do something for the failure condition of the large image request
                                                                                               // possibly setting the ImageView's image to a default image
                                                                                           }];
                                                        }];
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       // do something for the failure condition
                                       // possibly try to get the large image
                                   }];
    if ([self.movie[@"backdrop_path"] isKindOfClass:[NSString class]]) {
        NSString *backdropURLString = self.movie[@"backdrop_path"];
        NSString *fullBackdropURL = [baseURLString stringByAppendingString:backdropURLString];
        NSURL *BackDropURL = [NSURL URLWithString:fullBackdropURL];
        [self.backdropView setImageWithURL:BackDropURL];
    } else {
        self.backdropView.image = nil;
    }
    self.titleLabe.text = self.movie[@"title"];
    self.dateLabel.text = self.movie[@"release_date"];
    self.infoLabel.text = self.movie[@"overview"];
    
    [self.titleLabe sizeToFit];
    [self.infoLabel sizeToFit];
    
    [self.posterView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.posterView.layer setBorderWidth: 2.0];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    TrailerViewController *trailerViewController = [segue destinationViewController];
    trailerViewController.urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US", self.movie[@"id"]];
    
    
}




@end
