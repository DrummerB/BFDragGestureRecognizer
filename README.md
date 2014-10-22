# BFDragGestureRecognizer

![image](http://i.imgur.com/lfkzvgY.gif)


Summary
-------

BFDragGestureRecognizer is a UIGestureRecognizer subclass that can be used to drag views inside a scroll view with automatic scrolling at the edges of the scroll view.

Instructions
------------

Create a Podfile, if you don't have one already. Add the following line.

    pod 'BFDragGestureRecognizer'
    
Run the following command.

    pod install
    
Alternatively, you can just drop the `BFDragGestureRecognizer.{h,m}` files into your project.

Add the gesture recognizer to the view(s) you want to drag:

	BFDragGestureRecognizer *dragRecognizer = [[BFDragGestureRecognizer alloc] init];
    [dragRecognizer addTarget:self action:@selector(dragRecognized:)];
    [view addGestureRecognizer:dragRecognizer];
    
Implement the gesture handler method. This is very similar to what you would do using a standard UIPanGestureRecognizer:

	- (void)dragRecognized:(BFDragGestureRecognizer *)recognizer {
	    UIView *view = recognizer.view;
	    if (recognizer.state == UIGestureRecognizerStateBegan) {
	        // When the gesture starts, remember the current position.
	        _startCenter = view.center;
	    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
	        // During the gesture, we just add the gesture's translation to the saved original position.
	        // The translation will account for the changes in contentOffset caused by auto-scrolling.
	        CGPoint translation = [recognizer translationInView:_contentView];
	        CGPoint center = CGPointMake(_startCenter.x + translation.x, 
	        							 _startCenter.y + translation.y);
	        view.center = center;
	    } 
	}
    


License
-------

[New BSD License](http://en.wikipedia.org/wiki/BSD_licenses). For the full license text, see [here](https://raw.github.com/DrummerB/BFDragGestureRecognizer/master/LICENSE).
