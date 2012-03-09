//
//  SwipeVideoViewController.h
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 3/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeVideoAppDelegate.h"
#import "iCarousel.h"
#import "Facebook.h"

@interface SwipeVideoViewController : UIViewController <UIImagePickerControllerDelegate, UIAlertViewDelegate, iCarouselDataSource, iCarouselDelegate>
{
    UIImagePickerController *picker;}

@property (nonatomic, retain) UIImagePickerController *picker;
@property (nonatomic, retain) IBOutlet iCarousel *carousel;

@end
