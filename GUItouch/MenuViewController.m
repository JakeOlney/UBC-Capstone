//
//  MenuViewController.m
//  GUISync
//
//  Created by Jake Olney on 11/15/2013.
//  Copyright (c) 2013 Jake Olney. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

@synthesize scrollView, contentView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize: (CGSizeMake(320, 500))];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
