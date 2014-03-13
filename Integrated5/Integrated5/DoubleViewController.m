//
//  DoubleViewController.m
//  SampleDataGUI
//
//  Created by Jake Olney on 11/14/2013.
//  Copyright (c) 2013 Jake Olney. All rights reserved.
//

#import "DoubleViewController.h"
#import "CorePlot-CocoaTouch.h"
//#import "FileRead.h"
#import "Data.h"
#import "AudioSignalAnalyzer.h"
#import "FSKSerialGenerator.h"
#import "FSKRecognizer.h"
#import "SensorSerialProtocol.h"
#define SEND_GO 252

@interface DoubleViewController ()
{
    int plotIndex;
    int ecgProgress;
    //int scgProgress;
    double screenStart1;
    //double screenStart2;
    NSMutableArray *data1;
    //NSMutableArray *data2;
    NSArray *dataTemp1;
    //NSArray *dataTemp2;
    NSTimer *readTimer;
    NSTimer *newDataTimer;
    NSTimer *scrollTimer1;
    //NSTimer *scrollTimer2;
    int flag;
    CPTPlotSpaceAnnotation *symbolTextAnnotation;
    //CPTPlotSpaceAnnotation *symbolText2Annotation;
}

@property (nonatomic, strong) CPTGraphHostingView *hostView1;
@property (nonatomic, strong) CPTGraphHostingView *hostView2;

@end

@implementation DoubleViewController

@synthesize hostView1 = hostView1_;
@synthesize hostView2 = hostView2_;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //ADRIANS CODE
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
    
    /*readTimer =*/ [NSTimer scheduledTimerWithTimeInterval:0.0001
                                     target:self
                                   selector:@selector(intervalReadReq:)
                                   userInfo:nil
                                    repeats:YES];
    
    //JAKES CODE
    Data.initECG;
    data1 = [NSMutableArray arrayWithObjects: nil];
    //data2 = [NSMutableArray arrayWithObjects: nil];

    /*FileRead *fileReader = [[FileRead alloc] init];
    dataTemp1 = fileReader.fileReader1;
    dataTemp2 = fileReader.fileReader2;
    int temp = [dataTemp1 count];
    int temp2 = [dataTemp2 count];
    NSLog(@"Number of ECG Points: %i", temp);
    NSLog(@"Number of SCG Points: %i", temp2);*/

    plotIndex = 0;
    ecgProgress = Data.getECG;
    //scgProgress = Data.getSCG;
    screenStart1 = 500;
    //screenStart2 = 2000;

    flag = 0;

    /*newDataTimer = [NSTimer scheduledTimerWithTimeInterval:0.00001
                                                             target:self
                                                           selector:@selector(newData:)
                                                           userInfo:nil
                                                            repeats:YES];*/

    scrollTimer1 = [NSTimer scheduledTimerWithTimeInterval:0.0001
                                                            target:self
                                                          selector:@selector(scrollPlot1:)
                                                          userInfo:nil
                                                           repeats:YES];

    /*scrollTimer2 = [NSTimer scheduledTimerWithTimeInterval:0.00001
                                                            target:self
                                                          selector:@selector(scrollPlot2:)
                                                          userInfo:nil
                                                           repeats:YES];*/

    [self initPlot];
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
    NSLog(@"Break 1");
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
   // int temp = (int)input;
    
    // int c=0;
    
    //  int temp = input;
    if (input >= -128 && input < 0 )
    {
        z = 2*128 + input;
    }
  //  else
  //  {
  //      z = input;
  //  }
    
    NSLog(@"input: %i", z);
    ///NSLog(@"temp: %i", temp);
    [Data addECG: z];
    Data.setECG;
    [self newData];
    
}


