//
//  PINViewController.m
//  CFANavigationWindow Demo
//
//  Created by Bradley Mueller on 3/15/17.
//

#import "PINViewController.h"
#import "Constants.h"

@interface PINViewController ()

@end

@implementation PINViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)enterPIN:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserEnteredCorrectPINNotification object:nil];
}

- (IBAction)logout:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenticationChangedNotification object:@(NO)];
}

@end
