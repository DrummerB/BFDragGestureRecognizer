//
//  ViewController.m
//  Dashboard
//
//  Created by Steve Smith on 5/8/15.
//  Copyright (c) 2015 Steve Smith. All rights reserved.
//

#import "ViewController.h"
#import "CardViewController.h"
#import <BFDragGestureRecognizer/BFDragGestureRecognizer.h>

@interface ViewController () {
  NSMutableArray *_cardViewControllers;
  NSMutableArray *_cardViews;
  CGPoint _startCenter;
  CGPoint _draggingCenter;
}

@property (weak, nonatomic) IBOutlet UIScrollView *svScrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)loadView {
  [super loadView];

  CGFloat cardHeight = 300.0;
  CGFloat cardPadding = 30.0;

  _cardViews = [[NSMutableArray alloc] init];
  _cardViewControllers = [[NSMutableArray alloc] init];
  int yPos = 0;
  for (int i =0; i < 5; i++){
    CardViewController *card = [[self storyboard] instantiateViewControllerWithIdentifier:@"CardViewController"];
    [card setCardNumber:i];
    CGRect cardFrame = CGRectMake(0, yPos, [_svScrollView frame].size.width, cardHeight);
    [[card view] setFrame:cardFrame];
    if (i > 0){
      BFDragGestureRecognizer *holdDragRecognizer = [[BFDragGestureRecognizer alloc] init];
      [holdDragRecognizer setAllowHorizontalScrolling:NO];
      [holdDragRecognizer addTarget:self action:@selector(dragRecognized:)];
      [holdDragRecognizer setFrame:[[card lblLabel] frame]];
      [[card view] addGestureRecognizer:holdDragRecognizer];
      [[card view] setMoveable:YES];
    }else{
      [[card view] setMoveable:NO];
    }
    [_contentView addSubview:[card view]];
    yPos += (cardHeight + cardPadding);
    [_cardViews addObject:[card view]];
    [_cardViewControllers addObject:card];
  }
  [_svScrollView setContentSize:CGSizeMake([[self view] frame].size.width, [_cardViews count] * (cardHeight + cardPadding))];
  [_svScrollView setFrame:[[self view] frame]];
  [_contentView setFrame:CGRectMake(0, 0, [[self view] frame].size.width, [_cardViews count] * (cardHeight + cardPadding))];
}

- (void)dragRecognized:(BFDragGestureRecognizer *)recognizer {
  UIView *draggingView = recognizer.view;
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    // When the gesture starts, remember the current position, and animate the it.
    _startCenter = draggingView.center;
    _draggingCenter = _startCenter;
    [draggingView.superview bringSubviewToFront:draggingView];
    [UIView animateWithDuration:0.2 animations:^{
      draggingView.transform = CGAffineTransformMakeScale(1.1, 1.1);
      draggingView.alpha = 0.7;
    }];
  } else if (recognizer.state == UIGestureRecognizerStateChanged) {
    // During the gesture, we just add the gesture's translation to the saved original position.
    // The translation will account for the changes in contentOffset caused by auto-scrolling.
    CGPoint translation = [recognizer translationInView:_contentView];
//    CGPoint center = CGPointMake(_startCenter.x + translation.x, _startCenter.y + translation.y);
    CGPoint center = CGPointMake(_startCenter.x, _startCenter.y + translation.y);
    draggingView.center = center;
    [draggingView.superview bringSubviewToFront:draggingView];
    NSArray *dropZones = [self potentialDropZonesForView:draggingView];
    for (UIView *drop in dropZones){
      CGRect dropable = [self dropZoneForView:drop];
      if (CGRectIntersectsRect([draggingView frame], dropable)){
        CGPoint origDropCenter = drop.center;
        [UIView animateWithDuration:0.3 animations:^{
          drop.center = _draggingCenter;
        } completion:^(BOOL finished) {
          NSInteger dragIndex = [_cardViews indexOfObject:draggingView];
          NSInteger dropIndex = [_cardViews indexOfObject:drop];
          [_cardViews exchangeObjectAtIndex:dragIndex withObjectAtIndex:dropIndex];
          _draggingCenter = origDropCenter;
        }];
      }
    }
  } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
    [UIView animateWithDuration:0.2 animations:^{
      draggingView.transform = CGAffineTransformIdentity;
      draggingView.alpha = 1.0;
      draggingView.center = _draggingCenter;
    }];
  } else if (recognizer.state == UIGestureRecognizerStateFailed) {

  }
}

- (NSArray *)potentialDropZonesForView:(UIView *)draggingView {
  NSMutableArray *dropZones = [[NSMutableArray alloc] init];
  NSInteger index = [_cardViews indexOfObject:draggingView];
  if (index == 0){
    UIView *view = [_cardViews objectAtIndex:1];
    [dropZones addObject:view];
  }else if (index == [_cardViews count] - 1){
    UIView *view = [_cardViews objectAtIndex:(index - 1)];
    [dropZones addObject:view];
  }else{
    UIView *view1 = [_cardViews objectAtIndex:(index - 1)];
    UIView *view2 = [_cardViews objectAtIndex:(index + 1)];
    if ([view1 isMoveable]){
      [dropZones addObject:view1];
    }
    if ([view2 isMoveable]){
      [dropZones addObject:view2];
    }
  }
  return dropZones;
}

- (CGRect)dropZoneForView:(UIView *)view {
  CGRect dropZoneRect;
  CGRect currentFrame = [view frame];
  dropZoneRect = CGRectMake(currentFrame.origin.x, view.center.y, currentFrame.size.width, 1.0);
  return dropZoneRect;
}

@end
