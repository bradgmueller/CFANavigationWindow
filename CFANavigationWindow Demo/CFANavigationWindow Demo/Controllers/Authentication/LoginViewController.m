//
//  LoginViewController.m
//  CFANavigationWindow Demo
//
//  Created by Bradley Mueller on 3/15/17.
//

#import "LoginViewController.h"
#import "Constants.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)signedIn:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenticationChangedNotification object:@(YES)];
}

@end
