//
//  YouTubeUploader.m
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YouTubeUploader.h"

@interface YouTubeUploader ()

@property (nonatomic, strong) GDataServiceTicket *youTubeTicket;
@property (nonatomic, strong) GDataServiceGoogleYouTube *youTubeService;

@end

@implementation YouTubeUploader

@synthesize video;
@synthesize delegate;
@synthesize serviceName;

@synthesize youTubeTicket;
@synthesize youTubeService;

- (id)initWithVideo:(Video *)theVideo andDelegate:(id)theDelegate
{
    self = [super init];
    if (self) {
        self.video = theVideo;
        self.delegate = theDelegate;
        
        GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kYouTubeClientKeychainItem clientID:kYouTubeClientID clientSecret:kYouTubeClientSecret];
        
        self.youTubeService = [[GDataServiceGoogleYouTube alloc] init];
        [self.youTubeService setShouldCacheResponseData:YES];
        [self.youTubeService setServiceShouldFollowNextLinks:YES];
        [self.youTubeService setIsServiceRetryEnabled:YES];
        
        [self.youTubeService setYouTubeDeveloperKey:kYouTubeDeveloperKey];
        [self.youTubeService setAuthorizer:auth];
    }
    
    return self;
}

- (void)upload
{
    if (![self.youTubeService.authorizer canAuthorize]) {
        NSError *error = [NSError errorWithDomain:@"Forbidden" code:403 userInfo:nil];
        [self.delegate uploadDidError:self withError:error];
        return;
    }
    
    [self.youTubeService setYouTubeDeveloperKey:kYouTubeDeveloperKey];
    
    NSURL *url = [GDataServiceGoogleYouTube youTubeUploadURLForUserID:kGDataServiceDefaultUser];
    
    NSFileHandle *assetFileHandle = [NSFileHandle fileHandleForReadingFromURL:self.video.assetURL error:nil];
    NSString *filename = [[self.video.assetURL absoluteString] lastPathComponent];
    
    GDataMediaTitle *mediaTitle = [GDataMediaTitle textConstructWithString:self.video.title];
    GDataMediaDescription *mediaDescription = [GDataMediaDescription textConstructWithString:self.video.description];
    GDataMediaKeywords *mediaTags = [GDataMediaKeywords keywordsWithString:self.video.tags];
    
    GDataMediaCategory *mediaCategory = [GDataMediaCategory mediaCategoryWithString:self.video.category];
    
    GDataYouTubeMediaGroup *mediaGroup = [GDataYouTubeMediaGroup mediaGroup];
    [mediaGroup setMediaTitle:mediaTitle];
    [mediaGroup setMediaDescription:mediaDescription];
    [mediaGroup setMediaKeywords:mediaTags];
    [mediaGroup addMediaCategory:mediaCategory];
    [mediaGroup setIsPrivate:NO];
    
    NSString *mimeType = @"video/quicktime";
    
    GDataEntryYouTubeUpload *entry = [GDataEntryYouTubeUpload uploadEntryWithMediaGroup:mediaGroup fileHandle:assetFileHandle MIMEType:mimeType slug:filename];
    
    [(SwipeVideoAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    
    self.youTubeTicket = [self.youTubeService fetchEntryByInsertingEntry:entry forFeedURL:url delegate:self didFinishSelector:@selector(uploadFinished:finishedWithEntry:error:)];
}

- (void)uploadFinished:(GDataServiceTicket *)ticket finishedWithEntry:(GDataEntryYouTubeVideo *)entry error:(NSError *)error
{
    [(SwipeVideoAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
    
    if (error) {
        NSError *error = [NSError errorWithDomain:@"Unknown error." code:500 userInfo:nil];
        [self.delegate uploadDidError:self withError:error];
        return;
    }
    
    [self.delegate uploadDidFinish:self];
}

@end
