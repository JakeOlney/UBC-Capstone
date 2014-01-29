//
//  OverlayViewController.m
//  SampleDataGUI
//
//  Created by Jake Olney on 11/14/2013.
//  Copyright (c) 2013 Jake Olney. All rights reserved.
//

#import "OverlayViewController.h"
#import "CorePlot-CocoaTouch.h"
#import "FileRead.h"
#import "Data.h"

@interface OverlayViewController ()
{
    int plotIndex;
    int ecgProgress;
    int scgProgress;
    double screenStart;
    NSMutableArray *data1, *data2;
    NSArray *dataTemp1;
    NSArray *dataTemp2;
    NSTimer *newDataTimer;
    NSTimer *scrollTimer;
    int flag;
    CPTPlotSpaceAnnotation *symbolTextAnnotation;
    CPTPlotSpaceAnnotation *symbolText2Annotation;
}

@property (nonatomic, strong) CPTGraphHostingView *hostView;

@end

@implementation OverlayViewController

@synthesize hostView = hostView_;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    data1 = [NSMutableArray arrayWithObjects: nil];
    data2 = [NSMutableArray arrayWithObjects: nil];
    
    FileRead *fileReader = [[FileRead alloc] init];
    dataTemp1 = fileReader.fileReader1;
    dataTemp2 = fileReader.fileReader2;
    int temp = [dataTemp1 count];
    int temp2 = [dataTemp2 count];
    NSLog(@"Number of ECG Points: %i", temp);
    NSLog(@"Number of SCG Points: %i", temp2);
    
    plotIndex = 0;
    ecgProgress = Data.getECG;
    scgProgress = Data.getSCG;
    screenStart = 2000;
    flag = 0;
    
    newDataTimer = [NSTimer scheduledTimerWithTimeInterval:0.00001
                                                             target:self
                                                           selector:@selector(newData:)
                                                           userInfo:nil
                                                            repeats:YES];
    
    scrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.00001
                                                            target:self
                                                          selector:@selector(scrollPlot:)
                                                          userInfo:nil
                                                           repeats:YES];
    
    [self initPlot];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)newData:(NSTimer *)newDataTimer
{
    //Get the plot
    CPTGraph *theGraph = self.hostView.hostedGraph;
    CPTPlot *ECG   = [theGraph plotWithIdentifier:@"ECG"];
    CPTPlot *SCG   = [theGraph plotWithIdentifier:@"SCG"];
    
    //Plot until x=100
    if(ecgProgress > 15000)
    {
        [newDataTimer invalidate];
        newDataTimer = nil;
    }
    
    //Add value to array and then to plot
    else
    {
        NSString *val = [dataTemp1 objectAtIndex:ecgProgress];
        NSNumber *x = [NSNumber numberWithInt:[val intValue]];
        [data1 addObject: x];
        
        NSString *val2 = [dataTemp2 objectAtIndex:scgProgress];
        NSNumber *y = [NSNumber numberWithInt:[val2 intValue]];
        [data2 addObject: y];
        
        if(flag == 9)
        {
            [ECG insertDataAtIndex:data1.count - 10 numberOfRecords:10];
            [SCG insertDataAtIndex:data2.count - 10 numberOfRecords:10];
            NSLog(@"ECG value: %@", val);
            NSLog(@"SCG value: %@", val2);
            plotIndex ++;
            scgProgress ++;
            ecgProgress ++;
            Data.setSCG;
            Data.setECG;
            flag = 0;
        }
        
        else
        {
            NSLog(@"ECG value: %@", val);
            NSLog(@"SCG value: %@", val2);
            plotIndex ++;
            scgProgress ++;
            ecgProgress ++;
            Data.setSCG;
            Data.setECG;
            flag++;
        }

    }
}

