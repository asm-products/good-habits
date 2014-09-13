MVModalTransitions
=======================================================

This is a light-weight library to present custom view controllers on iPad and iPhone without recurring to the UIModalPresentationFormSheet and UIModalPresentationPageSheet presentation styles (which are only available on iPad).

With iOS 7, Apple introduced the new View Controller Transitioning APIs. These are used by the MVModalTransition and MVPopupTransition classes to present non-fullscreen interface-rotation friendly modal view controllers.
The MVModalTransition class can be used as a base class to implement custom transitions and provides support for adding a semi-transparent full-screen background view.

This sample project comes with a custom modal picker view that illustrates how to use this.

Usage
-------------------------------------------------------

<pre>
/* -- Presented view controller code -- */
@interface MVCustomAlertView ()<UIViewControllerTransitioningDelegate>
@property(strong, nonatomic) MVPopupTransition *animator;
@end

@implementation MVCustomAlertView

- (id)init {

    if ((self = [super init])) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
        self.animator = [MVPopupTransition createWithSize:CGSizeMake(300, 300) dimBackground:YES shouldDismissOnBackgroundViewTap:NO delegate:nil];
    }
    return self;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self.animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.animator;
}
@end


/* -- Presenting view controller code -- */
@implementation PresentingViewController

// Handler
- (void)buttonPressed {

  MVCustomAlertView *vc = [MyViewController new];
  [self presentViewController:vc animated:YES completion:nil];  
}
</pre>

Installation
-------------------------------------------------------

This example uses Masonry on top of Auto-Layout. The corresponding pod needs to be installed before the project can be built.

<pre>
pod install
</pre>

In order to use MVModalTransitions in a new project, add the following line to the project *-Prefix.pch file:

<pre>
#define MAS_SHORTHAND
</pre>

Scope
-------------------------------------------------------
The custom popup transition can be used to present modal view controllers as long as:
- their size doesn't change with interface rotation
- their width and height do not exceed the smallest of the screen dimensions

Preview
-------------------------------------------------------

![Modal View Controllers Preview](https://github.com/bizz84/MVModalTransitions/raw/master/Screenshots/ModalPortrait.png "Modal View Controllers Preview")

License
-------------------------------------------------------
Copyright (c) 2014 Andrea Bizzotto bizz84@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
