//
//  WelcomeViewController.m
//  Capstone
//
//  Created by jacquelinejou on 7/5/22.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@end

//bool isGrantedNotificationAccess;

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)registerUser:(id)sender {
    [self resignFirstResponder];
    [self performSegueWithIdentifier:@"registerSegue" sender:nil];
}

- (IBAction)loginUser:(id)sender {
    [self resignFirstResponder];
    [self performSegueWithIdentifier:@"loginSegue" sender:nil];
}

@end
