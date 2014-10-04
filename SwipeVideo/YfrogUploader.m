//
//  YfrogUploader.m
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YfrogUploader.h"

static NSString const *kContentType = @"video/quicktime";
static NSInteger const kChunkSize = 50000;

#pragma mark - Header

@interface YfrogUploader ()

@property (readwrite, strong) NSString *serviceName;

@property (nonatomic, strong) NSURLRequest *twitterSignedRequest;
@property (nonatomic, strong) NSURL *twitterVerifyURL;
@property (nonatomic, strong) NSString *twitterUsername;
@property (nonatomic, strong) NSURL *putURL;
@property (nonatomic) NSInteger currentChunk;
@property (nonatomic) NSInteger uploadSize;

@end

#pragma mark - Implementation

@implementation YfrogUploader

@synthesize uploadFileHandle;
@synthesize linkURL;
@synthesize delegate;
@synthesize serviceName;

@synthesize twitterSignedRequest;
@synthesize twitterVerifyURL;
@synthesize twitterUsername;
@synthesize putURL;
@synthesize currentChunk;
@synthesize uploadSize;

- (id)initWithUploadFileHandle:(NSFileHandle *)theFileHandle andDelegate:(id)theDelegate
{
    self = [super init];
    if (self) {
        self.uploadFileHandle = theFileHandle;
        self.delegate = theDelegate;
        self.serviceName = @"yfrog";
        self.currentChunk = 0;
        self.uploadSize = (NSInteger)[self.uploadFileHandle seekToEndOfFile];
    }
    
    return self;
}

- (void)upload
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    NSArray *accounts = [accountStore accountsWithAccountType:accountType];
    ACAccount *twitterAccount = [accounts objectAtIndex:0];
    
    NSURL *twitterVerifyCredentialsURL = [NSURL URLWithString:@"http://api.twitter.com/1/account/verify_credentials.json"];

    TWRequest *authRequest = [[TWRequest alloc] initWithURL:twitterVerifyCredentialsURL parameters:nil requestMethod:TWRequestMethodGET];
    [authRequest setAccount:twitterAccount];
    
    self.twitterSignedRequest = [authRequest signedURLRequest];
    
    NSURL *startUploadURL = [NSURL URLWithString:@"http://render.imageshack.us/renderapi/start"];
    NSMutableURLRequest *startUploadRequest = [NSMutableURLRequest requestWithURL:startUploadURL];
    
    NSString *authHeader = [self.twitterSignedRequest valueForHTTPHeaderField:@"Authorization"];
    NSString *serviceProvider = [[self.twitterSignedRequest URL] absoluteString];

    [startUploadRequest setValue:authHeader forHTTPHeaderField:@"X-Verify-Credentials-Authorization"];
    [startUploadRequest setValue:serviceProvider forHTTPHeaderField:@"X-Auth-Service-Provider"];
    [startUploadRequest setHTTPMethod:@"POST"];
    
    self.twitterUsername = twitterAccount.username;
    self.twitterVerifyURL = [self.twitterSignedRequest URL];
    
    NSString *twitterVerifyURLString = [self.twitterVerifyURL absoluteString];
    
    NSString *startUploadParams = [NSString stringWithFormat:@"key=%@&content_type=%@&t_username=%@&t_verify_credentials=%@", kYfrogDeveloperKey, kContentType, self.twitterUsername, twitterVerifyURLString];
    NSData *startUploadRequestBody = [startUploadParams dataUsingEncoding:NSUTF8StringEncoding];
    
    [startUploadRequest setHTTPBody:startUploadRequestBody];
    
    [GTMHTTPFetcher setLoggingEnabled:YES];
    
    [(SwipeVideoAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];  
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:startUploadRequest];
    [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(startedUpload:finishedWithData:error:)];
}

- (void)startedUpload:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    if (error) {
        [(SwipeVideoAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"%@", error);
        return;
    }
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    
    if (doc == nil) {
        return;
    }
    
    NSArray *linkArray = [doc nodesForXPath:@"/uploadInfo/@link" error:nil];
    GDataXMLNode *linkXML = [linkArray objectAtIndex:0];
    self.linkURL = [NSURL URLWithString:linkXML.stringValue];
    
    NSArray *putURLArray = [doc nodesForXPath:@"/uploadInfo/@putURL" error:nil];
    GDataXMLNode *putURLXML = [putURLArray objectAtIndex:0];
    self.putURL = [NSURL URLWithString:putURLXML.stringValue];
    
    [self.delegate uploadDidStart:self];
    
    [self uploadChunk];
}

- (void)uploadChunk
{
    NSString *twitterVerifyURLString = [self.twitterVerifyURL absoluteString];
    
    NSString *chunkUploadParams = [NSString stringWithFormat:@"%@?key=%@&content_type=%@&t_username=%@&t_verify_credentials=%@", self.putURL, kYfrogDeveloperKey, kContentType, self.twitterUsername, twitterVerifyURLString];
    NSURL *chunkUploadURL = [NSURL URLWithString:chunkUploadParams];
    
    NSInteger lowBound;
    NSInteger highBound;
    
    if (self.uploadSize < kChunkSize) {
        lowBound = 0;
        highBound = self.uploadSize;
    } else if (((self.currentChunk * kChunkSize) +kChunkSize) > self.uploadSize) {
        lowBound = self.currentChunk * kChunkSize;
        highBound = self.uploadSize;
    } else {
        lowBound = currentChunk * kChunkSize;
        highBound = lowBound + kChunkSize;
    }
    
    NSMutableURLRequest *chunkUploadRequest = [NSMutableURLRequest requestWithURL:chunkUploadURL];
    [chunkUploadRequest setHTTPMethod:@"PUT"];
    
    NSString *uploadSizeString = [NSString stringWithFormat:@"%d", self.uploadSize];
    NSString *uploadRangeString = [NSString stringWithFormat:@"bytes %d-%d/%d", lowBound, highBound, self.uploadSize];
    
    [chunkUploadRequest addValue:uploadSizeString forHTTPHeaderField:@"Content-Length"];
    [chunkUploadRequest addValue:uploadRangeString forHTTPHeaderField:@"Content-Range"];
    
    [self.uploadFileHandle seekToFileOffset:lowBound];
    NSData *uploadBody = [self.uploadFileHandle readDataOfLength:kChunkSize];
    
    [chunkUploadRequest setHTTPBody:uploadBody];
    
    GTMHTTPFetcher *chunkUploadFetcher = [GTMHTTPFetcher fetcherWithRequest:chunkUploadRequest];
    [chunkUploadFetcher beginFetchWithDelegate:self didFinishSelector:@selector(canUploadNextChunk:finishedWithData:error:)];
}

- (void)canUploadNextChunk:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    if (fetcher.statusCode == 202) {
        self.currentChunk++;
        [self uploadChunk];
        NSLog(@"uploading next chunk");
    } else {
        [(SwipeVideoAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];  
        NSLog(@"done! status: %d", fetcher.statusCode);
    }
}

@end
