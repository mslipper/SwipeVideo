//
//  SwipeVideoAppDelegate.h
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 3/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwipeVideoViewController;

@interface SwipeVideoAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet SwipeVideoViewController *viewController;

@end
