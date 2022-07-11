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
#import <Parse/PFObject+Subclass.h>
@import GoogleMaps;
@import GoogleMapsUtils;

@interface MapViewController ()<GMUClusterManagerDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) NSMutableArray *arrayOfPosts;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<GMSMarker *> *arrayOfMarkers;
@end

@implementation MapViewController {
//    GMSMapView *_mapView;
    GMUClusterManager *_clusterManager;
    GMSCircle *_circ;
    UIView *_contentView;
}

-(void)loadView {
    [super loadView];
    // Center on Current location
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:geoPoint.latitude longitude:geoPoint.longitude zoom:5];
            self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
            self.view = self.mapView;
            self.mapView.delegate = self;
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
            id<GMUClusterRenderer> renderer = [[GMUDefaultClusterRenderer alloc] initWithMapView:self.mapView clusterIconGenerator:clusterIconGenerator];
            self->_clusterManager = [[GMUClusterManager alloc] initWithMap:self.mapView algorithm:algorithm renderer:renderer];
            
            // Add markers to the cluster manager.
            [self->_clusterManager addItems:self.arrayOfMarkers];
            // Render clusters from items on the map
            [self->_clusterManager cluster];
            
            // setup scrollView
            [self setupScrollView];
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
        marker.userData = post;
        [self.arrayOfMarkers addObject:marker];
    }
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    _circ.map = nil;
    [self.mapView animateToLocation:marker.position];
    
    if ([marker.userData conformsToProtocol:@protocol(GMUCluster)]) {
        [self.mapView animateToZoom:self.mapView.camera.zoom +1];
        return YES;
    }
    marker.title = @"Date";
    marker.snippet = @"Post";
    marker.map = self.mapView;
    
    // Show marker
    self.mapView.selectedMarker = marker;
    // Hide marker
    self.mapView.selectedMarker = nil;
    return NO;
}

-(UIView *) mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    CustomInfoWindow *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    Post *post = marker.userData;
    infoWindow.usernameLabel.font = [UIFont fontWithName:@"VirtuousSlabBold" size:10];
    infoWindow.usernameLabel.text = post[@"UserID"];
    
    // format date
    infoWindow.dateLabel.font = [UIFont fontWithName:@"VirtuousSlabThin" size:10];
    NSDate *postTime = post.createdAt;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    infoWindow.dateLabel.text = [formatter stringFromDate:postTime];
    
    // format image
    [post[@"Image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        infoWindow.postImage.image = [UIImage imageWithData:data];
    }];
    
    infoWindow.commentLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:10];
    infoWindow.commentLabel.text = [[NSString stringWithFormat:@"%lu", [post[@"Comments"] count]] stringByAppendingString:@" Comments"];
    infoWindow.reactionLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:10];
    infoWindow.reactionLabel.text = [[NSString stringWithFormat:@"%lu", [post[@"Reactions"] count]] stringByAppendingString:@" Reactions"];
    
//    float anchorSize = 0.5f;
//    float infoWindowWidth = 250.0f;
//    float infoWindowHeight = 250.0f;
//
//    [self.subView removeFromSuperview];
//    float offset = anchorSize * M_SQRT2;
//
//    self.subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, infoWindowWidth, infoWindowHeight - offset/2)];
//    [self.subView setBackgroundColor:[UIColor yellowColor]];
//
//    self.subView.layer.cornerRadius = 5;
//    self.subView.layer.masksToBounds = YES;
//
//    [self setupScrollView];
//    [self.subView addSubview:self.scrollView];
//    [infoWindow addSubview:self.subView];
//    CLLocationCoordinate2D anchor = [self.mapView.selectedMarker position];
//    CGPoint point = [self.mapView.projection pointForCoordinate:anchor];
//    point.y -= self.mapView.selectedMarker.icon.size.height + offset/2 + (infoWindowHeight - offset/2)/2;
//    self.subView.center = point;
//
//    [self.mapView addSubview:self.subView];
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

-(void) setupScrollView {
    //    for(UIView *view in [yourScrollView subviews]){
    //
    //        [view removeFromSuperview];
    //    }
    //
    //    for(int i=0;i!=[yourArray count];i++)
    //    {
    //        labels[i]=[[UILabel alloc]init];
    //        //anyInteger is about your views place.
    //        views[i]=[[UIView alloc]initWithFrame:CGRectMake(21, i*anyInteger, 300, 50)];
    //        views[i].backgroundColor=[UIColor colorWithRed:0.1 green:0.2 blue:1.8 alpha:0.0];
    //        [views[i] addSubview:labels[i]];
    //        [yourScrollView addSubview:views[i]];
    //    }
//    [self.mapView bringSubviewToFront:self.collectionView];
//    [self.subView bringSubviewToFront:self.self.scrollView];
//    self.scrollView.pagingEnabled = YES;
//    self.scrollView.delegate = self;
    // and tablesource
//    self.scrollView.contentSize = CGSizeMake(self.mapView.intrinsicContentSize.width, self.mapView.intrinsicContentSize.height / 4);
//    CGRect selfBounds = self.view.bounds;
//    CGFloat width = CGRectGetWidth(self.scrollView.bounds);
//    CGFloat height = CGRectGetHeight(self.scrollView.bounds);
//    NSMutableString *constraintBuilding = [NSMutableString stringWithFormat:@"|"];
//    for (int i = 0; i < self.arrayOfMarkers.count; i++) {
//        CGFloat offset = width * i;
//        UIView* view1 = [[UIView alloc] initWithFrame:CGRectOffset(selfBounds, offset, 0)];
//        [view1 setTranslatesAutoresizingMaskIntoConstraints:NO];
//        [view1 setBackgroundColor:[UIColor colorWithRed:0.1 green:0.2 blue:1.8 alpha:0.0]];
//        [self.scrollView addSubview:view1];
//        //        [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view1(height)]|" options:0 metrics:@{@"height":@(height)} views:NSDictionaryOfVariableBindings(view1)]];
//        [constraintBuilding appendString:[NSString stringWithFormat:@"[view%i(width)]",i+1]];
//    }
//    
    //    NSMutableDictionary *views = [[NSMutableDictionary alloc] init];
    //
    //    for (int j = 0; j < self.scrollView.subviews.count; j++) {
    //        if (![[self.scrollView.subviews objectAtIndex:j] isKindOfClass:[UIImageView class]]) {
    //            [views addObject:[self.scrollView.subviews objectAtIndex:j]];
    //        }
    //    }
    //
    //    [constraintBuilding appendString:@"|"];
    //    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintBuilding options:0 metrics:@{@"width":@(width*colors.count)} views:NSDictionaryOfVariableBindings(views)]];
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