-(void) scrollPlot:(NSTimer *)scrollTimer
{
    CPTGraph *theGraph = self.hostView.hostedGraph;
    CPTPlot *ECG   = [theGraph plotWithIdentifier:@"ECG"];
    
    if(ecgProgress > 15000)
    {
        [scrollTimer invalidate];
        scrollTimer = nil;
    }
    else if(plotIndex < 2101)
    {
    }
    else if(plotIndex == 2101)
    {
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1000)
                                                        length:CPTDecimalFromDouble(2100)];
    }
    else
    {
        if (ECG)
        {
            if(screenStart == plotIndex - 1100)
            {
                CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
                plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(screenStart)
                                                                length:CPTDecimalFromDouble(2100)];
                screenStart += 1000;
            }
        }
    }
}

-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configurePlot];
    [self configureAxes];
}

-(void) configureHost
{
    //CGRect parentRect = self.view.bounds;
    CGRect parentRect = CGRectMake(0, 64, 320, 416);
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
    self.hostView.allowPinchScaling = YES;
    hostView_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:hostView_];
}

-(void) configureGraph
{
    // 1 - Create the Graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    self.hostView.hostedGraph = graph;
    graph.paddingLeft = 5.0;
    graph.paddingTop = 5.0;
    graph.paddingRight = 5.0;
    graph.paddingBottom = 5.0;
    
    // 2 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
}

-(void) configurePlot
{
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                    length:CPTDecimalFromFloat(2100)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-200)
                                                    length:CPTDecimalFromFloat(425)];
    CPTTheme *theme = [[CPTTheme alloc] init];
    theme = [CPTTheme themeNamed:kCPTPlainBlackTheme];
    [graph applyTheme: theme];
    graph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    
    // 2 - Create the plot
    CPTScatterPlot *ECG = [[CPTScatterPlot alloc] init];
    ECG.dataSource = self;
    ECG.identifier = @"ECG";
    CPTColor *ECGColor = [CPTColor orangeColor];
    CPTColor *symbolColor = [CPTColor greenColor];
    [graph addPlot:ECG toPlotSpace:plotSpace];
    
    CPTScatterPlot *SCG = [[CPTScatterPlot alloc] init];
    SCG.dataSource = self;
    SCG.identifier = @"SCG";
    CPTColor *SCGColor = [CPTColor cyanColor];
    [graph addPlot:SCG toPlotSpace:plotSpace];
    
    // 3 - Set up plot space
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
    
    // 4 - Create styles and symbols
    CPTMutableLineStyle *ECGLineStyle = [ECG.dataLineStyle mutableCopy];
    ECGLineStyle.lineWidth = 1.0f;
    ECGLineStyle.lineColor = ECGColor;
    ECG.dataLineStyle = ECGLineStyle;
    CPTMutableLineStyle *ECGSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    ECGSymbolLineStyle.lineColor = symbolColor;
    /*CPTPlotSymbol *ECGSymbol = [CPTPlotSymbol ellipsePlotSymbol];
     ECGSymbol.fill = [CPTFill fillWithColor:symbolColor];
     ECGSymbol.lineStyle = ECGSymbolLineStyle;
     ECGSymbol.size = CGSizeMake(1.5f, 1.5f);
     thePlot.plotSymbol = plotSymbol;*/
    
    //Enable touch interaction
    ECG.delegate = self;
    ECG.plotSymbolMarginForHitDetection = 5.0;
    
    CPTMutableLineStyle *SCGLineStyle = [SCG.dataLineStyle mutableCopy];
    SCGLineStyle.lineWidth = 1.0f;
    SCGLineStyle.lineColor = SCGColor;
    SCG.dataLineStyle = SCGLineStyle;
    CPTMutableLineStyle *SCGSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    SCGSymbolLineStyle.lineColor = symbolColor;
    /*CPTPlotSymbol *ECGSymbol = [CPTPlotSymbol ellipsePlotSymbol];
     ECGSymbol.fill = [CPTFill fillWithColor:symbolColor];
     ECGSymbol.lineStyle = ECGSymbolLineStyle;
     ECGSymbol.size = CGSizeMake(1.5f, 1.5f);
     thePlot.plotSymbol = plotSymbol;*/
    
    //Enable touch interaction
    SCG.delegate = self;
    SCG.plotSymbolMarginForHitDetection = 5.0;
}

