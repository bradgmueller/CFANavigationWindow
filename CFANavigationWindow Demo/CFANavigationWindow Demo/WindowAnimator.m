//
//  WindowAnimator.m
//  CFANavigationWindow Demo
//
//  Created by Bradley Mueller on 3/15/17.
//

#import "WindowAnimator.h"

@implementation WindowAnimator

#pragma mark - CFAWindowAnimator

- (void)animateWindowTransition:(CFAWindowAnimationContext *)context
{
    UIWindow *fromWindow = context.topFromWindow;
    UIWindow *toWindow = context.topToWindow;
    
    CFAWindowTransitionType type = context.type;
    
    /* 
     Hide all underlying windows, so they do not show behind the primary "from" & "to" windows
     Un-hiding them is not necessary - all windows are properly reset upon calling `animationFinished()`
     */
    
    for (UIWindow *window in context.underlyingFromWindows)
    {
        window.hidden = YES;
    }
    
    for (UIWindow *window in context.underlyingToWindows)
    {
        window.hidden = YES;
    }
    
    /* 
     Animate out the "from" window, and in the "to" window. 
     Always call `animationFinished()` when done
     */
    
    if (type == CFAWindowTransitionTypePush)
    {
        CGRect bounds = fromWindow.bounds;
        
        toWindow.frame = CGRectOffset(bounds, 0, bounds.size.height);
        toWindow.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
        
        [UIView animateWithDuration:1.0
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             
                             toWindow.transform = CGAffineTransformIdentity;
                             toWindow.alpha = 1;
                             toWindow.frame = bounds;
                             
                             fromWindow.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
                         }
                         completion:^(BOOL finished) {
                             
                             context.animationFinished();
                         }];
    }
    else if (type == CFAWindowTransitionTypePop)
    {
        CGRect bounds = fromWindow.bounds;
        
        toWindow.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
        
        [UIView animateWithDuration:1.0
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             
                             fromWindow.frame = CGRectOffset(bounds, 0, bounds.size.height);
                             fromWindow.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
                             fromWindow.alpha = 0;
                             
                             toWindow.transform = CGAffineTransformIdentity;
                             toWindow.alpha = 1;
                             toWindow.frame = bounds;
                         }
                         completion:^(BOOL finished) {
                             
                             context.animationFinished();
                         }];
    }
    else if (type == CFAWindowTransitionTypeRoot)
    {
        CGRect bounds = fromWindow.bounds;
        
        toWindow.frame = CGRectOffset(bounds, bounds.size.width, 0);
        toWindow.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
        toWindow.alpha = 0;
        toWindow.hidden = NO;
        
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             
                             toWindow.transform = CGAffineTransformIdentity;
                             toWindow.alpha = 1;
                             toWindow.frame = bounds;
                             
                             fromWindow.frame = CGRectOffset(bounds, -bounds.size.width, 0);
                             fromWindow.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
                             fromWindow.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             
                             context.animationFinished();
                         }];
    }
}

@end
