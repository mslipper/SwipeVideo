//
//  Video.h
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "GData.h"
#import "GDataEntryYouTubeUpload.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GDataXMLNode.h"
#import "GTMHTTPFetcher.h"
#import "ServiceCredentials.h"
#import "YfrogUploader.h"
#import "YouTubeUploader.h"
#import "VideoDelegate.h"
#import "UploaderDelegate.h"
#import "SwipeVideoAppDelegate.h"

@interface Video : NSObject <UploaderDelegate>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSURL *assetURL;

@property (nonatomic, strong) GDataServiceGoogleYouTube *youTubeService;

@property (nonatomic, weak) id <VideoDelegate> delegate;

- (id)initWithAssetURL:(NSURL *)theURL;

- (CGImageRef)thumbnail;

- (void)uploadToFacebook;

- (void)uploadToYouTube;

- (void)uploadToYfrog;

@end
