//
//  InitialViewController.m
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoRecorderController.h"

@interface VideoRecorderController ()

@property (strong, nonatomic) NSDate *recordingStartedAt;
@property (strong, nonatomic) NSTimer *recordingTimerTimer;

@end

@implementation VideoRecorderController

@synthesize previewView;
@synthesize recordView;
@synthesize loadingView;
@synthesize recordIcon;
@synthesize cameraRollButton;
@synthesize recordingTimer;
@synthesize tapInstructions;

@synthesize manager;
@synthesize video;

@synthesize recordingStartedAt;
@synthesize recordingTimerTimer;

- (IBAction)startRecording:(UIButton *)sender
{
    [UIView animateWithDuration:.40 delay:0.0 options:UIViewAnimationCurveLinear animations:^{        
        self.recordView.layer.opacity = 0;
        self.cameraRollButton.layer.opacity = 0;
        self.recordIcon.layer.opacity = 0;
        self.recordingTimer.layer.opacity = 0.5;
        self.tapInstructions.layer.opacity = 0.5;
    } completion:^(BOOL finished){
        self.recordView.hidden = YES;
        self.cameraRollButton.hidden = YES;
    }];
    
    [self.manager startRecording];
    
    self.recordingStartedAt = [NSDate date];
    
    NSTimeInterval oneSecond = (NSTimeInterval) 1;
    self.recordingTimerTimer = [NSTimer scheduledTimerWithTimeInterval:oneSecond target:self selector:@selector(updateRecordingTimer:) userInfo:nil repeats:YES];
    [self.recordingTimerTimer fire];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopRecording)];
    [self.previewView addGestureRecognizer:tap];
}

- (void)showImagePicker:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeMovie, nil];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    [self presentModalViewController:picker animated:YES];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    [self.manager.session stopRunning];
}

- (void)stopRecording
{
    self.recordView.hidden = NO;
    self.loadingView.hidden = NO;
    [self.loadingView startAnimating];
    
    [UIView animateWithDuration:.40 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
        self.recordView.layer.opacity = 0.5;
        self.loadingView.layer.opacity = 1;
        self.tapInstructions.layer.opacity = 0;
        self.recordingTimer.layer.opacity = 0;
    } completion:nil];
    
    [self.manager stopRecording];
    [self.recordingTimerTimer invalidate];
}

