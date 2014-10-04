//
//  Video.m
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "Video.h"

@interface Video ()

@property (nonatomic, strong) GDataServiceTicket *youTubeTicket;
@property (nonatomic) CGImageRef _thumbnail;

@end

@implementation Video

@synthesize title;
@synthesize description;
@synthesize tags;
@synthesize category;
@synthesize assetURL;
@synthesize youTubeService;
@synthesize delegate;
@synthesize youTubeTicket;
@synthesize _thumbnail;

- (id)initWithAssetURL:(NSURL *)theURL
{
    self = [super init];
    if (self) {
        self.title = nil;
        self.description = nil;
        self.tags = nil;
        self.category = nil;
        self.assetURL = theURL;
        [self setUpYouTube];
    }
    
    return self;
}

- (void)setUpYouTube
{
    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kYouTubeClientKeychainItem clientID:kYouTubeClientID clientSecret:kYouTubeClientSecret];
        
    self.youTubeService = [[GDataServiceGoogleYouTube alloc] init];
    [self.youTubeService setShouldCacheResponseData:YES];
    [self.youTubeService setServiceShouldFollowNextLinks:YES];
    [self.youTubeService setIsServiceRetryEnabled:YES];
    
    [self.youTubeService setYouTubeDeveloperKey:kYouTubeDeveloperKey];
    [self.youTubeService setAuthorizer:auth];
}

- (CGImageRef)thumbnail
{
    if (_thumbnail) {
        return self._thumbnail;
    }
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.assetURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    
    Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
    CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    
    CGImageRef thumbnailImage = [generator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
    
    if (thumbnailImage != NULL) {
        self._thumbnail = thumbnailImage;
        return self._thumbnail;
    } else {
        return NULL;
    }
}

#pragma mark - Facebook methods

- (void)uploadToFacebook
{
    UIApplication *application = [UIApplication sharedApplication];
    
    NSData *videoData = [NSData dataWithContentsOfURL:self.assetURL];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:videoData, @"video.mov", @"video/quicktime", @"contentType", self.title, @"title", self.description, @"description", nil];
    
    SwipeVideoAppDelegate *facebookDelegate = (SwipeVideoAppDelegate *)[application delegate];
    [facebookDelegate.facebook requestWithGraphPath:@"me/videos" andParams:params andHttpMethod:@"POST" andDelegate:facebookDelegate];
}

#pragma mark - YouTube methods

- (void)uploadToYouTube
{    
    YouTubeUploader *uploader = [[YouTubeUploader alloc] initWithVideo:self andDelegate:self];
    [uploader upload];
}

#pragma mark - yfrog methods

- (void)uploadToYfrog
{
    NSFileHandle *assetFileHandle = [NSFileHandle fileHandleForReadingFromURL:self.assetURL error:nil];
    YfrogUploader *uploader = [[YfrogUploader alloc] initWithUploadFileHandle:assetFileHandle andDelegate:self];
    [uploader upload];
}

#pragma mark - UploaderDelegate methods

- (void)uploadDidStart:(id)uploader
{
    if ([uploader isKindOfClass:[YfrogUploader class]]) {
        YfrogUploader *classedUploader = (YfrogUploader *)uploader;
        [self.delegate videoDidStartYfrogUpload:classedUploader.linkURL];
    } else if ([uploader isKindOfClass:[YouTubeUploader class]]) {
        [self.delegate videoDidStartYouTubeUpload];
    }
}

- (void)uploadDidError:(id)uploader withError:(NSError *)error
{
    [self.delegate videoDidFinishYouTubeUpload:error];
}

- (void)uploadDidFinish:(id)uploader
{
    [self.delegate videoDidFinishYouTubeUpload:nil];
}

@end
