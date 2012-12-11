//
//  RootViewController.h
//  UrlShortener
//
//  Created by Jochen Herrmann on 11.12.12.
//
//

#import <UIKit/UIKit.h>
#import "UrlShortener.h"

@interface RootViewController : UIViewController <UrlShortenerDelegate>

@property (nonatomic, strong) IBOutlet UITextField *shortURLTextField;
@property (nonatomic, strong) IBOutlet UILabel *resultLabel;
@property (nonatomic, strong) IBOutlet UISegmentedControl *serviceSegmentedControl;

- (IBAction)shortURLButtonTouched:(id)sender;
- (IBAction)shortURLWithBlocksButtonTouched:(id)sender;
@end
