//
//  VideoDelegate.h
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VideoDelegate <NSObject>

@optional

- (void)videoDidStartYouTubeUpload;
- (void)videoDidFinishYouTubeUpload:(NSError *)withError;

- (void)videoDidStartYfrogUpload:(NSURL *)yfrogLinkURL;
- (void)videoDidFinishYfrogUpload:(NSError *)withError;

@end
