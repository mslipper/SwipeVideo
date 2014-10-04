//
//  YfrogUploader.h
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "GData.h"
#import "GTMHTTPFetcher.h"
#import "GDataXMLNode.h"
#import "UploaderDelegate.h"
#import "SwipeVideoAppDelegate.h"
#import "ServiceCredentials.h"

@interface YfrogUploader : NSObject

@property (nonatomic, strong) NSFileHandle *uploadFileHandle;
@property (nonatomic, strong) NSURL *linkURL;
@property (nonatomic, strong) id <UploaderDelegate> delegate;
@property (readonly, strong) NSString *serviceName;

- (id)initWithUploadFileHandle:(NSFileHandle *)theFileHandle andDelegate:(id)theDelegate;
- (void)upload;

@end