-(void)newData
{
    //Get the plots
    CPTGraph *theGraph1 = self.hostView1.hostedGraph;
    CPTPlot *ECG   = [theGraph1 plotWithIdentifier:@"ECG"];
    
    /*CPTGraph *theGraph2 = self.hostView2.hostedGraph;
    CPTPlot *SCG   = [theGraph2 plotWithIdentifier:@"SCG"];*/
    
    /*//Plot until x=100
    if(ecgProgress > 15000)
    {
        [newDataTimer invalidate];
        newDataTimer = nil;
    }
    
    //Add value to array and then to plot
    else
    {*/
        //NSString *val = [dataTemp1 objectAtIndex:ecgProgress];
        NSNumber *x = [Data getECGData:ecgProgress];
        [data1 addObject: x];
        
        /*NSString *val2 = [dataTemp2 objectAtIndex:scgProgress];
        NSNumber *y = [NSNumber numberWithInt:[val2 intValue]];
        [data2 addObject: y];*/
        
        if(flag == 9)
        {
            [ECG insertDataAtIndex:data1.count - 10 numberOfRecords:10];
            //[SCG insertDataAtIndex:data2.count - 10 numberOfRecords:10];
            //NSLog(@"ECG value: %@", val);
            //NSLog(@"SCG value: %@", val2);
            
            plotIndex ++;
            ecgProgress ++;
            //scgProgress ++;
            //Data.setECG;
            //Data.setSCG;
            flag = 0;
        }
        
        else
        {
            //NSLog(@"ECG value: %@", val);
            //NSLog(@"SCG value: %@", val2);
            
            plotIndex ++;
            ecgProgress ++;
            //scgProgress ++;
            //Data.setECG;
            //Data.setSCG;
            flag ++;
        }
    }
//}

-(void) scrollPlot1:(NSTimer *)scrollTimer1
{
    CPTGraph *theGraph = self.hostView1.hostedGraph;
    CPTPlot *ECG   = [theGraph plotWithIdentifier:@"ECG"];
    
    /*if(ecgProgress > 15000)
    {
        [scrollTimer1 invalidate];
        scrollTimer1 = nil;
    }
    else */if(plotIndex < 601)
    {
    }
    else if(plotIndex == 601)
    {
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(250)
                                                        length:CPTDecimalFromDouble(600)];
    }
    else
    {
        if (ECG)
        {
            if(screenStart1 == plotIndex - 600)
            {
                CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
                plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(screenStart1)
                                                                length:CPTDecimalFromDouble(600)];
                screenStart1 += 250;
            }
        }
    }
}

/*-(void) scrollPlot2:(NSTimer *)scrollTimer2
{
    CPTGraph *theGraph = self.hostView2.hostedGraph;
    CPTPlot *SCG   = [theGraph plotWithIdentifier:@"SCG"];
    
    if(ecgProgress > 15000)
    {
        [scrollTimer2 invalidate];
        scrollTimer2 = nil;
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
        if (SCG)
        {
            if(screenStart2 == plotIndex - 1100)
            {
                CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
                plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(screenStart2)
                                                                length:CPTDecimalFromDouble(2100)];
                screenStart2 += 1000;
            }
        }
    }
}*/

-(void)initPlot
{
    [self configureHost];
    [self configureGraph];
    [self configurePlot1];
    [self configurePlot2];
    [self configureAxes1];
    [self configureAxes2];
}

-(void) configureHost
{
    //CGRect parentRect = self.view.bounds;
    CGRect parentRect1 = CGRectMake(0, 64, 320, 208);
    self.hostView1 = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect1];
    self.hostView1.allowPinchScaling = YES;
    hostView1_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:hostView1_];
    
    CGRect parentRect2 = CGRectMake(0, 272, 320, 208);
    self.hostView2 = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect2];
    self.hostView2.allowPinchScaling = YES;
    hostView2_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:hostView2_];
}

