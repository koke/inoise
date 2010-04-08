//
//  NoiseGenerator.m
//  soundtest
//
//  Created by Jorge Bernal on 4/8/10.
//  Copyright 2010 Jorge Bernal. All rights reserved.
//

#import "NoiseGenerator.h"

// synth params
int phaseL;
int phaseR;
float amp;
float FL;
float FR;


// Synthesis callback. Make your music here.
static void AQBufferCallback(void *	in,	AudioQueueRef inQ, AudioQueueBufferRef	outQB) {
	int i;
	UInt32 err;
	
	// Get the info struct and a pointer to our output data
	AQCallbackStruct * inData = (AQCallbackStruct *)in;
	short *coreAudioBuffer = (short*) outQB->mAudioData;
	
	// if we're being asked to render
	if (inData->frameCount > 0) {
		// Need to set this
		outQB->mAudioDataByteSize = 4*inData->frameCount; // two shorts per frame, one frame per packet
		// For each frame/packet (the same in our example)
		for(i=0;i<inData->frameCount*2;i=i+2) {
			// Render the sine waves - signed interleaved shorts (-32767 -> 32767), 16 bit stereo
			float sampleL = (amp * sin(FL * (float)phaseL));
			float sampleR = (amp * sin(FR * (float)phaseR));
			short sampleIL = (int)(sampleL * 32767.0);
			short sampleIR = (int)(sampleR * 32767.0);
			coreAudioBuffer[i] =   sampleIL;
			coreAudioBuffer[i+1] = sampleIR;
			phaseL++; phaseR++;
		}
		// "Enqueue" the buffer
		AudioQueueEnqueueBuffer(inQ, outQB, 0, NULL);
	} else {
		err = AudioQueueStop(inData->queue, false);
	}
}


@implementation NoiseGenerator

- (id) init {
	if (self = [super init]) {
		[NSThread detachNewThreadSelector:@selector(setupGenerator) toTarget:self withObject:nil];
	}
	
	return self;
}

- (float)waveFor:(float)freq {
	return (2.0 * 3.14159 * freq) / 44100.0;
}

- (void)setupGenerator {
	bgThread = [NSThread currentThread];
	[bgThread setName:@"noisegen"];
	NSLog(@"setupGenerator on thread: %@", bgThread);
	double sampleRate = 44100.0;
	int i;
	
	// synth params
	phaseL = 0;
	phaseR = 0;
	amp = 0.5;
	FL = [self waveFor:440.0];
	FR = [self waveFor:440.0];
	
	// Set up our audio format -- signed interleaved shorts (-32767 -> 32767), 16 bit stereo
	// The iphone does not want to play back float32s.
	in.mDataFormat.mSampleRate = sampleRate;
	in.mDataFormat.mFormatID = kAudioFormatLinearPCM;
	in.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger  | kAudioFormatFlagIsPacked;
	in.mDataFormat.mBytesPerPacket = 4;
	in.mDataFormat.mFramesPerPacket = 1; // this means each packet in the AQ has two samples, one for each channel -> 4 bytes/frame/packet
	in.mDataFormat.mBytesPerFrame = 4;
	in.mDataFormat.mChannelsPerFrame = 2;
	in.mDataFormat.mBitsPerChannel = 16;
	
	// Set up the output buffer callback on the current run loop
	AudioQueueNewOutput(&in.mDataFormat, AQBufferCallback, &in, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &in.queue);
	
	// Set the size and packet count of each buffer read. (e.g. "frameCount")
	in.frameCount = 1024;
	// Byte size is 4*frames (see above)
	UInt32 bufferBytes  = in.frameCount * in.mDataFormat.mBytesPerFrame;
	
	// alloc 3 buffers.
	for (i=0; i<BUFFERS; i++) {
		AudioQueueAllocateBuffer(in.queue, bufferBytes, &in.mBuffers[i]);
		// "Prime" by calling the callback once per buffer
		AQBufferCallback (&in, in.queue, in.mBuffers[i]);
	}	
	
	// set the volume of the queue -- note that the volume knobs on the ipod / celestial also change this
	AudioQueueSetParameter(in.queue, kAudioQueueParam_Volume, 1.0);
	
	// Start the queue
	[self start];
	isPlaying = YES;
	
	// Hang around forever...
	while(1) CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.25, false);
	
	// This is how you kill it.. not that we ever got here.
	AudioQueueDispose(in.queue, true);	
}

- (IBAction)start {
	if (isPlaying) {
		return;
	}
	isPlaying = YES;
	AudioQueueStart(in.queue, NULL);
	btnStop.enabled = YES;
	btnStart.enabled = NO;
}

- (IBAction)stop {
	if (!isPlaying) {
		return;
	}
	
	isPlaying = NO;
	AudioQueueStop(in.queue, false);
	btnStop.enabled = NO;
	btnStart.enabled = YES;
}

- (IBAction)sliderUpdated {
	frequency = [freqSlider value];
	[freqLabel setText:[NSString stringWithFormat:@"%.1f Hz", frequency]];
	FL = FR = [self waveFor:frequency];
}

@end
