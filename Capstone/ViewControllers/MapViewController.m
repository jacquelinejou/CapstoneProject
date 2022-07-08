//
//  MapViewController.m
//  Capstone
//
//  Created by jacquelinejou on 7/6/22.
//

#import "MapViewController.h"
#import <Parse/Parse.h>
#import "WelcomeViewController.h"
#import "SceneDelegate.h"
#import "LocationGenerator.h"
@import GoogleMaps;
@import GoogleMapsUtils;

@interface MapViewController ()<GMSMapViewDelegate>
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;

@end

@implementation MapViewController

-(void)loadView {
    [super loadView];
    // Center on Seattle
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:47.61 longitude:122.33 zoom:12];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    [self.mapView setCamera:camera];
}

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
