//
//  VideoDetailsViewController.h
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceholderTextView.h"
#import "VideoDetailsViewControllerDelegate.h"

@class VideoDetailsViewController;

@interface VideoDetailsViewController : UITableViewController <UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) IBOutlet UITextField *videoTitleField;
@property (nonatomic, weak) IBOutlet UIPlaceHolderTextView *videoDescriptionField;
@property (weak, nonatomic) IBOutlet UITextField *videoTagsField;
@property (weak, nonatomic) IBOutlet UILabel *videoCategoryField;

@property (nonatomic, strong) id <VideoDetailsViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) NSString *category;

- (IBAction)donePressed:(UIBarButtonItem *)sender;
- (IBAction)cancelPressed:(UIBarButtonItem *)sender;

@end
