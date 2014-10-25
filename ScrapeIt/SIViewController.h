//
//  SIViewController.h
//  ScrapeIt
//
//  Created by Demo on 23/10/14.
//  Copyright (c) 2014 demo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SIViewController : UIViewController<UITextViewDelegate,NSURLConnectionDataDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (weak, nonatomic) IBOutlet UITextView *urlTextview;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *siteImageView;

@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;
- (IBAction)downloadPressed:(id)sender;
@end
