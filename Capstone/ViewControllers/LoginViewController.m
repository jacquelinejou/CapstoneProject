//
//  LoginViewController.m
//  Capstone
//
//  Created by jacquelinejou on 7/5/22.
//

#import "LoginViewController.h"
#import "WelcomeViewController.h"
#import <Parse/Parse.h>
#import "ParseConnectionAPIManager.h"
#import "NotificationManager.h"

@interface LoginViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@end

static NSInteger _fontSize = 15;
static CGFloat _keyboardAnimationDuration = 0.3;
static CGFloat _startingKeyboardPostion = 0.0;

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameText.font = [UIFont fontWithName:@"VirtuousSlabThin" size:_fontSize];
    self.passwordText.font = [UIFont fontWithName:@"VirtuousSlabThin" size:_fontSize];
    self.passwordText.secureTextEntry = YES;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)didLogin:(id)sender {
    NSString *username = self.usernameText.text;
    NSString *password = self.passwordText.text;
    if ([username isEqualToString:@""] || [password isEqualToString:@""]) {
        [self emptyLoginAttempt];
    } else {
        [[ParseConnectionAPIManager sharedManager] loginWithCompletion:username password:password completion:^(NSError * _Nonnull error) {
            if (error == nil) {
                [self resignFirstResponder];
                [[NotificationManager sharedManager] isTime:^(BOOL isTime) {
                    NSString *const segueIdentifier = (isTime ? @"photoSegue" : @"loginSegue");
                    [self performSegueWithIdentifier:segueIdentifier sender:nil];
                }];
            } else {
                [self failedLogin];
            }
        }];
    }
}

-(UIAlertController *)errorMessage {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{
    }];
    return alert;
}

-(void)emptyLoginAttempt {
    UIAlertController *alert = [self errorMessage];
    alert.title = @"Empty Field";
    alert.message = @"Please fill in this field.";
}

-(void)failedLogin {
    UIAlertController *alert = [self errorMessage];
    alert.title = @"Invalid Login";
    alert.message = @"This username/password does not exist.";
}

- (IBAction)didCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:_keyboardAnimationDuration animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height;
        self.view.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:_keyboardAnimationDuration animations:^{
        CGRect f = self.view.frame;
        f.origin.y = _startingKeyboardPostion;
        self.view.frame = f;
    }];
}

@end