-(void) configureAxes
{
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 1.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 6.0f;
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineColor = [CPTColor whiteColor];
    gridLineStyle.lineWidth = 1.0f;
    
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    
    // 3 - Configure x-axis
    NSDecimalNumber *xTitle = [[NSDecimalNumber alloc] initWithFloat: 51.5];
    NSDecimal decimal = [xTitle decimalValue];
    
    CPTAxis *x = axisSet.xAxis;
    x.title = @"X";
    x.titleTextStyle = axisTitleStyle;
    x.titleLocation = decimal;
    x.titleOffset = 0.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.labelOffset = -15.0f;
    //x.majorGridLineStyle = gridLineStyle;
    x.majorTickLineStyle = tickLineStyle;
    x.minorTickLineStyle = axisLineStyle;
    x.majorTickLength = 7.0f;
    x.minorTickLength = 5.0f;
    x.tickDirection = CPTSignNegative;
    
    NSInteger xmajorIncrement = 500;
    NSInteger xminorIncrement = 100;
    CGFloat xMax = 15000.0f;
    NSMutableSet *xLabels = [NSMutableSet set];
    NSMutableSet *xMajorLocations = [NSMutableSet set];
    NSMutableSet *xMinorLocations = [NSMutableSet set];
    for (NSInteger i = xminorIncrement; i <= xMax; i += xminorIncrement)
    {
        NSInteger mod = i % xmajorIncrement;
        if (mod == 0)
        {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", i] textStyle:x.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(i);
            label.tickLocation = location;
            label.offset = -x.majorTickLength - x.labelOffset;
            /*if (label)
            {
                [xLabels addObject:label];
            }*/
            
            [xMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        }
        else
        {
            [xMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(i)]];
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xMajorLocations;
    x.minorTickLocations = xMinorLocations;
    
    // 4 - Configure y-axis
    NSDecimalNumber *yTitle = [[NSDecimalNumber alloc] initWithFloat: 1000];
    NSDecimal decimal2 = [yTitle decimalValue];
    CGFloat angle = 0;
    
    CPTAxis *y = axisSet.yAxis;
    y.title = @"Y";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = 0.0f;
    y.titleLocation = decimal2;
    y.titleRotation = angle;
    y.axisLineStyle = axisLineStyle;
    //y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = -15.0f;
    y.majorTickLineStyle = tickLineStyle;
    y.minorTickLineStyle = axisLineStyle;
    y.majorTickLength = 7.0f;
    y.minorTickLength = 5.0f;
    y.tickDirection = CPTSignNegative;
    
    NSInteger ymajorIncrement = 100;
    NSInteger yminorIncrement = 25;
    CGFloat yMax = 1000.0f;
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = -500; j <= yMax; j += yminorIncrement)
    {
        NSUInteger mod = j % ymajorIncrement;
        if (mod == 0)
        {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label)
            {
                [yLabels addObject:label];
            }
            
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        }
        else
        {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if([plot.identifier isEqual:@"ECG"])
    {
        return [data1 count];
    }
    else
    {
        return [data2 count];
    }
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if(fieldEnum == CPTScatterPlotFieldX)
    {
        NSNumber *a = [NSNumber numberWithInt:index];
        return a;
    }
    else
    {
        NSNumber *b;
        
        if([plot.identifier isEqual:@"ECG"])
        {
            b = [data1 objectAtIndex:index];
        }
        
        else
        {
            b = [data2 objectAtIndex:index];
        }
        
        return b;
    }
}

- (IBAction)exit:(id)sender
{
    [newDataTimer invalidate];
    newDataTimer = nil;
    [scrollTimer invalidate];
    scrollTimer = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pause:(id)sender
{
    if ([sender isSelected]) {
        [sender setImage:[UIImage imageNamed:@"pauseWhite"] forState:UIControlStateNormal];
        [sender setSelected:NO];
        
        newDataTimer = [NSTimer scheduledTimerWithTimeInterval:0.00001
                                                        target:self
                                                      selector:@selector(newData:)
                                                      userInfo:nil
                                                       repeats:YES];
        
        scrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.00001
                                                       target:self
                                                     selector:@selector(scrollPlot:)
                                                     userInfo:nil
                                                      repeats:YES];
        
    }
    else
    {
        if(newDataTimer != nil)
        {
            [newDataTimer invalidate];
            newDataTimer = nil;
        }
        [sender setImage:[UIImage imageNamed:@"playWhite"] forState:UIControlStateSelected];
        [sender setSelected:YES];
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(UIInterfaceOrientationIsPortrait(fromInterfaceOrientation))
    {
        NSLog(@"I am in Landscape");
    }
    
    else
    {
        NSLog(@"I am in portrait");
    }
}

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx
{
    NSNumber *val = [data1 objectAtIndex:idx];
    NSLog(@"Touched point: %ld, with value: %@", idx, val);
    //NSLog(@"Touch!");
    
    CPTGraph *graph = self.hostView.hostedGraph;
    
    //if([plot.identifier isEqual:@"ECG"])
    //{
        if ( symbolTextAnnotation ) {
            [graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
            symbolTextAnnotation = nil;
        }
        
        // Setup a style for the annotation
        CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
        hitAnnotationTextStyle.color    = [CPTColor whiteColor];
        hitAnnotationTextStyle.fontSize = 16.0;
        hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
        
        // Determine point of symbol in plot coordinates
        NSNumber *x          = [NSNumber numberWithInt:idx];
        NSNumber *y          = [data1 objectAtIndex:idx];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
        
        //Make a string for the y value
        NSString *yString = [y stringValue];
        
        // Now add the annotation to the plot area
        CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle];
        symbolTextAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:graph.defaultPlotSpace anchorPlotPoint:anchorPoint];
        symbolTextAnnotation.contentLayer = textLayer;
        symbolTextAnnotation.displacement = CGPointMake(0.0, 20.0);
        [graph.plotAreaFrame.plotArea addAnnotation:symbolTextAnnotation];
    //}
    
    /*else
    {
        if ( symbolText2Annotation ) {
            [graph2.plotAreaFrame.plotArea removeAnnotation:symbolText2Annotation];
            symbolText2Annotation = nil;
        }
        
        // Setup a style for the annotation
        CPTMutableTextStyle *hitAnnotation2TextStyle = [CPTMutableTextStyle textStyle];
        hitAnnotation2TextStyle.color    = [CPTColor whiteColor];
        hitAnnotation2TextStyle.fontSize = 16.0;
        hitAnnotation2TextStyle.fontName = @"Helvetica-Bold";
        
        // Determine point of symbol in plot coordinates
        NSNumber *x2          = [NSNumber numberWithInt:idx];
        NSNumber *y2          = [data2 objectAtIndex:idx];
        NSArray *anchor2Point = [NSArray arrayWithObjects:x2, y2, nil];
        
        //Make a string for the y value
        NSString *y2String = [y2 stringValue];
        
        // Now add the annotation to the plot area
        CPTTextLayer *text2Layer = [[CPTTextLayer alloc] initWithText:y2String style:hitAnnotation2TextStyle];
        symbolText2Annotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:graph2.defaultPlotSpace anchorPlotPoint:anchor2Point];
        symbolText2Annotation.contentLayer = text2Layer;
        symbolText2Annotation.displacement = CGPointMake(0.0, 20.0);
        [graph2.plotAreaFrame.plotArea addAnnotation:symbolText2Annotation];
    }*/
}

@end