//
//  CalendarViewController.m
//  Capstone
//
//  Created by jacquelinejou on 7/6/22.
//

#import "CalendarViewController.h"
#import <Parse/Parse.h>
#import "WelcomeViewController.h"
#import "SceneDelegate.h"

@interface CalendarViewController ()

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        SceneDelegate *mySceneDelegate = (SceneDelegate * ) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WelcomeViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeView"];
        mySceneDelegate.window.rootViewController = welcomeViewController;
    }];
}

@end