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
#import "PostCell.h"
#import <Parse/PFObject+Subclass.h>
@import GoogleMaps;
@import GoogleMapsUtils;

@interface MapViewController ()<GMUClusterManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) NSMutableArray *arrayOfPosts;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
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
            [self.mapView animateToCameraPosition:camera];
            self.mapView.mapType = kGMSTypeNormal;
            self.mapView.delegate = self;
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.showsHorizontalScrollIndicator = YES;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [self.collectionView initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView setHidden:YES];
    [self setConstraints];
    
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
        }
    }];
}

-(void)setConstraints {
    [self collectionViewConstraints];
}

-(void)collectionViewConstraints {
    NSLayoutConstraint *collectionViewWidth = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *collectionViewHeight = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute: NSLayoutAttributeHeight multiplier:0.25 constant:0.0f];
    NSLayoutConstraint *collectionViewLeading = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.mapView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:5.0f];
    NSLayoutConstraint *collectionViewTrailing = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.mapView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:5.0f];
    NSLayoutConstraint *collectionViewBottom = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.mapView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0f];
    [self.view addConstraints:@[collectionViewWidth, collectionViewHeight, collectionViewLeading, collectionViewTrailing, collectionViewBottom]];
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
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayOfPosts.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.frame.size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PostCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"PostCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.25];
    Post *post = self.arrayOfPosts[indexPath.row];
    cell.usernameLabel.text = [[NSString alloc] init];
    cell.usernameLabel.font = [UIFont fontWithName:@"VirtuousSlabBold" size:10];
    cell.usernameLabel.text = post[@"UserID"];
    
    // format date
    cell.dateLabel.font = [UIFont fontWithName:@"VirtuousSlabThin" size:10];
    NSDate *postTime = post.createdAt;
    cell.dateLabel.text = [self setDate:postTime];
    
    // format image
    [post[@"Image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        cell.postImage.image = [UIImage imageWithData:data];
    }];
    
    cell.commentLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:10];
    cell.commentLabel.text = [[NSString stringWithFormat:@"%lu", [post[@"Comments"] count]] stringByAppendingString:@" Comments"];
    cell.reactionLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:10];
    cell.reactionLabel.text = [[NSString stringWithFormat:@"%lu", [post[@"Reactions"] count]] stringByAppendingString:@" Reactions"];
    return cell;
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
    [self.collectionView setHidden:NO];
    // Hide marker
    self.mapView.selectedMarker = nil;
    return NO;
}

- (void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.collectionView setHidden:YES];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 8.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,2,0,2);
}

-(UIView *) mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    CustomInfoWindow *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    Post *post = marker.userData;
    infoWindow.usernameLabel.font = [UIFont fontWithName:@"VirtuousSlabBold" size:10];
    infoWindow.usernameLabel.text = post[@"UserID"];
    
    // format date
    infoWindow.dateLabel.font = [UIFont fontWithName:@"VirtuousSlabThin" size:10];
    NSDate *postTime = post.createdAt;
    infoWindow.dateLabel.text = [self setDate:postTime];
    
    // format image
    [post[@"Image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        infoWindow.postImage.image = [UIImage imageWithData:data];
    }];
    
    infoWindow.commentLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:10];
    infoWindow.commentLabel.text = [[NSString stringWithFormat:@"%lu", [post[@"Comments"] count]] stringByAppendingString:@" Comments"];
    infoWindow.reactionLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:10];
    infoWindow.reactionLabel.text = [[NSString stringWithFormat:@"%lu", [post[@"Reactions"] count]] stringByAppendingString:@" Reactions"];
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
