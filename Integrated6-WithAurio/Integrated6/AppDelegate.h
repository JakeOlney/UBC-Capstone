//
//  AppDelegate.h
//  Integrated6
//
//  Created by Jake Olney on 1/28/2014.
//  Copyright (c) 2014 Jake Olney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#include <libkern/OSAtomic.h>
#include <CoreFoundation/CFURL.h>

#import "EAGLView.h"
#import "FFTBufferManager.h"
#import "aurio_helper.h"
#import "CAStreamBasicDescription.h"

typedef enum aurioTouchDisplayMode {
	aurioTouchDisplayModeOscilloscopeWaveform,
	aurioTouchDisplayModeOscilloscopeFFT,
	aurioTouchDisplayModeSpectrum
} aurioTouchDisplayMode;
/*

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

*/

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow*			window;
	IBOutlet EAGLView*			view;
	
	AudioUnit					rioUnit;
	BOOL						unitIsRunning;
	BOOL						unitHasBeenCreated;
	
	aurioTouchDisplayMode		displayMode;
	
	BOOL						mute;
    
	FFTBufferManager*			fftBufferManager;
	DCRejectionFilter*			dcFilter;
	CAStreamBasicDescription	thruFormat;
    CAStreamBasicDescription    drawFormat;
    AudioBufferList*            drawABL;
	Float64						hwSampleRate;
    
    AudioConverterRef           audioConverter;
	
	AURenderCallbackStruct		inputProc;
    
	SystemSoundID				buttonPressSound;
	
}

@property (assign)				aurioTouchDisplayMode	displayMode;

@property (nonatomic, assign)	AudioUnit				rioUnit;
@property (nonatomic, assign)	BOOL					unitIsRunning;
@property (nonatomic, assign)	BOOL					unitHasBeenCreated;
@property (nonatomic, assign)	BOOL					mute;
@property (nonatomic, assign)	AURenderCallbackStruct	inputProc;
@property (strong, nonatomic)   UIWindow *window;

@end
