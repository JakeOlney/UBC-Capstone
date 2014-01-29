//
//  OverlayViewController.h
//  SampleDataGUI
//
//  Created by Jake Olney on 11/14/2013.
//  Copyright (c) 2013 Jake Olney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverlayViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *exit;
@property (weak, nonatomic) IBOutlet UIButton *pause;


- (IBAction)exit:(id)sender;
- (IBAction)pause:(id)sender;


@end