-(void) configureGraph
{
    // 1 - Create the Graph
    CPTGraph *graph1 = [[CPTXYGraph alloc] initWithFrame:self.hostView1.bounds];
    self.hostView1.hostedGraph = graph1;
    graph1.paddingLeft = 5.0;
    graph1.paddingTop = 5.0;
    graph1.paddingRight = 5.0;
    graph1.paddingBottom = 5.0;
    
    CPTGraph *graph2 = [[CPTXYGraph alloc] initWithFrame:self.hostView2.bounds];
    self.hostView2.hostedGraph = graph2;
    graph2.paddingLeft = 5.0;
    graph2.paddingTop = 5.0;
    graph2.paddingRight = 5.0;
    graph2.paddingBottom = 5.0;
    
    // 2 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace1 = (CPTXYPlotSpace *) graph1.defaultPlotSpace;
    plotSpace1.allowsUserInteraction = YES;
    
    CPTXYPlotSpace *plotSpace2 = (CPTXYPlotSpace *) graph2.defaultPlotSpace;
    plotSpace2.allowsUserInteraction = YES;
}

-(void) configurePlot1
{
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView1.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-50)
                                                    length:CPTDecimalFromFloat(650)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-200)
                                                    length:CPTDecimalFromFloat(800)];
    CPTTheme *theme = [[CPTTheme alloc] init];
    theme = [CPTTheme themeNamed:kCPTPlainBlackTheme];
    [graph applyTheme: theme];
    graph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    
    // 2 - Create the plot
    CPTScatterPlot *ECG = [[CPTScatterPlot alloc] init];
    ECG.dataSource = self;
    ECG.identifier = @"ECG";
    CPTColor *ECGColor = [CPTColor orangeColor];
    [graph addPlot:ECG toPlotSpace:plotSpace];
    
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
    /*CPTMutableLineStyle *ECGSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    ECGSymbolLineStyle.lineColor = ECGColor;
    CPTPlotSymbol *ECGSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    ECGSymbol.fill = [CPTFill fillWithColor:ECGColor];
    ECGSymbol.lineStyle = ECGSymbolLineStyle;
    ECGSymbol.size = CGSizeMake(1.1f, 1.1f);
    ECG.plotSymbol = ECGSymbol;*/
    
    //Enable touch interaction
    ECG.delegate                        = self;
    ECG.plotSymbolMarginForHitDetection = 5.0;
}

-(void) configurePlot2
{
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView2.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-50)
                                                    length:CPTDecimalFromFloat(2150)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-50)
                                                    length:CPTDecimalFromFloat(100)];
    CPTTheme *theme = [[CPTTheme alloc] init];
    theme = [CPTTheme themeNamed:kCPTPlainBlackTheme];
    [graph applyTheme: theme];
    graph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    
    // 2 - Create the plot
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
    CPTMutableLineStyle *SCGLineStyle = [SCG.dataLineStyle mutableCopy];
    SCGLineStyle.lineWidth = 1.0f;
    SCGLineStyle.lineColor = SCGColor;
    SCG.dataLineStyle = SCGLineStyle;
    /*CPTMutableLineStyle *SCGSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    SCGSymbolLineStyle.lineColor = SCGColor;
    CPTPlotSymbol *SCGSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    SCGSymbol.fill = [CPTFill fillWithColor:SCGColor];
    SCGSymbol.lineStyle = SCGSymbolLineStyle;
    SCGSymbol.size = CGSizeMake(1.1f, 1.1f);
    SCG.plotSymbol = SCGSymbol;*/
    
    //Enable touch interaction
    SCG.delegate                        = self;
    SCG.plotSymbolMarginForHitDetection = 5.0;
}

-(void) configureAxes1
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
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView1.hostedGraph.axisSet;
    
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
    
    NSInteger xmajorIncrement = 100;
    NSInteger xminorIncrement = 50;
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

-(void) configureAxes2
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
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView2.hostedGraph.axisSet;
    
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
    y.majorGridLineStyle = gridLineStyle;
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
    return [data1 count];
    
    /*if([plot.identifier isEqual:@"ECG"])
    {
        return [data1 count];
    }
    else
    {
        return [data2 count];
    }*/
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
            //b = [data2 objectAtIndex:index];
        }
        
        return b;
    }
}

