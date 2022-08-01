//
//  MapViewController.h
//  Capstone
//
//  Created by jacquelinejou on 7/06/22.
//

#import "MapViewController.h"
#import <Parse/Parse.h>
#import "WelcomeViewController.h"
#import "CustomInfoWindow.h"
#import "PostCell.h"
#import "CalendarViewController.h"
#import <Parse/PFObject+Subclass.h>
#import "APIManager.h"
@import GoogleMaps;
@import GoogleMapsUtils;

@interface MapViewController ()<GMUClusterManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITabBarControllerDelegate>
@property (strong,nonatomic) PostDetailsViewController* postDetailsVC;
@end

@implementation MapViewController {
    UICollectionView *_collectionView;
    GMSMapView *_mapView;
    GMUClusterManager *_clusterManager;
    GMSCircle *_circ;
    UIView *_contentView;
    CGFloat _borderSpace;
    NSInteger _insets;
    BOOL isMoved;
    BOOL windowShowing;
    CLLocationCoordinate2D _currLocation;
    PFGeoPoint *_northEast;
    PFGeoPoint *_northWest;
    PFGeoPoint *_southEast;
    PFGeoPoint *_southWest;
    NSMutableArray *_posts;
    NSMutableArray<GMSMarker *> *_markers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.delegate = self;
    self.postDetailsVC = [[PostDetailsViewController alloc] init];
    self.postDetailsVC.delegate = self;
    _borderSpace = 10.0;
    _insets = 2;
    isMoved = YES;
    windowShowing = NO;
    _posts = [[NSMutableArray alloc] init];
    _markers = [[NSMutableArray alloc] init];
    [self setupMapView];
    [self setupScrollBar];
    [self setupClustering];
}

-(void)setupMapView {
    // open map on bellevue with my location enabled to center on current location
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:47.6 longitude:-122.2 zoom:10];
    _mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    _mapView.delegate = self;
    _mapView.mapType = kGMSTypeNormal;
    _mapView.settings.compassButton = YES;
    _mapView.settings.myLocationButton = YES;
    [self.view addSubview:_mapView];
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_mapView.myLocationEnabled = YES;
    });

}

-(void)setupScrollBar {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[PostCell class] forCellWithReuseIdentifier:@"PostCell"];
    _collectionView.showsHorizontalScrollIndicator = YES;
    [_collectionView setHidden:YES];
    [_mapView addSubview:_collectionView];
}

-(void)setupClustering {
    id<GMUClusterAlgorithm> algorithm = [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];
    id<GMUClusterIconGenerator> clusterIconGenerator = [[GMUDefaultClusterIconGenerator alloc] init];
    id<GMUClusterRenderer> renderer = [[GMUDefaultClusterRenderer alloc] initWithMapView:_mapView clusterIconGenerator:clusterIconGenerator];
    _clusterManager = [[GMUClusterManager alloc] initWithMap:_mapView algorithm:algorithm renderer:renderer];
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    isMoved = YES;
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    if (isMoved) {
        isMoved = NO;
        // don't refetch data when recentering on marker tap
        if (!windowShowing) {
            [self fetchData];
        }
        windowShowing = NO;
        // hide scroll bar if empty
        if ([_posts count] == 0) {
            [_collectionView setHidden:YES];
        }
    }
}

-(void)fetchData {
    [self findDisplayDimensions];
    NSArray *coordinates = @[_northWest, _northEast, _southEast, _southWest];
    [[APIManager sharedManager] fetchMapDataWithCompletion:coordinates completion:^(NSArray * _Nonnull posts, NSError * _Nonnull error) {
            if (posts != nil) {
                self->_posts = (NSMutableArray *)posts;
                [self loadMarkers];

                // reset cluster manager
                [self->_clusterManager clearItems];
                [self->_clusterManager addItems:self->_markers];
                [self->_clusterManager cluster];
            }
    }];
}

-(void)findDisplayDimensions {
    GMSVisibleRegion visibleRegion = [_mapView.projection visibleRegion];
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]initWithRegion:visibleRegion];
    CLLocationCoordinate2D northEast = bounds.northEast;
    CLLocationCoordinate2D northWest = CLLocationCoordinate2DMake(bounds.northEast.latitude, bounds.southWest.longitude);
    CLLocationCoordinate2D southEast = CLLocationCoordinate2DMake(bounds.southWest.latitude, bounds.northEast.longitude);
    CLLocationCoordinate2D  southWest = bounds.southWest;
    _northEast = [PFGeoPoint geoPointWithLatitude:northEast.latitude longitude:northEast.longitude];
    _northWest = [PFGeoPoint geoPointWithLatitude:northWest.latitude longitude:northWest.longitude];
    _southWest = [PFGeoPoint geoPointWithLatitude:southWest.latitude longitude:southWest.longitude];
    _southEast = [PFGeoPoint geoPointWithLatitude:southEast.latitude longitude:southEast.longitude];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

-(void)updateViewConstraints {
    [super updateViewConstraints];
    [self setupMapConstraints];
    [self updateScrollBarConstraints];
}

