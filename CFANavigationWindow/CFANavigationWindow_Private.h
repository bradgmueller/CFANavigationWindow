//
//  CFANavigationWindow_Private.h
//  CFANavigationWindow Demo
//
//  Created by Bradley Mueller on 3/15/17.
//

#import "CFANavigationWindow.h"

@interface CFANavigationWindow ()

@property (nonatomic, strong) UIWindow *lowWindow;
@property (nonatomic, strong) UIWindow *mediumWindow;
@property (nonatomic, strong) UIWindow *highWindow;

@property (nonatomic, readonly) NSArray <UIWindow *> *windows;

@end