- (IBAction)exit:(id)sender
{
    [newDataTimer invalidate];
    newDataTimer = nil;
    [scrollTimer1 invalidate];
    scrollTimer1 = nil;
    //[scrollTimer2 invalidate];
    //scrollTimer2 = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pause:(id)sender
{
    if ([sender isSelected]) {
        [sender setImage:[UIImage imageNamed:@"pauseWhite"] forState:UIControlStateNormal];
        [sender setSelected:NO];
        
        /*readTimer = [NSTimer scheduledTimerWithTimeInterval:0.001
                                                     target:self
                                                   selector:@selector(intervalReadReq:)
                                                   userInfo:nil
                                                    repeats:YES];*/
        
        /*newDataTimer = [NSTimer scheduledTimerWithTimeInterval:0.00001
                                                        target:self
                                                      selector:@selector(newData:)
                                                      userInfo:nil
                                                       repeats:YES];*/
        
        scrollTimer1 = [NSTimer scheduledTimerWithTimeInterval:0.001
                                                       target:self
                                                     selector:@selector(scrollPlot1:)
                                                     userInfo:nil
                                                      repeats:YES];
        
        /*scrollTimer2 = [NSTimer scheduledTimerWithTimeInterval:0.00001
                                                        target:self
                                                      selector:@selector(scrollPlot2:)
                                                      userInfo:nil
                                                       repeats:YES];*/
        
    }
    else
    {
        if(readTimer != nil)
        {
            [readTimer invalidate];
            readTimer = nil;
        }
        [sender setImage:[UIImage imageNamed:@"playWhite"] forState:UIControlStateSelected];
        [sender setSelected:YES];
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(fromInterfaceOrientation == UIInterfaceOrientationPortrait || fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        NSLog(@"I am in Landscape");
        
        CGRect parentRect1 = CGRectMake(0, 64, 480, 128);
        
        CGRect parentRect2 = CGRectMake(0, 192, 480, 128);
        
        self.hostView1.frame = parentRect1;
        self.hostView2.frame = parentRect2;
    }
    
    else if(fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        NSLog(@"I am in portrait");
        
        CGRect parentRect1 = CGRectMake(0, 64, 320, 208);
        CGRect parentRect2 = CGRectMake(0, 272, 320, 208);
        
        self.hostView1.frame = parentRect1;
        self.hostView2.frame = parentRect2;
    }
}

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx
{
    NSNumber *val = [data1 objectAtIndex:idx];
    NSLog(@"Touched point: %ld, with value: %@", idx, val);
    //NSLog(@"Touch!");
    
    CPTGraph *graph1 = self.hostView1.hostedGraph;
    CPTGraph *graph2 = self.hostView2.hostedGraph;
    
    /*//Find max value within 20 points of touch
    NSNumber *max = 0;
    NSNumber *maxTemp = 0;
    int maxIndex = 0;
    
    for(int i = idx-10; i < idx+10; i++)
    {
        if([data1 objectAtIndex:i] < [data1 objectAtIndex:i+1])
        {
            maxTemp = [data1 objectAtIndex:i+1];
            
            if(
            maxIndex = i+1;
        }
        
        else
        {
            max = [data1 objectAtIndex:i];
            maxIndex = i+1;
        }
    }*/
    
    
    
    if([plot.identifier isEqual:@"ECG"])
    {
        if ( symbolTextAnnotation )
        {
            [graph1.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
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
        symbolTextAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:graph1.defaultPlotSpace anchorPlotPoint:anchorPoint];
        symbolTextAnnotation.contentLayer = textLayer;
        symbolTextAnnotation.displacement = CGPointMake(0.0, 20.0);
        [graph1.plotAreaFrame.plotArea addAnnotation:symbolTextAnnotation];
    }
    
    else
    {
        /*if ( symbolText2Annotation ) {
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
        [graph2.plotAreaFrame.plotArea addAnnotation:symbolText2Annotation];*/
    }
}

@end
