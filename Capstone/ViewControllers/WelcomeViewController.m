//
//  WelcomeViewController.m
//  Capstone
//
//  Created by jacquelinejou on 7/5/22.
//

#import "WelcomeViewController.h"
#import "AppDelegate.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self disableScreenRotation];
}

- (IBAction)registerUser:(id)sender {
    [self resignFirstResponder];
    [self performSegueWithIdentifier:@"registerSegue" sender:nil];
}

- (IBAction)loginUser:(id)sender {
    [self resignFirstResponder];
    [self performSegueWithIdentifier:@"loginSegue" sender:nil];
}

-(void)disableScreenRotation {
    AppDelegate *shared = [UIApplication sharedApplication].delegate;
    shared.disableRotation = YES;
}

@end
