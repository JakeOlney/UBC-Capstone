//
//  MenuViewController.h
//  GUISync
//
//  Created by Jake Olney on 11/15/2013.
//  Copyright (c) 2013 Jake Olney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define APP_DELEGATE ((AppDelegate*)[[UIApplication sharedApplication] delegate])

@class AudioSignalAnalyzer, FSKSerialGenerator, FSKRecognizer;

@interface MenuViewController : UIViewController <UIApplicationDelegate>
{
    // Sensor Serial Protocol
    int   _state;
    int   _sspRecvDataLength;
    UInt8 _sspRecvData[32];
}

@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) IBOutlet UIView *contentView;
@property (strong, nonatomic) FSKRecognizer *recognizer;
@property (strong, nonatomic) AudioSignalAnalyzer *analyzer;
@property (strong, nonatomic) FSKSerialGenerator *generator;

@end
