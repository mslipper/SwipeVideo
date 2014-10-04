//
//  SwipeVideoViewController.h
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 3/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "GData.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "ServiceCredentials.h"
#import "SwipeVideoAppDelegate.h"
#import "VideoDetailsViewController.h"
#import "VideoDelegate.h"
#import "Video.h"

@interface SwipeVideoViewController : UIViewController <UIActionSheetDelegate, VideoDetailsViewControllerDelegate, VideoDelegate>

- (IBAction)cornerPressed:(UIButton *)sender;

@property (nonatomic, strong) IBOutlet UIImageView *videoThumbnail;
@property (nonatomic, strong) IBOutlet UIImageView *trashButton;

@property (nonatomic, strong) Video *video;

@end
