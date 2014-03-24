//
//  PMAppDelegate.m
//  PMPrismContainerController
//
//  Created by Peter Meyers on 2/24/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "PMAppDelegate.h"
#import "PMViewController.h"
#import "PMRotatingPrismContainer.h"

static CGFloat const TitleFontSize = 18.0f;
static CGFloat const TitleTextColor = 200.0f/255.0f;
static NSString * const TitleFontName = @"HelveticaNeue-Light";

@implementation PMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	PMViewController *panelOne = [[PMViewController alloc] initWithNibName:nil
                                                                    bundle:nil];
	panelOne.view.backgroundColor = [UIColor redColor];
	panelOne.image = [UIImage imageNamed:@"pg.jpg"];
	
	PMViewController *panelTwo = [[PMViewController alloc] initWithNibName:nil
                                                                    bundle:nil];
	panelTwo.view.backgroundColor = [UIColor blueColor];
	panelTwo.image = [UIImage imageNamed:@"cp.jpg"];
	
	PMViewController *panelThree = [[PMViewController alloc] initWithNibName:nil
                                                                      bundle:nil];
	panelThree.view.backgroundColor = [UIColor grayColor];
	panelThree.image = [UIImage imageNamed:@"lj.jpg"];
	
	PMViewController *panelFour = [[PMViewController alloc] initWithNibName:nil
                                                                     bundle:nil];
	panelFour.view.backgroundColor = [UIColor whiteColor];
	panelFour.image = [UIImage imageNamed:@"kobe.jpg"];

    NSArray *viewControllers = @[panelOne,
                                 panelTwo,
                                 panelThree,
                                 panelFour];
    
    

    NSArray *titleLabels = @[[self newTitleLabel:@"Paul"],
                             [self newTitleLabel:@"Chris"],
                             [self newTitleLabel:@"Lebron"],
                             [self newTitleLabel:@"Kobe"]];
    
    
	PMRotatingPrismContainer *rpc = [PMRotatingPrismContainer rotatingPrismContainerWithViewControllers:viewControllers];
    
    rpc.titleViews = titleLabels;
    
    [rpc rotateToViewController:panelThree animated:NO completion:nil];

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[self.window setRootViewController:rpc];
	[self.window makeKeyAndVisible];
	
    return YES;
}

- (UILabel *) newTitleLabel:(NSString *)title
{
    UILabel *label = [UILabel new];
    label.text = title;
    label.font = [UIFont fontWithName:TitleFontName size:TitleFontSize];
    label.textColor = [UIColor colorWithWhite:TitleTextColor alpha:1.0];
    [label sizeToFit];
    return label;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
