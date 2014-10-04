//
//  InitialViewController.h
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "AVCamCaptureManager.h"
#import "AVCamRecorder.h"
#import "VideoDetailsViewControllerDelegate.h"
#import "SwipeVideoViewController.h"

@interface VideoRecorderController : UIViewController <AVCamCaptureManagerDelegate, UIImagePickerControllerDelegate, VideoDetailsViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) IBOutlet UIButton *recordView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (strong, nonatomic) IBOutlet UIImageView *recordIcon;
@property (strong, nonatomic) IBOutlet UIView *cameraRollButton;
@property (strong, nonatomic) IBOutlet UILabel *recordingTimer;
@property (strong, nonatomic) IBOutlet UILabel *tapInstructions;

@property (strong, nonatomic) AVCamCaptureManager *manager;
@property (strong, nonatomic) Video *video;

- (IBAction)startRecording:(UIButton *)sender;

@end