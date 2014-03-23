//
//  PMAppDelegate.m
//  PMPrismContainerController
//
//  Created by Peter Meyers on 2/24/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "PMAppDelegate.h"
#import "PMPanel.h"
#import "PMRotatingPrismContainer.h"

@implementation PMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	UINib *panelNib = [UINib nibWithNibName:@"PMPanel" bundle:nil];
	
	PMPanel *panelOne = [panelNib instantiateWithOwner:nil options:nil][0];
	panelOne.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	panelOne.backgroundColor = [UIColor redColor];
	panelOne.label.text = @"One, One, One, One";
	panelOne.image.image = [UIImage imageNamed:@"pg.jpg"];
	
	PMPanel *panelTwo = [panelNib instantiateWithOwner:nil options:nil][0];
	panelTwo.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	panelTwo.backgroundColor = [UIColor blueColor];
	panelTwo.label.text = @"Two, Two, Two, Two";
	panelTwo.image.image = [UIImage imageNamed:@"cp.jpg"];
	
	PMPanel *panelThree = [panelNib instantiateWithOwner:nil options:nil][0];
	panelThree.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	panelThree.backgroundColor = [UIColor grayColor];
	panelThree.label.text = @"Three, Three, Three, Three";
	panelThree.image.image = [UIImage imageNamed:@"lj.jpg"];
	
	PMPanel *panelFour = [panelNib instantiateWithOwner:nil options:nil][0];
	panelFour.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	panelFour.backgroundColor = [UIColor whiteColor];
	panelFour.label.text = @"Four, Four, Four, Four";
	panelFour.image.image = [UIImage imageNamed:@"kobe.jpg"];

	NSDictionary *panels = [NSDictionary dictionaryWithObjects:@[panelOne,panelTwo, panelThree, panelFour]
												  forKeys:@[@"Paul", @"Chris", @"Lebron", @"Kobe"]];
	PMRotatingPrismContainer *rpc = [PMRotatingPrismContainer rotatingPrismContainerWithPanels:panels];
    [rpc rotateToPanel:panelFour animated:NO completion:nil];

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[self.window setRootViewController:rpc];
	[self.window makeKeyAndVisible];
	
    return YES;
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
