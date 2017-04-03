//
//  CFANavigationWindow.h
//  CFANavigationWindow Demo
//
//  Created by Bradley Mueller on 3/15/17.
//

#import <UIKit/UIKit.h>
#import "UIWindow+CFA.h"
#import "CFAWindowAnimationContext.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, CFANavigationWindowLevel) {
    CFANavigationWindowLevelLow = 1,
    CFANavigationWindowLevelMedium,
    CFANavigationWindowLevelHigh
};

@class CFAWindowAnimationContext;

@protocol CFAWindowAnimator <NSObject>

- (void)animateWindowTransition:(nullable CFAWindowAnimationContext *)context;

@end

@interface CFANavigationWindow : UIWindow

/** 
 Returns the current application delegate's window, if it is a @p CFANavigationWindow
 */
+ (nullable CFANavigationWindow *)currentNavigationWindow;

/**
 Defaults to NO. When NO, any members of UIWindow not directly managed by the receiver will still be included in transition logic. When YES, the receiver will only consider those windows under its control.
 */
@property (nonatomic) BOOL ignoreNonManagedWindows;

/** 
 An array of view controllers currently being managed by the receiver - includes the receiver's @p rootViewController. Ordered by window level.
 */
@property (nonatomic, readonly) NSArray <UIViewController *> *viewControllers;

/** 
 Returns the controller at the specified @p level, if one exists.
 */
- (nullable UIViewController *)controllerAtLevel:(CFANavigationWindowLevel)level;

/**
 Create, present, and return a new @p UIWindow to be managed by the receiver

 @param controller The new window's @p rootViewController
 @param level The new window's position in the z-coordinate space
 @param animator Optional animator - will be ignored if the top-visible window will not change, or if the application is not active
 @param completion Optional completion block
 @return The new window
 */
- (nullable UIWindow *)pushController:(UIViewController *)controller
                        atWindowLevel:(CFANavigationWindowLevel)level
                         withAnimator:(nullable id <CFAWindowAnimator>)animator
                           completion:(nullable void(^)())completion;

/**
 Pop the controller and its window from the receiver's window hierarchy

 @param controller The controller whose window will dismiss
 @param animator Optional animator - will be ignored if the top-visible window will not change, or if the application is not active
 @param completion Optional completion block
 @return A boolean for success
 */
- (BOOL)popController:(UIViewController *)controller
         withAnimator:(id<CFAWindowAnimator>)animator
           completion:(nullable void(^)())completion;

/**
 Pop all of the receiver's managed windows from the hierarchy.

 @param animator Optional animator - will be ignored if the application is not active
 @param completion Optional completion block
 @return The popped controllers
 */
- (nullable NSArray <UIViewController *> *)popAllControllersWithAnimator:(id<CFAWindowAnimator>)animator
                                                              completion:(nullable void(^)())completion;

@end

NS_ASSUME_NONNULL_END
