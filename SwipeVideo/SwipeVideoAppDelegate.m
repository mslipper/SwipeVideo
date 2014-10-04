//
//  SwipeVideoAppDelegate.m
//  SwipeVideo
//
//  Created by MATTHEW SLIPPER on 3/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SwipeVideoAppDelegate.h"
#import "SwipeVideoViewController.h"

@implementation SwipeVideoAppDelegate

@synthesize window = _window;
@synthesize facebook;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    self.facebook = [[Facebook alloc] initWithAppId:@"312347132157768" andDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"])
    {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    UIImage *backgroundImage = [UIImage imageNamed:@"navbarBackground"];
    [[UINavigationBar appearance] setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - Facebook methods

- (void)request:(FBRequest *)request didLoad:(id)result {    
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	NSLog(@"Result of API call: %@", result);
    [self setNetworkActivityIndicatorVisible:NO];
}

- (void)requestLoading:(FBRequest *)request
{
    [self setNetworkActivityIndicatorVisible:YES];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
    NSLog(@"Err details: %@", [error description]);
    [self setNetworkActivityIndicatorVisible:NO];
};

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [facebook handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [facebook handleOpenURL:url];
}

- (void)fbDidLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

- (void)fbDidLogout
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"FBAccessTokenKey"])
    {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    if (cancelled) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"fbDidNotLogin" object:nil];
    }
}

- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

- (void)fbSessionInvalidated
{
    [self fbDidLogout];
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible {
    static NSInteger numberOfCallsToSetVisible = 0;
    if (setVisible) 
        numberOfCallsToSetVisible++;
    else 
        numberOfCallsToSetVisible--;
    
    // The assertion helps to find programmer errors in activity indicator management.
    // Since a negative NumberOfCallsToSetVisible is not a fatal error, 
    // it should probably be removed from production code.
    NSAssert(numberOfCallsToSetVisible >= 0, @"Network Activity Indicator was asked to hide more often than shown");
    
    // Display the indicator as long as our static counter is > 0.
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(numberOfCallsToSetVisible > 0)];
}

@end
