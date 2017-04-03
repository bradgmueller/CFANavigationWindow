//
//  UIWindow+CFA.h
//  OnBoard
//
//  Created by Bradley Mueller on 3/28/16.
//

#import <UIKit/UIKit.h>

@class CFANavigationWindow;
@protocol CFAWindowAnimator;

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (CFA)

/**
 Replace the current application key window (and all managed windows if applicable) with an instance of @p CFANavigationWindow

 @param controller The controller to assign as the new window's @p rootViewController
 @param animator Optional animator - will be ignored if the application is not active
 @param completion Optional completion block
 @return The newly created @p CFANavigationWindow, which is now the app delegate's window
 */
+ (CFANavigationWindow *)cfa_replaceRootWindowWithController:(UIViewController *)controller
                                                withAnimator:(nullable id <CFAWindowAnimator>)animator
                                                  completion:(nullable void(^)())completion;

/** 
 The navigation window presenting the receiver - @p nil if the receiver is not being managed by a @p CFANavigationWindow
 */
@property (nonatomic, readonly, nullable) CFANavigationWindow *cfa_navigationWindow;

@end

NS_ASSUME_NONNULL_END
