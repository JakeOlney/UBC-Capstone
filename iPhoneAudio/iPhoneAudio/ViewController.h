//
//  ViewController.h
//  iPhoneAudio
//
//  Created by Jake Olney on 2/26/2014.
//  Copyright (c) 2014 Jake Olney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioController.h"

@interface ViewController : UIViewController
{
    IBOutlet AudioController *audioController;
}

@property (readonly, nonatomic) AudioController *audioController;

@end
