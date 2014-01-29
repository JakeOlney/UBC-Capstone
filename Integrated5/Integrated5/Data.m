//
//  Data.m
//  GUISync
//
//  Created by Jake Olney on 11/15/2013.
//  Copyright (c) 2013 Jake Olney. All rights reserved.
//

#import "Data.h"


@implementation Data

static int ecgProgress = 0;
static int scgProgress = 0;
static NSMutableArray *data1;

+(void) initECG
{
    data1 = [NSMutableArray arrayWithObjects:nil];
    //data1 = [NSMutableArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", nil];

}

+(int) getECG
{
    return ecgProgress;
}

+(void) setECG;
{
    ecgProgress++;
}

+(void) addECG:(int) newPoint
{
    NSNumber *temp = [NSNumber numberWithInt:newPoint];
    [data1 addObject: temp];
    NSLog(@"newPoint: %i", newPoint);
    NSLog(@"temp addECG: %@", temp);
    //NSLog(@"temp data1: %@", [data1 objectAtIndex:ecgProgress]);
}

+(NSNumber*)getECGData:(int) index 
{
    return [data1 objectAtIndex: index];
}

+(int) getSCG
{
    return scgProgress;
}

+(void) setSCG;
{
    scgProgress++;
}

@end
