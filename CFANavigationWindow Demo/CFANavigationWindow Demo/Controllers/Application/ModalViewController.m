//
//  ModalViewController.m
//  CFANavigationWindow Demo
//
//  Created by Bradley Mueller on 3/15/17.
//

#import "ModalViewController.h"
#import "Constants.h"

@interface ModalViewController ()

@end

@implementation ModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)dismissModal:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signOutTapped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenticationChangedNotification object:@(NO)];
}

@end
