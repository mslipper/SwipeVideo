//
//  YouTubeUploader.h
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GData.h"
#import "GDataEntryYouTubeUpload.h"
#import "GTMHTTPFetcher.h"
#import "UploaderDelegate.h"
#import "Video.h"
#import "ServiceCredentials.h"

@class Video;

@interface YouTubeUploader : NSObject

@property (nonatomic, strong) Video *video;
@property (readonly, strong) NSString *serviceName;
@property (nonatomic, strong) id <UploaderDelegate> delegate;

- (id)initWithVideo:(Video *)theVideo andDelegate:(id)theDelegate;
- (void)upload;

@end
