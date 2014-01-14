//
//  MenuViewController.m
//  GUISync
//
//  Created by Jake Olney on 11/15/2013.
//  Copyright (c) 2013 Jake Olney. All rights reserved.
//

#import "MenuViewController.h"
#import "AudioSignalAnalyzer.h"
#import "FSKSerialGenerator.h"
#import "FSKRecognizer.h"
#import "SensorSerialProtocol.h"
#import "Data.h"
#define SEND_GO 252

@interface MenuViewController ()

@end

@implementation MenuViewController

@synthesize scrollView, contentView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize: (CGSizeMake(320, 500))];
    
    _recognizer = [[FSKRecognizer alloc] init];
    [_recognizer addReceiver:self];
    _analyzer = [[AudioSignalAnalyzer alloc] init];
    [_analyzer addRecognizer:_recognizer];
    _generator = [[FSKSerialGenerator alloc] init];
    [_generator play];
    
    
    //[APP_DELEGATE.generator writeByte: (uint8_t)252]; //ready go code
    
    
    //[APP_DELEGATE.generator writeByte: (uint8_t)SEND_GO]; //ready go code
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if(session.inputAvailable) {
        NSLog(@"Input is available, playandrecord Herererere\n");
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        NSLog(@"Input is available, playback\n");
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    [session setActive:YES error:nil];
    [session setPreferredIOBufferDuration:0.023220 error:nil];
    
    if (session.inputAvailable) {
        //[APP_DELEGATE.generator writeByte: (uint8_t)ARDUINO_READ]; //ready go code
        NSLog(@"Input is available, analyzer record\n");
        
        
        [_analyzer record];
        
        //  NSLog(@"Here\n");
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(intervalReadReq:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AVAudioSessionDelegate
- (void)inputIsAvailableChanged:(BOOL)isInputAvailable
{
    NSLog(@"inputIsAvailableChanged %d", isInputAvailable);
    AVAudioSession *session = [AVAudioSession sharedInstance]; [_analyzer stop];
    [_generator stop];
    
    if(isInputAvailable) {
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [_analyzer record]; }
    else {
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    [_generator play];
}

- (void)beginInterruption {
    NSLog(@"beginInterruption");
}

- (void)endInterruption{
    NSLog(@"endInterruption");
}

- (void)restartAnalyzerAndGenerator:(BOOL)isInputAvailable
{
	AVAudioSession *session = [AVAudioSession sharedInstance];
	[session setActive:YES error:nil];
	[_analyzer stop];
	[_generator stop];
	if(isInputAvailable)
    {
		[session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
		[_analyzer record];
	}
    else
    {
		[session setCategory:AVAudioSessionCategoryPlayback error:nil];
	}
	[_generator play];
}


#pragma mark - FSK

- (void)intervalReadReq:(NSTimer*)theTimer
{
    [_generator writeByte: (UInt8)ARDUINO_READ];
    _state = ARDUINO_READ;
    _sspRecvDataLength = 0;
}


- (void) receivedChar:(char)input
{
    int z=input;
    NSLog(@"input");
    // int c=0;
    
    //  int temp = input;
    if (input >= -128 && input < 0 )
    {
        z = 2*128 + input;
    }
    else
    {
        z = input;
    }
    
    NSLog(@"input: %i", z);
    double ECGvalue = z*1.2/255;
    NSLog(@"input: %f", ECGvalue);
    [Data addECG: ECGvalue];
    Data.setECG;
    
}

@end
