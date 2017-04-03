//
//  CFAWindowAnimationContext.h
//  CFANavigationWindow Demo
//
//  Created by Bradley Mueller on 3/15/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, CFAWindowTransitionType) {
    CFAWindowTransitionTypePush,
    CFAWindowTransitionTypePop,
    CFAWindowTransitionTypeRoot
};

@interface CFAWindowAnimationContext : NSObject

/** 
 The topmost visible window animation is transitioning from
 */
@property (nonatomic, strong) UIWindow *topFromWindow;

/** 
 The topmost visible window animation is transitioning to
 */
@property (nonatomic, strong) UIWindow *topToWindow;

/** 
 Any underlying windows animation is transitioning from
 */
@property (nonatomic, strong, nullable) NSArray <UIWindow *> *underlyingFromWindows;

/** 
 Any underlying windows animation is transitioning to
 */
@property (nonatomic, strong, nullable) NSArray <UIWindow *> *underlyingToWindows;

/** 
 The transition type
 */
@property (nonatomic) CFAWindowTransitionType type;

/** 
 A completion block - this MUST be called by the animator upon its completion. All windows will be properly reset to their visibility, or destroyed if removed from the hierarchy.
 */
@property (nonatomic, copy) void(^animationFinished)();

@end

NS_ASSUME_NONNULL_END
