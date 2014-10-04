//
//  SwipeVideoViewController.m
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 3/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SwipeVideoViewController.h"

#define STRING(obj) ([NSString stringWithFormat:@"%d", obj])

#define NORTH 1
#define EAST  2
#define WEST  3

@interface SwipeVideoViewController ()

@property (nonatomic, strong) NSArray *services;
@property (nonatomic) NSInteger selectedCorner;

@end

@implementation SwipeVideoViewController

@synthesize videoThumbnail;
@synthesize trashButton;
@synthesize video;
@synthesize services;
@synthesize selectedCorner;

#pragma mark - Actions

- (IBAction)cornerPressed:(UIButton *)sender { 
    self.selectedCorner = sender.tag;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    UIActionSheet *sheet;
    
    if ([defaults objectForKey:STRING(selectedCorner)]) {
        NSString *logout = [NSString stringWithFormat:@"Log me out of %@", [defaults objectForKey:STRING(selectedCorner)]];

        sheet = [[UIActionSheet alloc] initWithTitle:@"What would you like to do?" delegate:self cancelButtonTitle:@"Close this window" destructiveButtonTitle:logout otherButtonTitles:@"Clear this tab", nil];    
    } else {
        sheet = [[UIActionSheet alloc] initWithTitle:@"Choose a service:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"YouTube", @"yfrog", nil];
    }
    
    [sheet showInView:self.view];
}

#pragma mark - ActionSheet methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];

    if ([title isEqualToString:@"Cancel"] || [title isEqualToString:@"Close this window"]) {
        return;
    } else if ([title isEqualToString:@"Clear this tab"]) {
        [self clearCurrentTab];
    } else if ([services containsObject:title]) {
        [self userSelectedServicePickerActionSheetItem:buttonIndex withService:title];
    } else {
        [self userSelectedServiceLogoutActionSheet];
    }
}

- (void)userSelectedServicePickerActionSheetItem:(NSInteger)index withService:(NSString *)service
{
    UIButton *button = (UIButton *)[self.view viewWithTag:self.selectedCorner];
    UIImage *image = [self cropTabs:index];
    
    [button setImage:image forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setAlpha:1.0];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:service forKey:STRING(selectedCorner)];
    
    for (NSInteger i=1; i<=3; i++) {
        if (i != self.selectedCorner) {
            if ([[defaults objectForKey:STRING(i)] isEqualToString:service]) {
                [defaults removeObjectForKey:STRING(i)];
                
                UIButton *otherButton = (UIButton *)[self.view viewWithTag:i];
                [otherButton setImage:nil forState:UIControlStateNormal];
                [otherButton setBackgroundColor:[UIColor blackColor]];
                [otherButton setAlpha:0.3];
            }
        }
    }
    
    [defaults synchronize];
    
    if ([service isEqualToString:@"Facebook"]) {
        [self handleFacebookLogin];
    } else if ([service isEqualToString:@"YouTube"]) {
        [self handleYouTubeLogin];
    } else if ([service isEqualToString:@"yfrog"]) {
        [self handleYfrogLogin];
    }
}

- (void)userSelectedServiceLogoutActionSheet
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *service = [defaults objectForKey:STRING(selectedCorner)];
    
    if ([service isEqualToString:@"Facebook"]) {
        [self handleFacebookLogout];
    } else if ([service isEqualToString:@"YouTube"]) {
        [self clearCurrentTab];
    }
}

