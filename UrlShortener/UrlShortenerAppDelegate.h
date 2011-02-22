//
//  UrlShortenerAppDelegate.h
//  UrlShortener
//
//  Created by Jochen Herrmann on 21.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UrlShortener.h"

@interface UrlShortenerAppDelegate : NSObject <UIApplicationDelegate, UrlShortenerDelegate> {
    UrlShortener *_shortener;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
