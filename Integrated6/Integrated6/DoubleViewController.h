//
//  DoubleViewController.h
//  SampleDataGUI
//
//  Created by Jake Olney on 11/14/2013.
//  Copyright (c) 2013 Jake Olney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CPTScatterPlot.h"
#import "CPTPlot.h"

#define APP_DELEGATE ((AppDelegate*)[[UIApplication sharedApplication] delegate])


@class AudioSignalAnalyzer, FSKSerialGenerator, FSKRecognizer;

@interface DoubleViewController : UIViewController <CPTScatterPlotDelegate, CPTPlotDelegate, UIApplicationDelegate>
{
    // Sensor Serial Protocol
    int   _state;
    int   _sspRecvDataLength;
    UInt8 _sspRecvData[32];
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *exit;
@property (weak, nonatomic) IBOutlet UIButton *pause;
@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) IBOutlet UIView *contentView;
@property (strong, nonatomic) FSKRecognizer *recognizer;
@property (strong, nonatomic) AudioSignalAnalyzer *analyzer;
@property (strong, nonatomic) FSKSerialGenerator *generator;

- (IBAction)exit:(id)sender;
- (IBAction)pause:(id)sender;

-(void) scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx;

@end