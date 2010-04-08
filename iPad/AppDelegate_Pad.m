//
//  AppDelegate_Pad.m
//  whitenoise
//
//  Created by Jorge Bernal on 4/7/10.
//  Copyright Jorge Bernal 2010. All rights reserved.
//

#import "AppDelegate_Pad.h"

@implementation AppDelegate_Pad

@synthesize window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch
	
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
