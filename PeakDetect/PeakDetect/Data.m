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

+(int) getECG
{
    return ecgProgress;
}

+(void) setECG;
{
    ecgProgress++;
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
