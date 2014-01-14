//
//  Data.h
//  GUISync
//
//  Created by Jake Olney on 11/15/2013.
//  Copyright (c) 2013 Jake Olney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Data : NSObject

+(void) initECG;

+(int) getECG;

+(void) setECG;

+(void) addECG:(double) newPoint;

+(NSNumber*)getECGData:(int) index;

+(int) getSCG;

+(void) setSCG;

@end