#pragma mark - Segue/delegate methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowYouTubeAuthentication"]) {
        NSString *scope = [GDataServiceGoogleYouTube authorizationScope];
        GTMOAuth2ViewControllerTouch *authView = [GTMOAuth2ViewControllerTouch controllerWithScope:scope clientID:kYouTubeClientID clientSecret:kYouTubeClientSecret keychainItemName:kYouTubeClientKeychainItem completionHandler:^(GTMOAuth2ViewControllerTouch *controller, GTMOAuth2Authentication *auth, NSError *error){
            if (error == nil) {
                [self.video.youTubeService setAuthorizer:auth];
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                NSLog(@"error: %@", error);
            }
        }];
        
        UINavigationController *navigation = segue.destinationViewController;
        
        UIImage *cancelImage = [[UIImage imageNamed:@"cancelBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:nil];
        [cancelButton setBackgroundImage:cancelImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [cancelButton setTitle:@"Cancel"];
        [authView.navigationItem setLeftBarButtonItem:cancelButton];
        
        [authView setTitle:@"YouTube Login"];
        
        [navigation pushViewController:authView animated:NO];
    }
}

- (void)videoDetailsViewControllerDidCancel:(VideoDetailsViewController *)controller
{
    self.video = nil;
    [self clearVideoThumbnailAndRedisplayVideoRecorder];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)videoDetailsViewControllerDidSave:(VideoDetailsViewController *)controller
{
    self.video.title = controller.title;
    self.video.description = controller.description;
    self.video.tags = controller.tags;
    self.video.category = controller.category;
    [self dismissViewControllerAnimated:YES completion:^{
        [self showPoles];
    }];
}

#pragma mark - Swipe methods

- (void)attachSwipeGestures
{
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    
    
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    
    [self.videoThumbnail addGestureRecognizer:swipeUp];
    [self.videoThumbnail addGestureRecognizer:swipeDown];
    [self.videoThumbnail addGestureRecognizer:swipeLeft];
    [self.videoThumbnail addGestureRecognizer:swipeRight];
}

- (void)swipeUp:(UISwipeGestureRecognizer *)recognizer
{
    UIBezierPath *northPath = [UIBezierPath bezierPath];
    [northPath moveToPoint:CGPointMake(160, 240)];
    [northPath addQuadCurveToPoint:CGPointMake(160, 0) controlPoint:CGPointMake(120, 0)];
    
    [self animateSwipe:northPath];
    [self handleSwipe:NORTH];
}

- (void)swipeDown:(UISwipeGestureRecognizer *)recognizer
{
    UIBezierPath *southPath = [UIBezierPath bezierPath];
    [southPath moveToPoint:CGPointMake(160, 240)];
    [southPath addQuadCurveToPoint:CGPointMake(160, 480) controlPoint:CGPointMake(120, 360)];
    
    [self animateSwipe:southPath withCompletionHandler:^{
        [self clearVideoThumbnailAndRedisplayVideoRecorder];
    }];    
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer
{
    UIBezierPath *westPath = [UIBezierPath bezierPath];
    [westPath moveToPoint:CGPointMake(160, 240)];
    [westPath addQuadCurveToPoint:CGPointMake(0, 240) controlPoint:CGPointMake(80, 180)];
    
    [self animateSwipe:westPath];
    [self handleSwipe:WEST];
}

- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer
{
    UIBezierPath *eastPath = [UIBezierPath bezierPath];
    [eastPath moveToPoint:CGPointMake(160, 240)];
    [eastPath addQuadCurveToPoint:CGPointMake(320, 240) controlPoint:CGPointMake(240, 180)];
    
    [self animateSwipe:eastPath];
    [self handleSwipe:EAST];
}

- (void)handleSwipe:(NSInteger)location
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *service = [defaults objectForKey:STRING(location)];
    
    if ([service isEqualToString:@"Facebook"]) {
        NSLog(@"facebook");
        [self.video uploadToFacebook];
    } else if ([service isEqualToString:@"YouTube"]) {
        [self.video uploadToYouTube];
    } else if ([service isEqualToString:@"yfrog"]) {
        [self.video uploadToYfrog];
    } else if (service == nil) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose a service:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"YouTube", @"yfrog", nil];
        [sheet showInView:self.view];
        self.selectedCorner = location;
    }
}

- (void)animateSwipe:(UIBezierPath *)path
{
    [self animateSwipe:path withCompletionHandler:nil];
}

- (void)animateSwipe:(UIBezierPath *)path withCompletionHandler:(void (^)(void))completionHandler
{
    UIImage *image = [UIImage imageWithCGImage:self.video.thumbnail];
    
    CGRect buttonRect = CGRectMake(96, 167, 125, 125);
    UIImageView *view = [[UIImageView alloc] initWithImage:image];
    
    view.layer.frame = buttonRect;
    view.layer.cornerRadius = 5;
    view.clipsToBounds = YES;
    
    [self.view addSubview:view];
    [self.view bringSubviewToFront:view];
    
    [UIView animateWithDuration:.40 delay:0.0 options:UIViewAnimationCurveLinear animations:^{        
        view.transform = CGAffineTransformMakeScale(.1, .1);
        
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        anim.path = path.CGPath;
        anim.repeatCount = 0;
        anim.duration = .45;
        anim.removedOnCompletion = YES;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [view.layer addAnimation:anim forKey:@"swipeWest"];
    } completion:^(BOOL finished){
        [view removeFromSuperview];
        if (completionHandler) {
            completionHandler();
        }
    }];
}

#pragma mark - Transitions

- (void)showPoles
{
    UIButton *northButton = (UIButton *)[self.view viewWithTag:NORTH];
    UIButton *eastButton = (UIButton *)[self.view viewWithTag:EAST];
    UIButton *westButton = (UIButton *)[self.view viewWithTag:WEST];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [UIView animateWithDuration:.30 delay:0.5 options:UIViewAnimationCurveLinear animations:^{
        northButton.alpha = ([defaults objectForKey:STRING(NORTH)]) ? 1 : 0.3;
        eastButton.alpha = ([defaults objectForKey:STRING(EAST)]) ? 1 : 0.3;
        westButton.alpha = ([defaults objectForKey:STRING(WEST)]) ? 1 : 0.3;
        trashButton.alpha = 1;
    } completion:nil];
}

- (void)hidePoles
{
    UIButton *northButton = (UIButton *)[self.view viewWithTag:NORTH];
    UIButton *eastButton = (UIButton *)[self.view viewWithTag:EAST];
    UIButton *westButton = (UIButton *)[self.view viewWithTag:WEST];
    
    [UIView animateWithDuration:.30 delay:0.5 options:UIViewAnimationCurveLinear animations:^{
        northButton.alpha = 0;
        eastButton.alpha = 0;
        westButton.alpha = 0;
        trashButton.alpha = 0;
    } completion:nil];
}

