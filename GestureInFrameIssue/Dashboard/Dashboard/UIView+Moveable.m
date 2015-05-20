//
//  UIView+Moveable.m
//  Dashboard
//
//  Created by Steve Smith on 5/11/15.
//  Copyright (c) 2015 Steve Smith. All rights reserved.
//

#import "UIView+Moveable.h"
#import <objc/runtime.h>

#define STRONG_N OBJC_ASSOCIATION_RETAIN_NONATOMIC
#define ASSIGN   OBJC_ASSOCIATION_ASSIGN
static char _moveable;

@implementation UIView (Moveable)

- (BOOL)isMoveable {
  NSNumber *val = objc_getAssociatedObject(self, &_moveable);
  return [val boolValue];
}

- (void)setMoveable:(BOOL)moveable {
  NSNumber *isMoveable = @(moveable);
  objc_setAssociatedObject(self, &_moveable, isMoveable, ASSIGN);
}

@end
