//
//  AppDelegate.m
//  CFANavigationWindow Demo
//
//  Created by Bradley Mueller on 3/15/17.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "WindowAnimator.h"

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "MaskViewController.h"
#import "PINViewController.h"

#import "CFANavigationWindow.h"

@interface AppDelegate ()

@property (nonatomic) BOOL loggedIn;

@property (nonatomic, weak) PINViewController *pinController;
@property (nonatomic, weak) MaskViewController *maskController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup an initial window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view.backgroundColor = [UIColor blackColor];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authStateDidChange:)
                                                 name:kAuthenticationChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userEnteredPin:)
                                                 name:kUserEnteredCorrectPINNotification
                                               object:nil];
    
    [self setAuthStateChangedToAuthenticated:self.loggedIn animated:NO];
    
    if (self.loggedIn == YES)
    {
        [self presentController:self.pinController atWindowLevel:CFANavigationWindowLevelMedium animated:NO];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    if (self.loggedIn == YES)
    {
        [self presentController:self.maskController atWindowLevel:CFANavigationWindowLevelHigh animated:NO];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (self.loggedIn == YES)
    {
        [self presentController:self.pinController atWindowLevel:CFANavigationWindowLevelMedium animated:NO];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self dismissController:_maskController fromWindowLevel:CFANavigationWindowLevelHigh animated:NO];
}

- (void)authStateDidChange:(NSNotification *)notification
{
    self.loggedIn = [notification.object boolValue];
    
    [self setAuthStateChangedToAuthenticated:self.loggedIn animated:YES];
}

- (void)userEnteredPin:(NSNotification *)notification
{
    [self dismissController:_pinController fromWindowLevel:CFANavigationWindowLevelMedium animated:YES];
}

#pragma Setters/getters

- (BOOL)loggedIn
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"];
}

- (void)setLoggedIn:(BOOL)loggedIn
{
    [[NSUserDefaults standardUserDefaults] setBool:loggedIn forKey:@"loggedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (PINViewController *)pinController
{
    if (_pinController == nil)
    {
        PINViewController *vc = [[PINViewController alloc] init];
        _pinController = vc;
        return vc;
    }
    return _pinController;
}

- (MaskViewController *)maskController
{
    if (_maskController == nil)
    {
        MaskViewController *vc = [[MaskViewController alloc] init];
        _maskController = vc;
        return vc;
    }
    return _maskController;
}

#pragma mark - Windowing

#pragma mark Switching root window

- (void)setAuthStateChangedToAuthenticated:(BOOL)authenticated animated:(BOOL)animated
{
    UIViewController *controller = authenticated ? [[HomeViewController alloc] init] : [[LoginViewController alloc] init];
    
    WindowAnimator *animator = animated ? [[WindowAnimator alloc] init] : nil;
    
    NSLog(@"Switching to %@\n%@", authenticated ? @"Logged In" : @"Logged Out", [CFANavigationWindow currentNavigationWindow]);
    
    [UIWindow cfa_replaceRootWindowWithController:controller
                                     withAnimator:animator
                                       completion:nil];
}

#pragma mark Managing stacked windows

- (void)dismissController:(UIViewController *)controller fromWindowLevel:(CFANavigationWindowLevel)level animated:(BOOL)animated
{
    if (controller == nil)
    {
        return;
    }
    
    CFANavigationWindow *navWindow = [CFANavigationWindow currentNavigationWindow];
    
    UIViewController *existingController = [navWindow controllerAtLevel:level];
    if (existingController != controller)
    {
        NSAssert(NO, @"Existing controller at this level doesn't match dismissal controller - %ld", (long)level);
        return;
    }
    
    NSLog(@"Dismissing %@\n%@", NSStringFromClass([controller class]), navWindow);
    
    WindowAnimator *animator = animated ? [[WindowAnimator alloc] init] : nil;
    [navWindow popController:controller withAnimator:animator completion:nil];
}

- (void)presentController:(UIViewController *)controller atWindowLevel:(CFANavigationWindowLevel)level animated:(BOOL)animated
{
    if (controller == nil)
    {
        return;
    }
    
    CFANavigationWindow *navWindow = [CFANavigationWindow currentNavigationWindow];
    
    UIViewController *existingController = [navWindow controllerAtLevel:level];
    if (existingController != nil && existingController == controller)
    {
        NSLog(@"Bailing on presenting controller - it is already presented");
        return;
    }
    
    NSLog(@"Presenting %@\n%@", NSStringFromClass([controller class]), navWindow);
    
    WindowAnimator *animator = animated ? [[WindowAnimator alloc] init] : nil;
    [navWindow pushController:controller atWindowLevel:level withAnimator:animator completion:nil];
}

@end
