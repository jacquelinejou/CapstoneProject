//
//  LoginViewController.m
//  Capstone
//
//  Created by jacquelinejou on 7/5/22.
//

#import "LoginViewController.h"
#import "WelcomeViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameText.font = [UIFont fontWithName:@"VirtuousSlabThin" size:15];
    self.passwordText.font = [UIFont fontWithName:@"VirtuousSlabThin" size:15];
}

- (IBAction)didLogin:(id)sender {
    NSString *username = self.usernameText.text;
    NSString *password = self.passwordText.text;
    if ([username isEqualToString:@""] || [password isEqualToString:@""]) {
        [self loginHelper];
    } else {
       [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
           if (error == nil) {
               [self performSegueWithIdentifier:@"loginSegue" sender:nil];
           } else {
               [self failedLogin];
           }
       }];
    }
}

-(void)loginHelper {
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

-(void)failedLogin {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Login" message:@"This username/password does not exist." preferredStyle:(UIAlertControllerStyleAlert)];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
