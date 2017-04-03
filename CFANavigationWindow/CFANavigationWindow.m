//
//  CFANavigationWindow.m
//  CFANavigationWindow Demo
//
//  Created by Bradley Mueller on 3/15/17.
//

#import "CFANavigationWindow_Private.h"
#import "UIWindow+CFA_Private.h"
#import "CFAWindowAnimationContext.h"

#ifdef DEBUG
#define NSDebug(__FORMAT__, ...) NSLog(__FORMAT__, ##__VA_ARGS__)
#else
#define NSDebug(__FORMAT__, ...)
#endif

@implementation CFANavigationWindow

+ (CFANavigationWindow *)currentNavigationWindow
{
    UIWindow *rootWindow = [[[UIApplication sharedApplication] delegate] window];
    if ([rootWindow isKindOfClass:[CFANavigationWindow class]])
    {
        return (CFANavigationWindow *)rootWindow;
    }
    return nil;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [UIWindow prepareInvisibleWindowIfNeeded];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [UIWindow prepareInvisibleWindowIfNeeded];
    }
    return self;
}

- (NSString *)description
{
    NSString *(^classString)(UIViewController *) = ^NSString *(UIViewController *vc) {
        return vc != nil ? NSStringFromClass(vc.class) : @"(none)";
    };
    
    NSString *description = [super description];
    description = [description stringByAppendingFormat:@"\n0. %@\n1. %@\n2. %@\n3. %@",
                   classString(self.rootViewController),
                   classString([self controllerAtLevel:CFANavigationWindowLevelLow]),
                   classString([self controllerAtLevel:CFANavigationWindowLevelMedium]),
                   classString([self controllerAtLevel:CFANavigationWindowLevelHigh])
                   ];
    return description;
}

#pragma mark - Setters/getters

- (nullable UIWindow *)windowAtLevel:(CFANavigationWindowLevel)level
{
    UIWindow *existingWindow = nil;
    switch (level) {
        case CFANavigationWindowLevelLow:
            existingWindow = self.lowWindow;
            break;
        case CFANavigationWindowLevelMedium:
            existingWindow = self.mediumWindow;
            break;
        case CFANavigationWindowLevelHigh:
            existingWindow = self.highWindow;
            break;
    }
    return existingWindow;
}

- (void)setWindow:(UIWindow *)window atLevel:(CFANavigationWindowLevel)level
{
    window.cfa_navigationWindow = self;
    window.cfa_navigationLevel = level;
    
    switch (level) {
        case CFANavigationWindowLevelLow:
            self.lowWindow = window;
            break;
        case CFANavigationWindowLevelMedium:
            self.mediumWindow = window;
            break;
        case CFANavigationWindowLevelHigh:
            self.highWindow = window;
            break;
    }
}

- (void)removeWindow:(UIWindow *)window
{
    window.cfa_navigationWindow = nil;
    
    [self setWindow:nil atLevel:window.cfa_navigationLevel];
    
    window.cfa_navigationLevel = 0;
    
    [window cfa_destroy];
}

#pragma mark - Readonly

- (NSArray<UIViewController *> *)viewControllers
{
    return [self.windows valueForKey:@"rootViewController"];
}

- (UIViewController *)controllerAtLevel:(CFANavigationWindowLevel)level
{
    return [self windowAtLevel:level].rootViewController;
}

- (NSArray<UIWindow *> *)windows
{
    NSMutableArray *mutable = [[NSMutableArray alloc] init];
    
    [mutable addObject:self];
    
    if (self.lowWindow != nil)
    {
        [mutable addObject:self.lowWindow];
    }
    
    if (self.mediumWindow != nil)
    {
        [mutable addObject:self.mediumWindow];
    }
    
    if (self.highWindow != nil)
    {
        [mutable addObject:self.highWindow];
    }
    
    return mutable;
}

