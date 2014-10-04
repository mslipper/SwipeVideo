//
//  VideoDetailsViewController.m
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoDetailsViewController.h"

@implementation VideoDetailsViewController

@synthesize cancelButton;
@synthesize doneButton;
@synthesize videoTitleField;
@synthesize videoDescriptionField;
@synthesize videoTagsField;
@synthesize videoCategoryField;
@synthesize title;
@synthesize description;
@synthesize tags;
@synthesize category;
@synthesize delegate;

- (IBAction)donePressed:(UIBarButtonItem *)sender
{
    self.title = self.videoTitleField.text;
    self.description = self.videoDescriptionField.text;
    self.tags = self.videoTagsField.text;
    [self.delegate videoDetailsViewControllerDidSave:self];
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [self.delegate videoDetailsViewControllerDidCancel:self];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.videoDescriptionField.placeholder = @"Describe it.";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.videoDescriptionField.placeholder = @"Describe it.";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setVideoTitleField:nil];
    [self setVideoDescriptionField:nil];
    [self setDoneButton:nil];
    [self setCancelButton:nil];
    [self setVideoTagsField:nil];
    [self setVideoCategoryField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self.videoTitleField becomeFirstResponder];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        [self.videoDescriptionField becomeFirstResponder];
    } else if (indexPath.section == 1) {
        [self.videoTagsField becomeFirstResponder];
    } else if (indexPath.section == 2) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Autos & Vehicles", @"Comedy", @"Education", @"Entertainment", @"Film & Animation", @"Gaming", @"Howto & Style", @"Music", @"News & Politics", @"Nonprofits & Activism", @"People & Blogs", @"Pets & Animals", @"Science & Technology", @"Sports", @"Travel & Events", nil];
        
        [sheet showInView:self.view];
    }
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.videoCategoryField.text = [actionSheet buttonTitleAtIndex:buttonIndex];
    self.videoCategoryField.textColor = [UIColor darkTextColor];
    
    NSDictionary *categories = [NSDictionary dictionaryWithObjectsAndKeys: @"Film", @"Film & Animation", @"Autos", @"Autos & Vehicles", @"Music", @"Music", @"Animals", @"Pets & Animals", @"Sports", @"Sports", @"Shortmov", @"Short Movies", @"Travel", @"Travel & Events", @"Games", @"Gaming", @"Videoblog", @"Videoblogging", @"People", @"People & Blogs", @"Comedy", @"Comedy", @"Entertainment", @"Entertainment", @"News", @"News & Politics", @"Howto", @"Howto & Style", @"Education", @"Education", @"Tech", @"Science & Technology", @"Nonprofit", @"Nonprofits & Activism", nil];
    
    NSString *selectedCategory = [actionSheet buttonTitleAtIndex:buttonIndex];

    self.category = [categories objectForKey:selectedCategory];
}

@end
