//
//  SIViewController.m
//  ScrapeIt
//
//  Created by Demo on 23/10/14.
//  Copyright (c) 2014 demo. All rights reserved.
//

#import "SIViewController.h"
#import "TFHpple.h"

#define URL_PLACEHODERTEXT             @"Add card link..."
#define TITLE_PLACEHODERTEXT           @"Add Title..."
#define DESCRIPTION_PLACEHODERTEXT     @"Add Description..."

@interface SIViewController ()
{
    NSMutableData *responseData;
    BOOL isExpanded;

}

@end

@implementation SIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundImage.png"]];
    isExpanded=NO;
    [self disableDownload];

    
    
	// Do any additional setup after loading the view, typically from a nib.
}


-(void)viewDidLayoutSubviews
{
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundImage.png"]];
    
    CGRect frame=self.mainContainerView.frame;
    frame.size.height=0;
    self.mainContainerView.frame=frame;
    
    frame=self.buttonContainerView.frame;
    frame.origin.y=CGRectGetMaxY(self.mainContainerView.frame);
    self.buttonContainerView.frame=frame;
    

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)downloadPressed:(id)sender {
    
    NSURL *aURL=[NSURL URLWithString:self.urlTextview.text];
    NSURLRequest *aRequest=[NSURLRequest requestWithURL:aURL];
    NSURLConnection *aConnection=[NSURLConnection connectionWithRequest:aRequest delegate:self];
    [self disableDownload];
    [self.activityIndicator startAnimating];

}

-(BOOL)isValidURLString:(NSString *)urlString
{
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF Matches[c] %@", urlRegEx];
    return [urlTest evaluateWithObject:urlString];
    
}
-(void)enableDownload
{
    if (!self.downloadButton.isEnabled) {
        
    [self.downloadButton setBackgroundImage:[UIImage imageNamed:@"downloadEnabled"] forState:UIControlStateNormal];
    [self.downloadButton setEnabled:YES];
    }
    
}


-(void)disableDownload
{
    if (self.downloadButton.isEnabled) {
    [self.downloadButton setBackgroundImage:[UIImage imageNamed:@"downloadDisabled"] forState:UIControlStateNormal];
    [self.downloadButton setEnabled:NO];
    }
}


-(void)finishedDownloadingContent
{
    [self.activityIndicator stopAnimating];
     __block CGRect frame=self.mainContainerView.frame;
     frame.size.height=305;
     [UIView animateWithDuration:0.3f
                         animations:^{
                            self.mainContainerView.frame = frame;
                             frame=self.buttonContainerView.frame;
                             frame.origin.y=CGRectGetMaxY(self.mainContainerView.frame);
                             self.buttonContainerView.frame=frame;
    
                         }
                         completion:^(BOOL finished){
                             NSLog( @"Expaned main container view" );
                             isExpanded=YES;
                         }];
    [self disableDownload];
    [self.view endEditing:YES];


}


-(void)hideMainContainerView
{
    __block CGRect frame=self.mainContainerView.frame;
    frame.size.height=0;
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.mainContainerView.frame = frame;
                         frame=self.buttonContainerView.frame;
                         frame.origin.y=CGRectGetMaxY(self.mainContainerView.frame);
                         self.buttonContainerView.frame=frame;
                         
                     }
                     completion:^(BOOL finished){
                         NSLog( @"Finished Hiding main Container View" );
                         isExpanded=NO;
                     }];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
#pragma mark -- UITextViewDelegate Methods

-(void)textViewDidChange:(UITextView *)textView
{
    
    if (textView.tag==0) {
        
        if (isExpanded) {
            [self hideMainContainerView];
        }

        if ([self isValidURLString:textView.text]) {
            [self enableDownload];
        }
        else
        {
            [self disableDownload];
        }
    }
  
}




- (void)textViewDidBeginEditing:(UITextView *)textView
{
    switch (textView.tag) {
        case 0:
            if ([textView.text isEqualToString:URL_PLACEHODERTEXT]) {
                textView.text = @"";
            }
            break;
        case 1:
            if ([textView.text isEqualToString:TITLE_PLACEHODERTEXT]) {
                textView.text = @"";

            }
        case 2:
            if ([textView.text isEqualToString:DESCRIPTION_PLACEHODERTEXT]) {
                textView.text=@"";
            }
        default:
            break;
    }
    
    textView.textColor = [UIColor blackColor];
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    switch (textView.tag) {
        case 0:
            if ([textView.text isEqualToString:@""]) {
                textView.text = URL_PLACEHODERTEXT;
            }
            break;
        case 1:
            if ([textView.text isEqualToString:@""]) {
                textView.text =TITLE_PLACEHODERTEXT;
                
            }
        case 2:
            if ([textView.text isEqualToString:@""]) {
                textView.text=DESCRIPTION_PLACEHODERTEXT;
            }
        default:
            break;
    }
    
    textView.textColor=[UIColor grayColor];
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark -- NSURLConnectionData Delegate Methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    responseData=nil;
    responseData=[[NSMutableData alloc] init];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseString=[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    TFHpple *htmlParser = [TFHpple hppleWithHTMLData:responseData];
    
    NSString *titleXpathQueryString = @"//head/meta[@property='og:title']";
    NSArray *titleNodes;
    titleNodes=[htmlParser searchWithXPathQuery:titleXpathQueryString];
    
    if ([titleNodes count]==0)
    {
        titleXpathQueryString = @"//html/head/title";
        titleNodes = [htmlParser searchWithXPathQuery:titleXpathQueryString];
        if ([titleNodes count] > 0) {
            self.titleTextView.text=[[[titleNodes objectAtIndex:0] firstChild] content];
        }
    }
    else
    {
        self.titleTextView.text=[[titleNodes objectAtIndex:0] objectForKey:@"content"];
    }
    NSString *descriptionXpathQueryString = @"//head/meta[@property='og:description']";
    NSArray *descriptionNodes;
    titleNodes=[htmlParser searchWithXPathQuery:descriptionXpathQueryString];
    
    if ([titleNodes count]==0)
    {
        descriptionXpathQueryString = @"//html/head/meta[@name='description']";
        descriptionNodes = [htmlParser searchWithXPathQuery:descriptionXpathQueryString];
    }
    
    if ([descriptionNodes count] > 0) {
        self.descriptionTextView.text=[[descriptionNodes objectAtIndex:0] objectForKey:@"content"];
    }
    
    NSString *imageXpathQueryString = @"//head/meta[@property='og:image']";
    NSArray *imageNodes;
    imageNodes=[htmlParser searchWithXPathQuery:imageXpathQueryString];
    

    if ([imageNodes count] > 0)
    {
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData *imageData=[NSData dataWithContentsOfURL:[NSURL URLWithString:[[imageNodes objectAtIndex:0] objectForKey:@"content"]]];
        if ( imageData == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            // WARNING: is the cell still using the same data by this point??
            UIImage * toImage = [UIImage imageWithData:imageData];
            
            [UIView transitionWithView:self.siteImageView
                              duration:1.0f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                self.siteImageView.image  = toImage;
                            } completion:nil];
        });
        
    });
    }
    
    [self finishedDownloadingContent];
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    UIAlertView *failureAlert=[[UIAlertView alloc] initWithTitle:@"Errore Downloading Data" message:@"There was an error in downloading data.Please make sure that the URL is correct" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [failureAlert show];
    [self enableDownload];
    [self.activityIndicator stopAnimating];
}


@end
