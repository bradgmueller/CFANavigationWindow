# CFANavigationWindow
Providing easy navigation options with UIWindows on iOS

`CFANavigationWindow` is a `UIWindow` subclass designed to facilitate some navigation between different core app modes on iOS. 

With `CFANavigationWindow` you can easily:
- Swap the root window for another window
- Push/pop windows on a stack above/beneath each other
- Animate any window transitions

Using different windows can be especially useful when looking to manage different modes of an app (i.e. Signed In / Out), or handle interstitials like a lock screen, mask, tutorial, etc. Isolating the different modes into separate windows adds flexibility and reduces the complications found when attempting to implement the same functionality with something like Modal presentations.

## Replacing the root window

Replacing the root window with a controller in a new window can be useful in certain circumstances, for instance when a user Signs In / Out. Here's an example of how to do so with `CFANavigationWindow`:

```
#import "CFANavigationWindow.h"

...

- (void)setAuthStateChangedToAuthenticated:(BOOL)authenticated animated:(BOOL)animated
{
    UIViewController *controller = authenticated ? [[HomeViewController alloc] init] : [[LoginViewController alloc] init];
    
    WindowAnimator *animator = animated ? [[WindowAnimator alloc] init] : nil;

    [CFANavigationWindow cfa_replaceRootWindowWithController:controller
                                                withAnimator:animator
                                                  completion:nil];
}
```

By replacing the root window with a new controller, the existing root window (including its stack of windows) transitions away, and presented is your new controller in a new `CFANavigationWindow`.

## Managing a stack of windows

With an instance of `CFANavigationWindow` as the app delegate's `window`, other controllers can be presented in a stack managed windows at different z-indicies. This is particularly useful for covering the content of your application with something like a tutorial, mask, loading screen, PIN screen, etc.

Here's an example of pushing/popping controllers onto the window stack, where when the user leaves the app, a PIN code controller appears on top of the app's content:
```
// AppDelegate.m

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self presentController:self.pinController atWindowLevel:CFANavigationWindowLevelMedium animated:NO];
}

- (void)userEnteredPin:(NSNotification *)notification
{
    [self dismissController:_pinController fromWindowLevel:CFANavigationWindowLevelMedium animated:YES];
}

- (void)dismissController:(UIViewController *)controller fromWindowLevel:(CFANavigationWindowLevel)level animated:(BOOL)animated
{
    CFANavigationWindow *navWindow = [CFANavigationWindow currentNavigationWindow];
    WindowAnimator *animator = animated ? [[WindowAnimator alloc] init] : nil;
    [navWindow popController:controller withAnimator:animator completion:nil];
}

- (void)presentController:(UIViewController *)controller atWindowLevel:(CFANavigationWindowLevel)level animated:(BOOL)animated
{
    CFANavigationWindow *navWindow = [CFANavigationWindow currentNavigationWindow];
    WindowAnimator *animator = animated ? [[WindowAnimator alloc] init] : nil;
    [navWindow pushController:controller atWindowLevel:level withAnimator:animator completion:nil];
}
```

Pushing and popping new windows onto the stack is done at a discrete window level, to ensure that each controller is always shown at its proper priority in the stack. Although it’s designed to have at most 3 windows in the stack, you’re welcome to modify it for more.

## Animating transitions

Each window transition has the option to include an animator, an object that conforms to `<CFAWindowAnimator>`. 
If provided, the object will be called to perform any animations for the transition, unless:
- the application state is not "active"
- the top-most visible window before the tansition will be the same after the transition (i.e., a window exists at `CFANavigationWindowLevelMedium` and the transition is popping the window at `CFANavigationWindowLevelLow`)

The animator is provided the transition's context, in the form of a `CFAWindowAnimationContext` object. This includes all necessary information, including the type of transition (push, pop, replace), and the windows involved in the transition (from/to windows, top/underlying windows). 
When the animator is finished, it must call `animationFinished()` on the context. This allows `CFANavigationWindow` to properly clean up. Any windows staying on-screen will have their frames, alphas, transforms, etc. properly reset, and any windows dismissed will be deallocated.

Here's some example code of a window animator:

```
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
        // Animation block...
    }
    else if (type == CFAWindowTransitionTypePop)
    {
        // Animation block...
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
```

## Considerations

If your application already manages multiple windows, `CFANavigationWindow` may affect their operation. By default, `CFANavigationWindow` will address all members of `UIWindow` (but not any subclasses) when performing transitions and assigning the new `keyWindow`, but you can set `ignoreNonManagedWindows` to YES to ignore other existing windows.
