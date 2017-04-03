//
//  HomeViewController.m
//  CFANavigationWindow Demo
//
//  Created by Bradley Mueller on 3/15/17.
//

#import "HomeViewController.h"
#import "Constants.h"
#import "WindowAnimator.h"

#import "LoadingViewController.h"
#import "ModalViewController.h"

#import "CFANavigationWindow.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self fetchInitialUserData];
}

- (void)fetchInitialUserData
{
    LoadingViewController *loadingController = [[LoadingViewController alloc] init];
    CFANavigationWindow *navWindow = [CFANavigationWindow currentNavigationWindow];
    
    NSLog(@"Presenting %@\n%@", NSStringFromClass(loadingController.class), navWindow);
    [navWindow pushController:loadingController
                atWindowLevel:CFANavigationWindowLevelLow
                 withAnimator:nil
                   completion:nil];
    
    /* Simulate fetch requests */
    float delayInSeconds = 4.0;
    dispatch_time_t delayTimer = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(delayTimer, dispatch_get_main_queue(), ^(void){
        
        /* Fetch requests returned */
        
        NSLog(@"Dismissing %@\n%@", NSStringFromClass(loadingController.class), navWindow);
        
        WindowAnimator *animator = [[WindowAnimator alloc] init];
        [navWindow popController:loadingController withAnimator:animator completion:nil];
    });
}

- (IBAction)presentModal:(id)sender
{
    ModalViewController *vc = [[ModalViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)signOutTapped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenticationChangedNotification object:@(NO)];
}

@end
