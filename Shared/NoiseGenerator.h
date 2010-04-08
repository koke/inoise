//
//  NoiseGenerator.h
//  whitenoise
//
//  Created by Jorge Bernal on 4/7/10.
//  Copyright 2010 Jorge Bernal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define BUFFERS 3

// Callback info struct -- holds the queue and the buffers and some other stuff for the callback
typedef struct AQCallbackStruct {
	AudioQueueRef					queue;
	UInt32							frameCount;
	AudioQueueBufferRef				mBuffers[BUFFERS];
	AudioStreamBasicDescription		mDataFormat;
} AQCallbackStruct;

typedef enum {
	NoiseGeneratorTypeSineWave = 0,
	NoiseGeneratorTypeWhiteNoise,
} NoiseGeneratorType;

@interface NoiseGenerator : NSObject {
	bool isPlaying;
	float frequency;
	IBOutlet UISlider *freqSlider;
	IBOutlet UILabel *freqLabel;
	IBOutlet UIButton *btnStart;
	IBOutlet UIButton *btnStop;
	IBOutlet UISegmentedControl *noiseSelector;
	NSThread *bgThread;
	AQCallbackStruct in;
}
- (IBAction)start;
- (IBAction)stop;
- (IBAction)sliderUpdated;
- (IBAction)selectorChange;
- (void)setupGenerator;
@end
