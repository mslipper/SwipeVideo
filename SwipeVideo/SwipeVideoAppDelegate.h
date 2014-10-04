//
//  SwipeVideoAppDelegate.h
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 3/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

@class SwipeVideoViewController;

@interface SwipeVideoAppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate, FBRequestDelegate>


@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) Facebook *facebook;

- (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible;

@end