-(void)updateScrollBarConstraints {
    [_collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_collectionView.leftAnchor constraintEqualToAnchor:_mapView.leftAnchor constant:_borderSpace].active = YES;
    [_collectionView.rightAnchor constraintEqualToAnchor:_mapView.rightAnchor constant:_borderSpace * -1].active = YES;
    [_collectionView.bottomAnchor constraintEqualToAnchor:_mapView.bottomAnchor constant:self.view.frame.size.height * -0.11].active = YES;
    [_collectionView.heightAnchor constraintEqualToConstant:0.25 * self.view.frame.size.height].active = YES;
}

-(void)setupMapConstraints{
    [_mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_mapView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [_mapView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [_mapView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_mapView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}

- (void)loadMarkers {
    [_markers removeAllObjects];
    for (Post *post in _posts) {
        [self loadMarker:post];
    }
    [_collectionView reloadData];
}

-(void)loadMarker:(Post *)post {
    PFGeoPoint *coordinate = (PFGeoPoint *) post.Location;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude longitude:coordinate.longitude zoom:10];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(camera.target.latitude, camera.target.longitude);
    GMSMarker *marker = [GMSMarker markerWithPosition:coord];
    marker.icon = [UIImage imageNamed:@"custom_pin.png"];
    marker.map = _mapView;
    marker.userData = post;
    [_markers addObject:marker];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _posts.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _collectionView.frame.size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PostCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"PostCell" forIndexPath:indexPath];
    Post *post = _posts[indexPath.row];
    cell.post = post;
    cell.usernameLabel.text = post.UserID;
    cell.commentLabel.text = [[NSString stringWithFormat:@"%lu", [post.Comments count]] stringByAppendingString:@" Comments"];
    cell.reactionLabel.text = [[NSString stringWithFormat:@"%lu", [post.Reactions count]] stringByAppendingString:@" Reactions"];
    
    // setup post date
    NSDate *postTime = post.createdAt;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    cell.dateLabel.text = [formatter stringFromDate:postTime];
    
    // setup post image
    PFFileObject *pffile = post.Image;
    NSString *url = pffile.url;
    NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: url]];
    cell.postImage.image = [UIImage imageWithData: imageData];
    return cell;
}

// when tap post in scroll bar, recenter map on that post and display it in a details view controller
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Post *post = _posts[indexPath.row];
    GMSMarker *marker = _markers[indexPath.row];
    _mapView.selectedMarker = marker;
    PFGeoPoint *coordinates = (PFGeoPoint *) post.Location;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinates.latitude longitude:coordinates.longitude zoom:10];
    [_mapView animateToLocation:CLLocationCoordinate2DMake(camera.target.latitude, camera.target.longitude)];
    // send post to postdetailsviewcontroller
    self.postDetailsVC.postDetails = post;
    self.postDetailsVC.postIndex = indexPath.row;
    [[self navigationController] pushViewController:self.postDetailsVC animated:YES];
    isMoved = NO;
}

- (void)didSendBackPost:(Post *)post withIndex:(NSInteger)postIndex {
    Post *oldPost = _posts[postIndex];
    [_posts removeObject:oldPost];
    [_posts addObject:post];
    [_collectionView reloadData];
}

// display marker window above marker and scroll bar when tapped
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    _circ.map = nil;
    windowShowing = YES;
    [_mapView animateToLocation:marker.position];
    
    if ([marker.userData conformsToProtocol:@protocol(GMUCluster)]) {
        [_mapView animateToZoom:_mapView.camera.zoom +1];
        return YES;
    }
    marker.title = @"Date";
    marker.snippet = @"Post";
    marker.map = _mapView;
    
    // Show marker
    _mapView.selectedMarker = marker;
    [_collectionView setHidden:NO];
    // Hide marker
    _mapView.selectedMarker = nil;
    return NO;
}

// close marker window and scroll bar when tap anywhere other than a marker
- (void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    windowShowing = NO;
    _mapView.selectedMarker = nil;
    [_collectionView setHidden:YES];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return _borderSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return _borderSpace;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,_insets,0,_insets);
}

// setup marker window
-(UIView *) mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    CustomInfoWindow *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    Post *post = marker.userData;
    infoWindow.usernameLabel.font = [UIFont fontWithName:@"VirtuousSlabBold" size:10];
    infoWindow.usernameLabel.text = post.UserID;
    
    // format date
    infoWindow.dateLabel.font = [UIFont fontWithName:@"VirtuousSlabThin" size:10];
    NSDate *postTime = post.createdAt;
    infoWindow.dateLabel.text = [self setDate:postTime];
    
    // format image
    PFFileObject *pffile = post.Image;
    NSString *url = pffile.url;
    NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: url]];
    infoWindow.postImage.image = [UIImage imageWithData: imageData];
    
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

- (BOOL)isSameMonth:(NSDate*)date1 otherDay:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    return [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

- (IBAction)didLogout:(id)sender {
    [[APIManager sharedManager] logout];
}

@end
