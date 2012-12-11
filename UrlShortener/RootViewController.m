//
//  RootViewController.m
//  UrlShortener
//
//  Created by Jochen Herrmann on 11.12.12.
//
//

#import "RootViewController.h"

@interface RootViewController ()

- (UrlShortenerService)getServiceFromSegementedControl;

@end

@implementation RootViewController

@synthesize shortURLTextField;
@synthesize resultLabel;
@synthesize serviceSegmentedControl;

- (IBAction)shortURLButtonTouched:(id)sender {
    UrlShortener *shortener = [[UrlShortener alloc] init];
    [shortener shortenUrl:shortURLTextField.text withService:[self getServiceFromSegementedControl] completion:^(NSString *shortUrl) {
        [resultLabel setText:shortUrl];
    } error:^(NSError *error) {
        // Handle the error.
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
}

- (IBAction)shortURLWithBlocksButtonTouched:(id)sender {
    UrlShortener *shortener = [[UrlShortener alloc] initWithDelegate:self];
    [shortener shortenUrl:shortURLTextField.text withService:[self getServiceFromSegementedControl]];
}

- (UrlShortenerService)getServiceFromSegementedControl {
    if (serviceSegmentedControl.selectedSegmentIndex == 0) {
        return UrlShortenerServiceBitly;
    }
    if (serviceSegmentedControl.selectedSegmentIndex == 1) {
        return UrlShortenerServiceGoogle;
    }
    if (serviceSegmentedControl.selectedSegmentIndex == 2) {
        return UrlShortenerServiceRedirect;
    }
    return UrlShortenerServiceIsgd;
}

- (void)urlShortenerSucceededWithShortUrl:(NSString *)shortUrl {
    [resultLabel setText:shortUrl];
    
}
- (void)urlShortenerFailedWithError:(NSError *)error {
    // Handle the error.
    NSLog(@"Error: %@", [error localizedDescription]);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
