//
//  SceneDelegate.m
//  Capstone
//
//  Created by jacquelinejou on 7/5/22.
//

#import "SceneDelegate.h"
#import "Parse/Parse.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (PFUser.currentUser) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    }
}

@end
