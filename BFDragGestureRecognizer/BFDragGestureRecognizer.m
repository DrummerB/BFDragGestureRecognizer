//
// Created by Balázs Faludi on 21.10.14.
// Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import "BFDragGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

#define kSpeedMultiplier 0.2

@interface BFDragGestureRecognizer ()

@end

@implementation BFDragGestureRecognizer {
    CGPoint _translationInWindow;
    CGPoint _amountScrolled;
    CGPoint _scrollSpeed;

    CGPoint _startLocation;
    CGPoint _startContentOffset;

    BOOL _holding;
    BOOL _scrolling;

    NSTimer *_holdTimer;

    CADisplayLink *_displayLink;
    BOOL _nextDeltaTimeZero;
    CFTimeInterval _previousTimestamp;
}

- (id)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self) {
        _allowHorizontalScrolling = YES;
        _allowVerticalScrolling = YES;
        _minimumPressDuration = 0.5;
        _minimumMovement = 0;
        _maximumMovement = 10;
        _autoScrollInsets = UIEdgeInsetsMake(44, 44, 44, 44);
        _frame = CGRectNull;
    }
    return self;
}

- (CGPoint)translationInView:(UIView *)view {
    CGPoint totalTranslationInWindow = CGPointMake(_translationInWindow.x + _amountScrolled.x,
                                                   _translationInWindow.y + _amountScrolled.y);
    CGPoint totalTranslationInView = [view convertPoint:totalTranslationInWindow fromView:nil];
    CGPoint totalTranslationOfView = [view convertPoint:CGPointZero fromView:nil];
    totalTranslationInView = CGPointMake(totalTranslationInView.x - totalTranslationOfView.x,
                                         totalTranslationInView.y - totalTranslationOfView.y);
    return totalTranslationInView;
}

- (UIScrollView *)enclosingScrollView {
    UIView *view = self.view.superview;
    while (view) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            return (UIScrollView *)view;
        }
        view = view.superview;
    }
    return nil;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [self enclosingScrollView];
    }
    return _scrollView;
}

- (CGRect)frame {
    if (CGRectIsNull(_frame)) {
        if (self.view) {
            return self.view.bounds;
        }
        return CGRectZero;
    }
    return _frame;
}

- (void)holdTimerFired:(NSTimer *)timer {
    _holding = NO;
    if ([self canBeginGesture]) {
        self.state = UIGestureRecognizerStateBegan;
    }
}

- (BOOL)canBeginGesture {
    CGFloat distance = (CGFloat)sqrt(_translationInWindow.x * _translationInWindow.x + _translationInWindow.y * _translationInWindow.y);
    return distance >= self.minimumMovement && self.state == UIGestureRecognizerStatePossible;
}

#pragma mark - Resetting

- (void)tearDown {
    [self endScrolling];
    [_holdTimer invalidate];
}

- (void)reset {
    _holding = NO;
    _scrolling = NO;
    _translationInWindow = CGPointZero;
    _amountScrolled = CGPointZero;
    _scrollSpeed = CGPointZero;
}

#pragma mark - Auto Scrolling

