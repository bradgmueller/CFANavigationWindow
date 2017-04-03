//
//  UIWindow+CFA_Private.h
//  CFANavigationWindow Demo
//
//  Created by Bradley Mueller on 3/15/17.
//

#import "UIWindow+CFA.h"
#import "CFANavigationWindow.h"

@interface UIWindow (CFA_Private)

@property (nonatomic, readwrite, nullable) CFANavigationWindow *cfa_navigationWindow;
@property (nonatomic, readwrite) CFANavigationWindowLevel cfa_navigationLevel;

- (void)cfa_destroy;
- (void)cfa_showInScreen;

@end
