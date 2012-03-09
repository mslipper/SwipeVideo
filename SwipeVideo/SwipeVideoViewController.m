//
//  SwipeVideoViewController.m
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 3/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SwipeVideoViewController.h"

@interface SwipeVideoViewController ()

@property (nonatomic, retain) NSMutableArray *targets;

@end

@implementation SwipeVideoViewController

@synthesize carousel;
@synthesize targets;
@synthesize picker;

- (void)insertTargets
{
    NSArray *images = [NSArray arrayWithObjects:[UIImage imageNamed:@"tap.png"], [UIImage imageNamed:@"youtube.png"], [UIImage imageNamed:@"facebook.png"], [UIImage imageNamed:@"vimeo.png"], nil];
    
    self.targets = [NSMutableArray array];
    for (int i = 0; i < images.count; i++)
    {
        [targets addObject:[[[UIImageView alloc] initWithImage:[images objectAtIndex:i]] autorelease]];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        [self insertTargets];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self insertTargets];
    }
    return self;
}

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
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    self.view.backgroundColor = background;
    [background release];
    
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
    
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;

    }
    else
    {
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    carousel.type = iCarouselTypeLinear;
    carousel.backgroundColor = [UIColor clearColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.carousel = nil;
    self.picker = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    carousel.delegate = nil;
    carousel.dataSource = nil;
    
    [carousel release];
    [picker release];
    [super dealloc];
}

#pragma mark - iCarousel methods

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    if(index == self.carousel.currentItemIndex)
    {
        switch (index) {
            case 0:
                [self presentModalViewController:self.picker animated:YES];
                break;
            case 2:
                [self handleFacebookButton];
                break;
            default:
                break;
        }
    }
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [targets count];
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    return 10;
}

-(UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    return [targets objectAtIndex:index];
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    return 170;
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    return NO;
}

#pragma mark - Alery methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];

}

#pragma mark - Facebook methods

- (void)handleFacebookButton
{
    SwipeVideoAppDelegate *delegate = (SwipeVideoAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Facebook *facebook = delegate.facebook;
    
    if ([facebook isSessionValid])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You are already logged in to Facebook. Would you like to log out?" delegate:self cancelButtonTitle:@"Close this" otherButtonTitles:@"Log me out", nil];
        [alert show];
    } 
    else
    {
        NSArray *permissions = [NSArray arrayWithObjects:@"publish_stream", nil];
        [facebook authorize:permissions];
        [permissions release];
    }
}

@end
