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

@interface MapViewController ()<GMSMapViewDelegate, GMUClusterManagerDelegate>
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;     // outlet vs field

@end

@implementation MapViewController {
    GMSMapView *_mapView;
    GMUClusterManager *_clusterManager;
    GMSCircle *_circ;
}

-(void)loadView {
    [super loadView];
    // Center on Seattle
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:47.61 longitude:-122.33 zoom:12];
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.view = _mapView;
    _mapView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(self.mapView.camera.target.latitude, self.mapView.camera.target.longitude);
    GMSMarker *marker = [GMSMarker markerWithPosition:mapCenter];
    marker.icon = [UIImage imageNamed:@"custom_pin.png"];
    marker.map = self.mapView;
    
    // Set up the cluster manager with a supplied icon generator and renderer.
    id<GMUClusterAlgorithm> algorithm = [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];
    id<GMUClusterIconGenerator> clusterIconGenerator = [[GMUDefaultClusterIconGenerator alloc] init];
    id<GMUClusterRenderer> renderer = [[GMUDefaultClusterRenderer alloc] initWithMapView:_mapView clusterIconGenerator:clusterIconGenerator];
    _clusterManager = [[GMUClusterManager alloc] initWithMap:_mapView algorithm:algorithm renderer:renderer];
    
    [_clusterManager cluster];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    _circ.map = nil;
    [_mapView animateToLocation:marker.position];
    
    if ([marker.userData conformsToProtocol:@protocol(GMUCluster)]) {
        [_mapView animateToZoom:_mapView.camera.zoom +1];
        return YES;
    }
    // Will show Date and image later
    marker.title = @"Date";
    marker.snippet = @"Post";
    marker.map = mapView;
    // Show marker
    _mapView.selectedMarker = marker;
    // Hide marker
    _mapView.selectedMarker = nil;
    
    return NO;
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
