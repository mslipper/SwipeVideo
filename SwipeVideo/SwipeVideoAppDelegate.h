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

@interface SwipeVideoAppDelegate : NSObject <UIApplicationDelegate, FBSessionDelegate>
{
    Facebook *facebook;
}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SwipeVideoViewController *viewController;
@property (nonatomic, retain) Facebook *facebook;

@end
