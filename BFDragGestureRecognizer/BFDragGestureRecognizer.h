//
// Created by Balázs Faludi on 21.10.14.
// Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BFDragGestureRecognizer : UIGestureRecognizer

/// The minimum required duration the user has to press down on the view to start the gesture.
/// For example, the user has to press down on an app icon for a short time, before the drag gesture is started.
/// The default value is 0.5 seconds, the same as for UILongPressGestureRecognizer.
@property (nonatomic) NSTimeInterval minimumPressDuration;

/// The required distance in points the user has to move his finger to start the drag gesture.
/// The default value is 0 points.
@property (nonatomic) CGFloat minimumMovement;

/// The maximum distance in points the user is allowed to move his finger while pressing down on the view (before the gesture is started).
/// After the minimumPressDuration elapsed, this value has no significance.
/// The default value is 10 points, the same as for UILongPressGestureRecognizer.
@property (nonatomic) CGFloat maximumMovement;

/// A rectangle in the gesture recognizer's view's coordinate system. Touches outside of this frame will be ignored.
/// This is a quick way to limit the draggable part to a certain area of the view, without adding subviews, subclassing or delegate methods.
/// The default value is the bounds of the gesture recognizer's view, i.e. the entire view.
@property (nonatomic) CGRect frame;

/// The scroll view that should be auto-scrolled by the gesture the finger is moved to the edges of the scroll view.
/// By default, this will automatically be set to the nearest ancestor (of the gesture's view) in the view hierarchy that is a scroll view.
/// If the gesture's view is not directly embedded in the scroll view you want to auto-scroll, you can set the scroll view here.
@property (nonatomic) UIScrollView *scrollView;

/// Determines whether auto-scrolling the scrollView in vertical direction is enables.
/// The default value is YES.
@property (nonatomic) BOOL allowVerticalScrolling;

/// Determines whether auto-scrolling the scrollView in horizontal direction is enables.
/// The default value is YES.
@property (nonatomic) BOOL allowHorizontalScrolling;

/// The autoScrollInsets define how close to the scrollView's edges auto-scrolling will be started.
/// These insets are added to the scrollView's contentInsets.
/// The default values are {44, 44, 44, 44}, the height of a standard toolbar.
@property (nonatomic) UIEdgeInsets autoScrollInsets;

/// The translation of the drag gesture in the coordinate system of the specified view. Similar to UIPanGestureRecognizer's method.
- (CGPoint)translationInView:(UIView *)view;

@end