- (void)beginScrolling {
    if (!_scrolling) {
        _scrolling = YES;
        _nextDeltaTimeZero = YES;
        _previousTimestamp = 0.0;
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkUpdate:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)endScrolling {
    if (_scrolling) {
        _scrollSpeed = CGPointZero;
        [_displayLink invalidate];
        _scrolling = NO;
    }
}

- (void)displayLinkUpdate:(CADisplayLink *)sender {
    // Figure out the delta time since the last update, then call the update method with that delta.

    CFTimeInterval currentTime = [_displayLink timestamp];

    CFTimeInterval deltaTime;
    if(_nextDeltaTimeZero) {
        _nextDeltaTimeZero = NO;
        deltaTime = 0;
    } else {
        deltaTime = currentTime - _previousTimestamp;
    }
    _previousTimestamp = currentTime;

    [self updateWithDelta:deltaTime];
}

- (void)updateWithDelta:(CFTimeInterval)deltaTime {

    CGSize contentSize = self.scrollView.contentSize;
    CGRect bounds = self.scrollView.bounds;
    UIEdgeInsets contentInset = self.scrollView.contentInset;

    CGPoint maximumContentOffset = CGPointMake(contentSize.width - bounds.size.width + contentInset.right,
                                               contentSize.height - bounds.size.height + contentInset.bottom);
    CGPoint minimumContentOffset = CGPointMake(-contentInset.left, -contentInset.top);

    CGPoint maximumAmountScrolled = CGPointMake(maximumContentOffset.x - _startContentOffset.x,
                                                maximumContentOffset.y - _startContentOffset.y);
    CGPoint minimumAmountScrolled = CGPointMake(minimumContentOffset.x - _startContentOffset.x,
                                                minimumContentOffset.y - _startContentOffset.y);

    _amountScrolled = CGPointMake((CGFloat)(_amountScrolled.x + _scrollSpeed.x * deltaTime),
                                  (CGFloat)(_amountScrolled.y + _scrollSpeed.y * deltaTime));

    _amountScrolled = CGPointMake(MAX(minimumAmountScrolled.x, MIN(maximumAmountScrolled.x, _amountScrolled.x)),
                                  MAX(minimumAmountScrolled.y, MIN(maximumAmountScrolled.y, _amountScrolled.y)));

    CGFloat offsetX = _startContentOffset.x + _amountScrolled.x;
    CGFloat offsetY = _startContentOffset.y + _amountScrolled.y;
    self.scrollView.contentOffset = CGPointMake(offsetX, offsetY);

    self.state = UIGestureRecognizerStateChanged;

}

#pragma mark - Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSUInteger count = [event touchesForGestureRecognizer:self].count;
    if (count != 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    if (!CGRectContainsPoint(self.frame, location)) {
        [self ignoreTouch:touch forEvent:event];
        return;
    }

    _startLocation = [touch locationInView:nil];
    _startContentOffset = self.scrollView.contentOffset;

    _holding = YES;
    _holdTimer = [NSTimer scheduledTimerWithTimeInterval:self.minimumPressDuration
                                                  target:self
                                                selector:@selector(holdTimerFired:)
                                                userInfo:nil
                                                 repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_holdTimer forMode:NSRunLoopCommonModes];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // Update the total translation since the beginning of the gesture (since starting to handle touches, not since state == began)
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:nil];
    CGPoint translation = CGPointMake(location.x - _startLocation.x, location.y - _startLocation.y);
    _translationInWindow = translation;

    // If we're currently still waiting for minimumPressDuration to elapse, check that we didn't move too much. Fail if we did.
    if (_holding) {
        CGFloat distance = (CGFloat)sqrt(_translationInWindow.x * _translationInWindow.x + _translationInWindow.y * _translationInWindow.y);
        if (distance > self.maximumMovement) {
            [self tearDown];
            self.state = UIGestureRecognizerStateFailed;
        }
    } else {
        // We now waited long enough.
        if (self.state == UIGestureRecognizerStatePossible) {
            // If didn't yet begin the gesture, check if we can now (moved the minimumMovement required) and begin if possible.
            if ([self canBeginGesture]) {
                self.state = UIGestureRecognizerStateBegan;
            }
        } else {
            // This is the main part, that runs during the gesture.
            // First we need to figure out if we're inside the main area (that doesn't auto-scroll) of the scrollView.
            UIEdgeInsets contentInset = self.scrollView.contentInset;
            CGRect frame = self.scrollView.frame;
            CGPoint locationInSuper = [touch locationInView:self.scrollView.superview];
            CGRect insideRect = UIEdgeInsetsInsetRect(frame, contentInset);
            insideRect = UIEdgeInsetsInsetRect(insideRect, _autoScrollInsets);
            BOOL isInside = CGRectContainsPoint(insideRect, locationInSuper);

            if (isInside) {
                // If we're inside, just reset the state to notify the gesture targets about the change in translation.
                [self endScrolling];
                self.state = UIGestureRecognizerStateChanged;
            } else {
                // If we're in the auto-scroll area, update the scrolling speed and make sure we have a displayLink running.
                // The displayLink will take care of scrolling the scrollView and updating the translation.
                CGFloat speedY = 0;
                CGFloat speedX = 0;
                if (_allowVerticalScrolling) {
                    speedY = MIN(0, locationInSuper.y - (frame.origin.y + contentInset.top + _autoScrollInsets.top)) +
                            MAX(0, locationInSuper.y - (frame.origin.y + frame.size.height - contentInset.bottom - _autoScrollInsets.bottom));
                }
                if (_allowHorizontalScrolling) {
                    speedX = MIN(0, locationInSuper.x - (frame.origin.x + contentInset.left + _autoScrollInsets.left)) +
                            MAX(0, locationInSuper.x - (frame.origin.x + frame.size.width - contentInset.right - _autoScrollInsets.right));
                }
                _scrollSpeed = CGPointMake((CGFloat)(speedX * kSpeedMultiplier * 60), (CGFloat)(speedY * kSpeedMultiplier * 60));
                [self beginScrolling];
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self tearDown];
    if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
        self.state = UIGestureRecognizerStateEnded;
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self tearDown];
    if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
        self.state = UIGestureRecognizerStateCancelled;
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (BOOL)shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (otherGestureRecognizer == _scrollView.pinchGestureRecognizer) {
        return YES;
    }
    if (otherGestureRecognizer == _scrollView.panGestureRecognizer) {
        return YES;
    }
    return NO;
}

@end