- (NSArray <UIWindow *> *)otherEligibleAppWindows
{
    if (self.ignoreNonManagedWindows == YES)
    {
        return @[];
    }
    
    NSArray *managedWindows = self.windows;
    NSArray *appWindows = [[UIApplication sharedApplication] windows];
    NSMutableArray *mutable = [[NSMutableArray alloc] init];
    
    for (UIWindow *window in appWindows)
    {
        if ([window isMemberOfClass:[UIWindow class]] && [managedWindows containsObject:window] == NO)
        {
            [mutable addObject:window];
        }
    }
    return [NSArray arrayWithArray:mutable];
}

#pragma mark - Pushing

- (UIWindow *)pushController:(UIViewController *)controller
               atWindowLevel:(CFANavigationWindowLevel)level
                withAnimator:(id<CFAWindowAnimator>)animator
                  completion:(nullable void (^)())completion
{
    UIWindow *existingWindow = [self windowAtLevel:level];
    if (existingWindow != nil)
    {
        NSAssert(NO, @"CFANavigationWindow Error - Cannot push window at level %ld when existing window exists: %@", (long)level, existingWindow);
        
        if (completion != nil)
        {
            completion();
        }
        return nil;
    }
    
    [UIWindow prepareInvisibleWindowIfNeeded];
    
    UIWindow *fromWindow = [self.windows lastObject];
    
    NSMutableArray *underlyingFromWindows = [self.windows mutableCopy];
    [underlyingFromWindows removeObject:fromWindow];
    
    UIWindow *newWindow = [[UIWindow alloc] initWithFrame:self.bounds];
    newWindow.windowLevel = self.windowLevel + (float)level * 0.1;
    newWindow.tintColor = self.tintColor;
    newWindow.backgroundColor = self.backgroundColor;
    newWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    newWindow.rootViewController = controller;
    newWindow.alpha = 0;
    newWindow.hidden = NO;
    
    [self setWindow:newWindow atLevel:level];
    
    UIWindow *toWindow = ^{
        
        UIWindow *myTopWindow = [self.windows lastObject];
        UIWindow *appTopWindow = [self otherEligibleAppWindows].lastObject;
        if (appTopWindow == nil) {
            return myTopWindow;
        }
        return (myTopWindow.windowLevel > appTopWindow.windowLevel) ? myTopWindow : appTopWindow;
    }();
    
    __weak typeof(self) weakSelf = self;
    
    CFAWindowAnimationContext *context = [[CFAWindowAnimationContext alloc] init];
    context.topToWindow = toWindow;
    context.topFromWindow = fromWindow;
    context.underlyingToWindows = nil;
    context.underlyingFromWindows = underlyingFromWindows;
    context.type = CFAWindowTransitionTypePush;
    context.animationFinished = ^() {
        
        for (UIWindow *window in weakSelf.windows)
        {
            [window cfa_showInScreen];
        }
        
        [toWindow makeKeyAndVisible];
        
        if (completion != nil)
        {
            completion();
        }
    };
    
    if (animator != nil && fromWindow != toWindow && [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        [animator animateWindowTransition:context];
    }
    else
    {
        context.animationFinished();
    }
    
    return newWindow;
}

#pragma mark - Popping

- (BOOL)popController:(UIViewController *)controller withAnimator:(id<CFAWindowAnimator>)animator completion:(nullable void (^)())completion
{
    if ([self.windows count] <= 1)
    {
        NSDebug(@"CFANavigationWindow warning - No windows to pop!");
        
        if (completion != nil)
        {
            completion();
        }
        return NO;
    }
    
    [UIWindow prepareInvisibleWindowIfNeeded];
    
    NSMutableArray *subWindows = [[self windows] mutableCopy];
    [subWindows removeObject:self];
    
    UIWindow *windowToRemove = nil;
    
    for (UIWindow *window in subWindows)
    {
        if (window.rootViewController == controller)
        {
            windowToRemove = window;
            break;
        }
    }
    
    if (windowToRemove == nil)
    {
        NSDebug(@"CFANavigationWindow warning - cannot pop controller, not part of the window's hierarchy! Controller: %@", controller);
        
        if (completion != nil)
        {
            completion();
        }
        return NO;
    }
    
    UIWindow *visibleDismissingWindow = self.windows.lastObject;
    
    UIWindow *visiblePresentingWindow = ^{
        
        NSMutableArray *newWindows = [[self windows] mutableCopy];
        [newWindows removeObject:windowToRemove];
        UIWindow *myNewTop = newWindows.lastObject;
        
        UIWindow *appNewTop = [self otherEligibleAppWindows].lastObject;
        if (appNewTop == nil) {
            return myNewTop;
        }
        return myNewTop.windowLevel > appNewTop.windowLevel ? myNewTop : appNewTop;
    }();
    
    NSMutableArray *hiddenPresentingWindows = [self.windows mutableCopy];
    [hiddenPresentingWindows removeObject:visiblePresentingWindow];
    [hiddenPresentingWindows removeObject:visibleDismissingWindow];
    
    __weak typeof(self) weakSelf = self;
    
    CFAWindowAnimationContext *context = [[CFAWindowAnimationContext alloc] init];
    context.topToWindow = visiblePresentingWindow;
    context.topFromWindow = visibleDismissingWindow;
    context.underlyingToWindows = hiddenPresentingWindows;
    context.underlyingFromWindows = nil;
    context.type = CFAWindowTransitionTypePop;
    context.animationFinished = ^() {
        
        [weakSelf removeWindow:windowToRemove];
        
        for (UIWindow *window in weakSelf.windows)
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
    
    if (animator != nil && visiblePresentingWindow != visibleDismissingWindow && [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        [animator animateWindowTransition:context];
    }
    else
    {
        context.animationFinished();
    }
    
    return YES;
}

- (NSArray <UIWindow *> *)popAllControllersWithAnimator:(id<CFAWindowAnimator>)animator completion:(nullable void (^)())completion
{
    if ([self.windows count] <= 1)
    {
        NSDebug(@"CFANavigationWindow warning - No windows to pop!");
        
        if (completion != nil)
        {
            completion();
        }
        return nil;
    }
    
    [UIWindow prepareInvisibleWindowIfNeeded];
    
    UIWindow *visibleDismissingWindow = self.windows.lastObject;
    
    UIWindow *visiblePresentingWindow = ^{
        
        UIWindow *myNewTop = self;
        UIWindow *appNewTop = [self otherEligibleAppWindows].lastObject;
        if (appNewTop == nil) {
            return myNewTop;
        }
        return myNewTop.windowLevel > appNewTop.windowLevel ? myNewTop : appNewTop;
    }();
    
    NSMutableArray *hiddenDismissingWindows = [self.windows mutableCopy];
    [hiddenDismissingWindows removeObject:visiblePresentingWindow];
    [hiddenDismissingWindows removeObject:visibleDismissingWindow];
    
    NSArray *dismissingControllers = [[[NSArray arrayWithArray:hiddenDismissingWindows] arrayByAddingObject:visibleDismissingWindow] valueForKey:@"rootViewController"];
    
    __weak typeof(self) weakSelf = self;
    
    CFAWindowAnimationContext *context = [[CFAWindowAnimationContext alloc] init];
    context.topToWindow = visiblePresentingWindow;
    context.topFromWindow = visibleDismissingWindow;
    context.underlyingToWindows = nil;
    context.underlyingFromWindows = hiddenDismissingWindows;
    context.type = CFAWindowTransitionTypePop;
    context.animationFinished = ^() {
        
        for (UIWindow *window in hiddenDismissingWindows)
        {
            [weakSelf removeWindow:window];
        }
        [weakSelf removeWindow:visibleDismissingWindow];
        
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
    
    return dismissingControllers;
}

@end
