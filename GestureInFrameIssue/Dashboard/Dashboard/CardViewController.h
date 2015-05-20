//
//  CardViewController.h
//  Dashboard
//
//  Created by Steve Smith on 5/8/15.
//  Copyright (c) 2015 Steve Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Moveable.h"

@interface CardViewController : UIViewController

@property (nonatomic, assign) NSInteger cardNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblLabel;

@end
