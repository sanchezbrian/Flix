//
//  MoviesViewController.m
//  Flix
//
//  Created by Brian Sanchez on 6/24/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"


@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *movies;

@property (weak, nonatomic) IBOutlet UITableView *tableView; // outlet for tableView

@property (nonatomic, strong) UIRefreshControl *refreshContol;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MoviesViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Movies";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    
    [self.activityIndicator startAnimating]; // activity indicator
    [self fetchMovies]; // caling the request
    self.refreshContol = [[UIRefreshControl alloc] init];
    [self.refreshContol addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshContol atIndex:0];
}

- (void)fetchMovies {
    // url endpoint
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Movies" message:@"The internet connection appears to be offline" preferredStyle:(UIAlertControllerStyleAlert)];
               
               UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try again"
                 style:UIAlertActionStyleDefault
               handler:^(UIAlertAction * _Nonnull action) {
                   [self fetchMovies];
               }];
               
               [alert addAction:okAction];
               
               [self presentViewController:alert animated:YES completion:^{
               }];
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               
               NSLog(@"%@", dataDictionary);
               
               self.movies = dataDictionary[@"results"];
               
               for (NSDictionary *movie in self.movies) {
                   NSLog(@"%@", movie[@"title"]);
               }
               [self.tableView reloadData];
               // TODO: Get the array of movies
               // TODO: Store the movies in a property to use elsewhere
               // TODO: Reload your table view data
           }
        [self.refreshContol endRefreshing];
        [self.activityIndicator stopAnimating];
       }];
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    // puts back to reuse
    
    NSDictionary *movie = self.movies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.infoLabel.text = movie[@"overview"];
    
    if ([movie[@"poster_path"] isKindOfClass:[NSString class]]) {
         NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
         NSString *posterURLString = movie[@"poster_path"];
         NSString *fullPosterURL = [baseURLString stringByAppendingString:posterURLString];
         NSURL *posterURL = [NSURL URLWithString:fullPosterURL];
         NSURLRequest *request = [NSURLRequest requestWithURL:posterURL];
         __weak MovieCell *weakSelf = cell;
         [cell.posterView setImageWithURLRequest:request placeholderImage:nil
                                         success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
                                             
                                             // imageResponse will be nil if the image is cached
                                             if (imageResponse) {
                                                 NSLog(@"Image was NOT cached, fade in image");
                                                 weakSelf.posterView.alpha = 0.0;
                                                 weakSelf.posterView.image = image;
                                                 
                                                 //Animate UIImageView back to alpha 1 over 0.3sec
                                                 [UIView animateWithDuration:.3 animations:^{
                                                     weakSelf.posterView.alpha = 1.0;
                                                 }];
                                             }
                                             else {
                                                 NSLog(@"Image was cached so just update the image");
                                                 weakSelf.posterView.image = image;
                                             }
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
                                             // do something for the failure condition
                                         }];
     }
     else {
         cell.posterView.image = nil;
    }
    // cell.textLabel.text = movie[@"title"];
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
}


@end
