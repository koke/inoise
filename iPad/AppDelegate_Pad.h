//
//  AppDelegate_Pad.h
//  whitenoise
//
//  Created by Jorge Bernal on 4/7/10.
//  Copyright Jorge Bernal 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoiseGenerator.h"

@interface AppDelegate_Pad : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	IBOutlet NoiseGenerator *generator;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