- (void)updateRecordingTimer:(NSTimer *)timer
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *currentDate = [NSDate date];
    
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *conversionInfo = [calendar components:unitFlags fromDate:self.recordingStartedAt toDate:currentDate options:0];
    
    NSInteger hours   = [conversionInfo hour];
    NSInteger minutes = [conversionInfo minute];
    NSInteger seconds = [conversionInfo second];
        
    self.recordingTimer.text = [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    self.recordView.layer.cornerRadius = 5;
    self.recordView.clipsToBounds = YES;
    
    self.recordingTimer.layer.cornerRadius = 5;
    self.recordingTimer.clipsToBounds = YES;
    
    self.cameraRollButton.layer.cornerRadius = 5;
    self.cameraRollButton.clipsToBounds = YES;
    
    self.tapInstructions.layer.cornerRadius = 5;
    self.tapInstructions.clipsToBounds = YES;
    
    if (self.manager == nil) {
        self.manager = [[AVCamCaptureManager alloc] init];
        self.manager.delegate = self;
        
        if ([self.manager setupSession]) {
            self.manager.session.sessionPreset = AVCaptureSessionPresetMedium;
            AVCaptureVideoPreviewLayer *captureLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.manager.session];
            CALayer *previewViewLayer = self.previewView.layer;
            previewViewLayer.masksToBounds = YES;
            
            CGRect bounds = self.previewView.bounds;
            captureLayer.frame = bounds;
            
            if ([captureLayer isOrientationSupported]) {
                captureLayer.orientation = AVCaptureVideoOrientationPortrait;
            }
            
            captureLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            
            [previewViewLayer insertSublayer:captureLayer below:[[previewViewLayer sublayers] objectAtIndex:0]];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.manager.session startRunning];
            });
        }
    } else {
        [self.manager.session startRunning];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImagePicker:)];
    [self.cameraRollButton addGestureRecognizer:tap];

    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self.manager.session stopRunning];
    
    [self setPreviewView:nil];
    [self setRecordView:nil];
    [self setCameraRollButton:nil];
    [self setLoadingView:nil];
    [self setRecordingTimer:nil];
    [self setRecordIcon:nil];
    [self setTapInstructions:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    [self dismissViewControllerAnimated:YES completion:^ {
        [self doneRecording:videoURL];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.manager.session startRunning];
}

- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (void)captureManagerRecordingFinished:(AVCamCaptureManager *)captureManager
{
    [self doneRecording:captureManager.recorder.outputFileURL];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowVideoDetailsView"]) {
        UINavigationController *destinationController = segue.destinationViewController;
        VideoDetailsViewController *detailsViewController = (VideoDetailsViewController *)destinationController.topViewController;
        detailsViewController.delegate = self;
        
        UIImage *detailsImage = [UIImage imageNamed:@"detailsBackground"];
        UIColor *tile = [UIColor colorWithPatternImage:detailsImage];
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = tile;
        detailsViewController.tableView.backgroundView = backgroundView;
        
        UIBarButtonItem *done = detailsViewController.doneButton;
        UIImage *doneImage = [[UIImage imageNamed:@"doneBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        UIImage *doneImageDepressed = [[UIImage imageNamed:@"doneBackgroundDepressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [done setBackgroundImage:doneImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [done setBackgroundImage:doneImageDepressed forState:UIControlEventTouchUpInside barMetrics:UIBarMetricsDefault];
        
        UIBarButtonItem *cancel = detailsViewController.cancelButton;
        UIImage *cancelImage = [[UIImage imageNamed:@"cancelBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        UIImage *cancelImageDepressed = [[UIImage imageNamed:@"cancelBackgroundDepressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [cancel setBackgroundImage:cancelImage forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        [cancel setBackgroundImage:cancelImageDepressed forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    } else if ([segue.identifier isEqualToString:@"ShowSwipeVideoView"]) {
        SwipeVideoViewController *destinationController = segue.destinationViewController;
        self.video.delegate = destinationController;
        destinationController.video = self.video;
    }
}

- (void)doneRecording:(NSURL *)videoURL
{
    self.video = [[Video alloc] initWithAssetURL:videoURL];
    [self.manager.session stopRunning];
    [self performSegueWithIdentifier:@"ShowVideoDetailsView" sender:self];
}

- (void)videoDetailsViewControllerDidSave:(VideoDetailsViewController *)controller
{
    NSDateFormatter *formatter;
    NSString *todaysDate;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM d, YYYY"];
    
    todaysDate = [formatter stringFromDate:[NSDate date]];
    
    self.video.title = ![controller.title isEqualToString:@""] ? controller.title : todaysDate;
    self.video.description = ![controller.description isEqualToString:@""] ? controller.description : @"Uploaded with SwipeVideo";
    self.video.tags = ![controller.tags isEqualToString:@""] ? controller.tags : @"SwipeVideo";
    self.video.category = controller.category ?: @"Entertainment";
        
    [self dismissViewControllerAnimated:NO completion:^{
        [self performSegueWithIdentifier:@"ShowSwipeVideoView" sender:self];
    }];
}

- (void)videoDetailsViewControllerDidCancel:(id)controller
{
    [self resetView];
}

- (void)resetView
{
    self.video = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.recordView.hidden = NO;
    self.recordView.layer.opacity = 0.5;
    
    self.recordIcon.layer.opacity = 1;
    
    self.loadingView.hidden = YES;
    self.loadingView.layer.opacity = 0;
    [self.loadingView stopAnimating];
    
    self.recordingStartedAt = nil;
    self.recordingTimer.text = @"00:00:00";
    
    NSEnumerator *enumerator = [self.previewView.gestureRecognizers objectEnumerator];
    id gestureRecognizer;
    while(gestureRecognizer = [enumerator nextObject]) {
        [self.previewView removeGestureRecognizer:gestureRecognizer];
    }
    
    [self.manager.session startRunning];
}

@end
