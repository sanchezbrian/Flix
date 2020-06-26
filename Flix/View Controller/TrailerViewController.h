//
//  TrailerViewController.h
//  Flix
//
//  Created by Brian Sanchez on 6/25/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrailerViewController : UIViewController
@property (weak, nonatomic) IBOutlet WKWebView *trailerView;
@property (nonatomic, strong) NSString *urlString;


@end

NS_ASSUME_NONNULL_END
