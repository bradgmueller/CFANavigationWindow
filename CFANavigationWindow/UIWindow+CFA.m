//
//  UIWindow+CFA.m
//  OnBoard
//
//  Created by Bradley Mueller on 3/28/16.
//

#import "UIWindow+CFA_Private.h"
#import "CFANavigationWindow_Private.h"
#import "CFAWindowAnimationContext.h"
@import ObjectiveC;

/**
 A single window instance to act as the canary for the application's frame. This sits behind all other windows and is invisible.
 */
@interface CFAInvisibleWindow : UIWindow
@end

@interface CFAInvisibleWindowController : UIViewController
@end

@implementation CFAInvisibleWindow

+ (instancetype)sharedInvisibleWindow
{
    static CFAInvisibleWindow *__invisibleWindow = nil;
    if (__invisibleWindow == nil && [[[UIApplication sharedApplication] delegate] window] != nil)
    {
        __invisibleWindow = [[CFAInvisibleWindow alloc] initWithFrame:[[[UIApplication sharedApplication] delegate] window].bounds];
        __invisibleWindow.windowLevel = UIWindowLevelNormal - 1;
        __invisibleWindow.userInteractionEnabled = NO;
        __invisibleWindow.backgroundColor = [UIColor clearColor];
        __invisibleWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        __invisibleWindow.hidden = NO;
        CFAInvisibleWindowController *vc = [[CFAInvisibleWindowController alloc] init];
        vc.view.backgroundColor = [UIColor clearColor];
        vc.view.userInteractionEnabled = NO;
        __invisibleWindow.rootViewController = vc;
    }
    return __invisibleWindow;
}

@end

@implementation CFAInvisibleWindowController

- (UIViewController *)mainController
{
    UIWindow *mainAppWindow = [[UIApplication sharedApplication] keyWindow];
    UIViewController *topController = mainAppWindow.rootViewController;
    
    while(topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [[self mainController] shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    return [[self mainController] shouldAutorotate];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self mainController] preferredInterfaceOrientationForPresentation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [[self mainController] supportedInterfaceOrientations];
}

@end

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark -

@implementation UIWindow (CFA)

#pragma mark - Setters/getters

- (void)setCfa_navigationLevel:(CFANavigationWindowLevel)cfa_navigationLevel
{
    objc_setAssociatedObject(self, @selector(cfa_navigationLevel), @(cfa_navigationLevel), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CFANavigationWindowLevel)cfa_navigationLevel
{
    return [objc_getAssociatedObject(self, @selector(cfa_navigationLevel)) integerValue];
}

- (void)setCfa_navigationWindow:(CFANavigationWindow *)cfa_navigationWindow
{
    objc_setAssociatedObject(self, @selector(cfa_navigationWindow), cfa_navigationWindow, OBJC_ASSOCIATION_ASSIGN);
}

- (CFANavigationWindow *)cfa_navigationWindow
{
    return objc_getAssociatedObject(self, @selector(cfa_navigationWindow));
}

#pragma mark - Internal

- (void)cfa_destroy
{
    if (self.rootViewController.presentedViewController != nil)
    {
        [self.rootViewController dismissViewControllerAnimated:NO completion:nil];
    }
    
    self.rootViewController = nil;
    self.hidden = YES;
}

- (void)cfa_showInScreen
{
    self.alpha = 1;
    self.hidden = NO;
    self.transform = CGAffineTransformIdentity;
    self.frame = [CFAInvisibleWindow sharedInvisibleWindow].bounds;
}

#pragma mark - Switching root windows

+ (void)prepareInvisibleWindowIfNeeded
{
    [CFAInvisibleWindow sharedInvisibleWindow];
}

+ (CFANavigationWindow *)cfa_replaceRootWindowWithController:(UIViewController *)controller
                                                withAnimator:(id <CFAWindowAnimator>)animator
                                                  completion:(nullable void (^)())completion
{
    NSParameterAssert(controller);
    
    [self prepareInvisibleWindowIfNeeded];
    
    UIWindow *rootWindow = [[[UIApplication sharedApplication] delegate] window];
    
    UIWindow *visibleDismissingWindow = rootWindow;
    NSMutableArray *hiddenDismissingWindows = [[NSMutableArray alloc] init];
    
    if ([visibleDismissingWindow isKindOfClass:[CFANavigationWindow class]])
    {
        NSArray *navWindows = [(CFANavigationWindow *)visibleDismissingWindow windows];
        visibleDismissingWindow = navWindows.lastObject;
        hiddenDismissingWindows = [navWindows mutableCopy];
        [hiddenDismissingWindows removeObject:visibleDismissingWindow];
    }
    
    CFANavigationWindow *newWindow = [[CFANavigationWindow alloc] initWithFrame:rootWindow.bounds];
    newWindow.windowLevel = rootWindow.windowLevel;
    newWindow.tintColor = rootWindow.tintColor;
    newWindow.backgroundColor = rootWindow.backgroundColor;
    newWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    newWindow.rootViewController = controller;
    
    [[[UIApplication sharedApplication] delegate] setWindow:newWindow];
    
    newWindow.alpha = 0;
    newWindow.hidden = NO;
    
    UIWindow *visiblePresentingWindow = [[newWindow windows] lastObject];
    NSMutableArray *hiddenPresentingWindows = [[newWindow windows] mutableCopy];
    [hiddenPresentingWindows removeObject:visiblePresentingWindow];
    
    CFAWindowAnimationContext *context = [[CFAWindowAnimationContext alloc] init];
    context.topToWindow = visiblePresentingWindow;
    context.topFromWindow = visibleDismissingWindow;
    context.underlyingToWindows = hiddenPresentingWindows;
    context.underlyingFromWindows = hiddenDismissingWindows;
    context.type = CFAWindowTransitionTypeRoot;
    context.animationFinished = ^() {
        
        for (UIWindow *window in hiddenDismissingWindows)
        {
            [window cfa_destroy];
        }
        [visibleDismissingWindow cfa_destroy];
        
        for (UIWindow *window in hiddenPresentingWindows)
        {
            [window cfa_showInScreen];
        }
        [visiblePresentingWindow cfa_showInScreen];
        [visiblePresentingWindow makeKeyAndVisible];
        
        if (completion != nil)
        {
            completion();
        }
    };
    
    if (animator != nil && [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        [animator animateWindowTransition:context];
    }
    else
    {
        context.animationFinished();
    }
    
    return newWindow;
}

@end

