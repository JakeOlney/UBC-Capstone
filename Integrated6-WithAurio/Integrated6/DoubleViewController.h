//
//  DoubleViewController.h
//  SampleDataGUI
//
//  Created by Jake Olney on 11/14/2013.
//  Copyright (c) 2013 Jake Olney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPTScatterPlot.h"
#import "CPTPlot.h"



@interface DoubleViewController : UIViewController <CPTScatterPlotDelegate, CPTPlotDelegate, CPTScatterPlotDataSource>

@property (assign, nonatomic) IBOutlet UIBarButtonItem *exit;
@property (assign, nonatomic) IBOutlet UIButton *pause;
@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) IBOutlet UIView *contentView;

- (IBAction)exit:(id)sender;
- (IBAction)pause:(id)sender;

-(void) scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx;

@end