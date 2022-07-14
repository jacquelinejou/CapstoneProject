//
//  PhotoViewController.m
//  Capstone
//
//  Created by jacquelinejou on 7/12/22.
//

#import "PhotoViewController.h"
#import "SceneDelegate.h"
#import "MapViewController.h"

@interface PhotoViewController ()
@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

-(void)checkTime{
    SceneDelegate *sd = [[SceneDelegate alloc] init];
    if (![sd dateConverter]) {
        [self performSegueWithIdentifier:@"postSegue" sender:nil];
    }
}

@end