#pragma mark - Facebook methods

- (void)handleFacebookLogin
{
    SwipeVideoAppDelegate *delegate = (SwipeVideoAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (![delegate.facebook isSessionValid]) {
        NSArray *permissions = [NSArray arrayWithObjects:@"publish_stream", nil];
        [delegate.facebook authorize:permissions];
    }
}

- (void)handleFacebookLogout
{
    [self clearCurrentTab];

    SwipeVideoAppDelegate *delegate = (SwipeVideoAppDelegate *)[[UIApplication sharedApplication] delegate];

    [delegate.facebook logout];
}

- (void)fbDidNotLogin:(NSNotification *)notification
{
    for (NSInteger i=1; i<=3; i++) {
        NSString *serviceAtCorner = [[NSUserDefaults standardUserDefaults] objectForKey:STRING(i)];
        if ([serviceAtCorner isEqualToString:@"Facebook"]) {
            self.selectedCorner = i;
            [self clearCurrentTab];
        }
    }
}

#pragma mark - YouTube methods

- (void)handleYouTubeLogin
{
    GTMOAuth2Authentication *auth = [self.video.youTubeService authorizer];
    if (!auth.canAuthorize) {
        [self performSegueWithIdentifier:@"ShowYouTubeAuthentication" sender:self];
    }
}

- (void)videoDidStartYouTubeUpload
{
}

- (void)videoDidFinishYouTubeUpload:(NSError *)withError
{    
    if (withError) {
        NSLog(@"error: %@", withError);
        if ([withError code] == 403) {
            [self handleYouTubeLogin];
        }
    }
}

#pragma mark - yfrog methods

- (void)handleYfrogLogin
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if (!granted) {
            [self clearCurrentTab];
        }
    }];
}

- (void)videoDidStartYfrogUpload:(NSURL *)yfrogLinkURL
{    
    TWTweetComposeViewController *tweetView = [[TWTweetComposeViewController alloc] init];
    
    [tweetView addURL:yfrogLinkURL];
    
    [tweetView setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self presentViewController:tweetView animated:YES completion:nil];
}

#pragma mark - Helper Methods

- (UIImage *)cropTabs:(NSInteger)index
{
    UIImage *image;
    UIImageOrientation orientation = UIImageOrientationUp;
    
    if (self.selectedCorner == NORTH) {
        image = [UIImage imageNamed:@"north.png"];
    } else {
        image = [UIImage imageNamed:@"south.png"];
    }
    
    if (self.selectedCorner == EAST) {
        orientation = UIImageOrientationLeft;
    } else if (self.selectedCorner == WEST) {
        orientation = UIImageOrientationRight;
    }
    
    CGFloat scale = ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0) ? 2.0 : 1.0;
    
    int width  = 300;
    int height = 70;
        
    CGRect rect = CGRectMake(0, height * index, width, height);
    
    CGImageRef ref = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:ref scale:scale orientation:orientation];
    
    CGImageRelease(ref);
    
    return croppedImage;
}

- (void)clearCurrentTab
{
    UIButton *button = (UIButton *)[self.view viewWithTag:self.selectedCorner];
    [button setImage:nil forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor darkTextColor]];
    [button setAlpha:0.3];
        
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:STRING(selectedCorner)];
    [defaults synchronize];
}

- (void)clearVideoThumbnailAndRedisplayVideoRecorder
{
    videoThumbnail.image = nil;
    
    for (UIGestureRecognizer *gesture in [videoThumbnail gestureRecognizers]) {
        if ([gesture isKindOfClass:[UISwipeGestureRecognizer class]]) {
            [videoThumbnail removeGestureRecognizer:gesture];
        }
    }
    
    [self performSegueWithIdentifier:@"ShowVideoRecorderView" sender:self];
}

#pragma mark - Initialization

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    self.videoThumbnail.layer.cornerRadius = 5;
    self.videoThumbnail.clipsToBounds = YES;
    
    UIImage *thumbnailImage = [UIImage imageWithCGImage:self.video.thumbnail];
    self.videoThumbnail.image = thumbnailImage;

    self.services = [NSArray arrayWithObjects:@"Facebook", @"YouTube", @"yfrog", nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    for (NSInteger i=1; i<=3; i++) {
        self.selectedCorner = i;
        if ([defaults objectForKey:STRING(selectedCorner)]) {
            UIButton *button = (UIButton *)[self.view viewWithTag:i];
            NSInteger serviceIndex = [self.services indexOfObject:[defaults objectForKey:STRING(selectedCorner)]];
            
            UIImage *image = [self cropTabs:serviceIndex];
            
            [button setImage:image forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor clearColor]];
        }
    }
    
    [self attachSwipeGestures];
    [self showPoles];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidNotLogin:) name:@"fbDidNotLogin" object:nil];    
}

- (void)viewDidUnload
{
    [self setServices:nil];
    [self setVideoThumbnail:nil];
    [self setTrashButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
