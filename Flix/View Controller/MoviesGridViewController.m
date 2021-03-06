//
//  MoviesGridViewController.m
//  Flix
//
//  Created by Brian Sanchez on 6/25/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "MoviesGridViewController.h"
#import "MovieCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) NSArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.searchBar.delegate = self;
    
    
    
    [self fetchMovies];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    CGFloat postersPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
}

- (void)fetchMovies {
    // url endpoint
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/297761/similar?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US&page=1"];
    
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

               
               self.movies = dataDictionary[@"results"];
               self.filteredMovies = self.movies;
               [self.collectionView reloadData];
               // TODO: Get the array of movies
               // TODO: Store the movies in a property to use elsewhere
               // TODO: Reload your table view data
           }
       }];
    [task resume];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // segue.identifier
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
    NSDictionary *dictionary = self.filteredMovies[indexPath.item];
    DetailsViewController *detailsViewController = segue.destinationViewController;
    detailsViewController.movie = dictionary;
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionViewCell" forIndexPath:indexPath];
    NSDictionary *movie = self.filteredMovies[indexPath.item];
    NSString *lowResURlString = @"https://image.tmdb.org/t/p/w45";
    NSString *highResURLString = @"https://image.tmdb.org/t/p/original";
    
    NSString *posterURLString = movie[@"poster_path"];
    NSString *lowPosterURL = [lowResURlString stringByAppendingString:posterURLString];
    NSString *highPosterURL = [highResURLString stringByAppendingString:posterURLString];
    NSURL *lowposterURL = [NSURL URLWithString:lowPosterURL];
    NSURL *highposterURL = [NSURL URLWithString:highPosterURL];
    NSURLRequest *requestSmall = [NSURLRequest requestWithURL:lowposterURL];
    NSURLRequest *requestLarge = [NSURLRequest requestWithURL:highposterURL];

    __weak MovieCollectionViewCell *weakSelf = cell;

    [cell.posterView setImageWithURLRequest:requestSmall
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
                                       
                    if(response) {
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
                    } else {
                        weakSelf.posterView.image = smallImage;
                    }
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       // do something for the failure condition
                                       // possibly try to get the large image
                                   }];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredMovies.count; // num of items
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[c]%@", searchText];
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
        NSLog(@"%@",self.filteredMovies);
    } else {
        self.filteredMovies = self.movies;
    }
    [self.collectionView reloadData];
    
}



@end
