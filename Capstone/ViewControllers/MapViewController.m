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
#import "CustomInfoWindow.h"
#import "Post.h"
@import GoogleMaps;
@import GoogleMapsUtils;

@interface MapViewController ()<GMUClusterManagerDelegate>
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) NSMutableArray *arrayOfPosts;
@property (nonatomic, strong) NSMutableArray<GMSMarker *> *arrayOfMarkers;
@end

@implementation MapViewController {
    GMSMapView *_mapView;
    GMUClusterManager *_clusterManager;
    GMSCircle *_circ;
    UIView *_contentView;
}

-(void)loadView {
    [super loadView];
    // Center on Current location
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:geoPoint.latitude longitude:geoPoint.longitude zoom:12];
            self->_mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
            self.view = self->_mapView;
            self->_mapView.delegate = self;
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrayOfPosts = [[NSMutableArray alloc] init];
    self.arrayOfMarkers = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.arrayOfPosts = (NSMutableArray *)posts;
            [self loadMarkers];
            
            // Set up the cluster manager with a supplied icon generator and renderer.
            id<GMUClusterAlgorithm> algorithm = [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];
            id<GMUClusterIconGenerator> clusterIconGenerator = [[GMUDefaultClusterIconGenerator alloc] init];
            id<GMUClusterRenderer> renderer = [[GMUDefaultClusterRenderer alloc] initWithMapView:self->_mapView clusterIconGenerator:clusterIconGenerator];
            self->_clusterManager = [[GMUClusterManager alloc] initWithMap:self->_mapView algorithm:algorithm renderer:renderer];
            
            // Add markers to the cluster manager.
            [self->_clusterManager addItems:self.arrayOfMarkers];
            // Render clusters from items on the map
            [self->_clusterManager cluster];
        }
    }];
}

- (void)loadMarkers {
    for (Post *post in self.arrayOfPosts) {
        PFGeoPoint *coordinates = (PFGeoPoint *) post[@"Location"];
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinates.latitude longitude:coordinates.longitude zoom:12];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(camera.target.latitude, camera.target.longitude);
        GMSMarker *marker = [GMSMarker markerWithPosition:coord];
        marker.icon = [UIImage imageNamed:@"custom_pin.png"];
        marker.map = self.mapView;
        [self.arrayOfMarkers addObject:marker];
    }
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    _circ.map = nil;
    [_mapView animateToLocation:marker.position];
    
    if ([marker.userData conformsToProtocol:@protocol(GMUCluster)]) {
        [_mapView animateToZoom:_mapView.camera.zoom +1];
        return YES;
    }
    marker.title = @"Date";
    marker.snippet = @"Post";
    marker.map = mapView;

    // Show marker
    _mapView.selectedMarker = marker;
    // Hide marker
    _mapView.selectedMarker = nil;
    
    return NO;
}

-(UIView *) mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    CustomInfoWindow *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    Post *post = (Post *) marker;
    infoWindow.usernameLabel.text = post.userID;
    infoWindow.dateLabel.text = [self setDate:post.date];
    NSData *data = post.image.getData;
    infoWindow.postImage.image = [UIImage imageWithData:data];
    infoWindow.commentLabel.text = [NSString stringWithFormat:@"%lu", post.comments.count];
    infoWindow.reactionLabel.text = [NSString stringWithFormat:@"%lu", post.reactions.count];
    return infoWindow;
}

-(NSString *) setDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    // Configure the input format to parse the date string
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    NSString *stringDate = [formatter stringFromDate:date];
    return stringDate;
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
