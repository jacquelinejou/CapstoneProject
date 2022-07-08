//
//  RegisterViewController.m
//  Capstone
//
//  Created by jacquelinejou on 7/5/22.
//

#import "RegisterViewController.h"
#import <Parse/Parse.h>

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameText.font = [UIFont fontWithName:@"VirtuousSlabThin" size:15];
    self.passwordText.font = [UIFont fontWithName:@"VirtuousSlabThin" size:15];
}

- (IBAction)didRegister:(id)sender {
    // Create user
    PFUser *newUser = [PFUser user];
    // set user properties
    newUser.username = self.usernameText.text;
    newUser.password = self.passwordText.text;
    if ([self.usernameText.text isEqualToString:@""] || [self.passwordText.text isEqualToString:@""]) {
        [self registrationHelper];
    } else {
       [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
           if (error == nil) {
               [self dismissViewControllerAnimated:YES completion:nil];
           } else {
               [self failedRegister];
           }
       }];
    }
}

-(void)registrationHelper {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty Field" message:@"Please fill in this field." preferredStyle:(UIAlertControllerStyleAlert)];
    
    // create a cancel action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    // add the cancel action to the alertController
    [alert addAction:cancelAction];

    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * _Nonnull action) {
    }];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{
    }];
}

-(void)failedRegister {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Registration" message:@"This username already exists." preferredStyle:(UIAlertControllerStyleAlert)];
    
    // create a cancel action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    // add the cancel action to the alertController
    [alert addAction:cancelAction];

    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * _Nonnull action) {
    }];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{
    }];
}


- (IBAction)didCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
