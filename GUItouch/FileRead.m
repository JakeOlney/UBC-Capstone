//
//  FileRead.m
//  SampleDataGUI
//
//  Created by Jake Olney on 11/14/2013.
//  Copyright (c) 2013 Jake Olney. All rights reserved.
//

#import "FileRead.h"

@implementation FileRead

- (NSArray *) fileReader1
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"ECG"
                                                     ofType:@"txt"];
    
    NSString* fileContents = [NSString stringWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding
                                                          error:NULL];
    
    NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
    
    return lines;
}

- (NSArray *) fileReader2
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SCG"
                                                     ofType:@"txt"];
    
    NSString* fileContents = [NSString stringWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding
                                                          error:NULL];
    
    NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
    
    return lines;
}

@end