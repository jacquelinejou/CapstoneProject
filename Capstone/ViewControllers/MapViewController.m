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
#import "CalendarViewController.h"
#import <Parse/PFObject+Subclass.h>
@import GoogleMaps;
@import GoogleMapsUtils;

@interface MapViewController ()<GMUClusterManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITabBarControllerDelegate>
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) NSMutableArray *arrayOfPosts;
@property (nonatomic, strong) NSMutableDictionary *dictOfPosts;
@property (nonatomic, strong) NSMutableDictionary *currMonthDictOfPosts;
@property (nonatomic, strong) NSMutableArray<GMSMarker *> *arrayOfMarkers;
@end

@implementation MapViewController {
    UICollectionView *_collectionView;
    GMUClusterManager *_clusterManager;
    GMSCircle *_circ;
    UIView *_contentView;
    CGFloat borderSpace;
    NSInteger insets;
}

-(void)loadView {
    [super loadView];
    // Center on Current location if no posts, or else latest post
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
    borderSpace = 10.0;
    insets = 2;
    self.tabBarController.delegate = self;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.mapView addSubview:_collectionView];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[PostCell class] forCellWithReuseIdentifier:@"PostCell"];
    _collectionView.showsHorizontalScrollIndicator = YES;
    [_collectionView setHidden:YES];
    
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
            [self setupDictionaries];
            
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

-(void)setupDictionaries {
    self.dictOfPosts = [[NSMutableDictionary alloc] init];
    self.currMonthDictOfPosts = [[NSMutableDictionary alloc] init];
    for (Post *post in self.arrayOfPosts) {
        // sets date to beginning of day to compare later
        NSDate *date = post.createdAt;
        [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay startDate:&date interval:NULL forDate:date];
        
        // converts image to usable image
        PFFileObject *pffile = post[@"Image"];
        NSString *url = pffile.url;
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: url]];
        UIImage *image = [UIImage imageWithData: imageData];
        self.dictOfPosts[date] = image;
        // add to current month dict if in curr month
        if ([self isSameMonth:date otherDay:[NSDate date]]) {
            self.currMonthDictOfPosts[date] = image;
        }
    }
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

-(void)updateViewConstraints {
    [super updateViewConstraints];
    [_collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_collectionView.leftAnchor constraintEqualToAnchor:self.mapView.leftAnchor constant:borderSpace].active = YES;
    [_collectionView.rightAnchor constraintEqualToAnchor:self.mapView.rightAnchor constant:borderSpace * -1].active = YES;
    [_collectionView.bottomAnchor constraintEqualToAnchor:self.mapView.bottomAnchor constant:borderSpace * -1].active = YES;
    [_collectionView.heightAnchor constraintEqualToConstant:0.25 * self.view.frame.size.height].active = YES;
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
    [_collectionView reloadData];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayOfPosts.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _collectionView.frame.size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PostCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"PostCell" forIndexPath:indexPath];
    Post *post = self.arrayOfPosts[indexPath.row];
    [cell setupCell:post];
    PFGeoPoint *coordinates = (PFGeoPoint *) post[@"Location"];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinates.latitude longitude:coordinates.longitude zoom:5];
    [self.mapView animateToCameraPosition:camera];
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
    [_collectionView setHidden:NO];
    // Hide marker
    self.mapView.selectedMarker = nil;
    return NO;
}

- (void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [_collectionView setHidden:YES];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return borderSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return borderSpace;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,insets,0,insets);
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
    PFFileObject *pffile = post[@"Image"];
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
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        SceneDelegate *mySceneDelegate = (SceneDelegate * ) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WelcomeViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeView"];
        mySceneDelegate.window.rootViewController = welcomeViewController;
    }];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    UINavigationController *navController = tabBarController.viewControllers[1];
    CalendarViewController *calendarView = (CalendarViewController *) navController.topViewController;
    calendarView.dictOfPosts = self.dictOfPosts;
    calendarView.currMonthDictOfPosts = self.currMonthDictOfPosts;
}

@end
