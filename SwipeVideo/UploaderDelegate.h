//
//  UploaderDelegate.h
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UploaderDelegate <NSObject>

@optional

- (void)uploadDidStart:(id)uploader;
- (void)uploadDidError:(id)uploader withError:(NSError *)error;
- (void)uploadDidFinish:(id)uploader;

@end
