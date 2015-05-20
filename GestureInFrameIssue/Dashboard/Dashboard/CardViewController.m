//
//  CardViewController.m
//  Dashboard
//
//  Created by Steve Smith on 5/8/15.
//  Copyright (c) 2015 Steve Smith. All rights reserved.
//

#import "CardViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CardViewController ()
- (IBAction)buttonTap:(id)sender;

@end

@implementation CardViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [_lblLabel setText:[NSString stringWithFormat:@"%li", (long)[self cardNumber]]];
  [[[self view] layer] setBorderColor:[[UIColor blackColor] CGColor]];
  [[[self view] layer] setBorderWidth:1.0];
}

- (IBAction)buttonTap:(id)sender {
  NSString *message = [NSString stringWithFormat:@"You tapped %li", (long)[self cardNumber]];
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tap" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alert show];
}
@end
