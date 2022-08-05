//
//  CalendarViewController.m
//  Capstone
//
//  Created by jacquelinejou on 7/6/22.
//

#import "CalendarViewController.h"
#import <Parse/Parse.h>
#import "WelcomeViewController.h"
#import "FSCalendar.h"
#import "CalendarCell.h"
#import "Post.h"
#import "ParseConnectionAPIManager.h"
#import "ParseCalendarAPIManager.h"
#import "CacheManager.h"
#import "ColorManager.h"
#import "PlayVideoViewController.h"

@interface CalendarViewController () <FSCalendarDataSource, FSCalendarDelegate, UITabBarControllerDelegate>
@end

static CGFloat _borderSpace = 10.0;
static NSInteger _titleFont = 15;
static NSInteger _headerFont = 20;
static NSInteger _weekdayFont = 16;
static CGFloat _headerAlphaColor = 0.2;
static CGFloat _weekdayAlphaColor = 0.05;
static NSInteger _calendarTopMultiplier = 10;
static CGFloat _calendarBottomMultiplier = -0.1;

@implementation CalendarViewController {
    NSCalendar *_gregorian;
    FSCalendar *_calendarView;
    BOOL _isCurMonth;
    NSMutableDictionary *_dictOfPosts;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCache];
    self.tabBarController.delegate = self;
    [self initializeFields];
    [self setupCalendarView];
    [self setupCalendarImage];
    [self setConstraints];
}

-(void)setupCache {
    if (![[CacheManager sharedManager] hasCached]) {
        [[ParseCalendarAPIManager sharedManager] fetchCalendarDataWithCompletion:PFUser.currentUser date:[NSDate date] completion:^(NSArray * _Nonnull posts, NSError * _Nonnull error) {
            if (!error) {
                [[CacheManager sharedManager] cacheMonth:posts];
                [self->_calendarView reloadData];
            }
        }];
    }
}

-(void)initializeFields {
    _isCurMonth = YES;
    _dictOfPosts = [[NSMutableDictionary alloc] init];
    _gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
}

-(void)setupCalendarView {
    _calendarView.adjustsBoundingRectWhenChangingMonths = YES;
    _calendarView = [[FSCalendar alloc] initWithFrame:CGRectZero];
    _calendarView.dataSource = self;
    _calendarView.delegate = self;
    [self.view addSubview:_calendarView];
}

-(void)setupCalendarImage{
    _calendarView.appearance.titleFont = [UIFont fontWithName:@"VirtuousSlabRegular" size:_titleFont];
    _calendarView.appearance.headerTitleFont = [UIFont fontWithName:@"VirtuousSlabBold" size:_headerFont];
    _calendarView.appearance.weekdayFont = [UIFont fontWithName:@"VirtuousSlabBold" size:_weekdayFont];
    _calendarView.appearance.todayColor = [UIColor systemBrownColor];
    _calendarView.appearance.titleTodayColor = [UIColor whiteColor];
    _calendarView.appearance.titleDefaultColor = [UIColor systemBrownColor];
    _calendarView.appearance.weekdayTextColor = [UIColor systemBrownColor];
    _calendarView.appearance.headerTitleColor = [UIColor systemBrownColor];
    _calendarView.calendarHeaderView.backgroundColor = [[UIColor colorWithRed:[[ColorManager sharedManager] getCurrColor] green:[[ColorManager sharedManager] getCurrColor] blue:[[ColorManager sharedManager] getOtherColor] alpha:[[ColorManager sharedManager] getCurrColor]] colorWithAlphaComponent:_headerAlphaColor];
    _calendarView.calendarWeekdayView.backgroundColor = [[UIColor colorWithRed:[[ColorManager sharedManager] getCurrColor] green:[[ColorManager sharedManager] getCurrColor] blue:[[ColorManager sharedManager] getOtherColor] alpha:[[ColorManager sharedManager] getCurrColor]] colorWithAlphaComponent:_weekdayAlphaColor];
    _calendarView.placeholderType = FSCalendarPlaceholderTypeNone;
    [_calendarView registerClass:[CalendarCell class] forCellReuseIdentifier:@"CalendarCell"];
}

-(void)setConstraints {
    [_calendarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_calendarView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:_borderSpace].active = YES;
    [self.view.rightAnchor constraintEqualToAnchor:_calendarView.rightAnchor constant:_borderSpace].active = YES;
    [_calendarView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor  constant:self.view.frame.size.height * -_calendarBottomMultiplier].active = YES;
    [_calendarView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:_borderSpace * _calendarTopMultiplier].active = YES;
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated {
    [self.view layoutIfNeeded];
}

- (FSCalendarCell *)calendar:(FSCalendar *)calendar cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    CalendarCell *cell = [_calendarView dequeueReusableCellWithIdentifier:@"CalendarCell" forDate:date atMonthPosition:monthPosition];
    NSDate *newDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:date];
    [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay startDate:&newDate interval:NULL forDate:newDate];
    Post *currPost;
    if (_isCurMonth) {
        currPost = [[CacheManager sharedManager] getCachedPostForKey:newDate];
    } else {
        currPost = _dictOfPosts[newDate];
    }
    if (currPost) {
        NSString *stringImage = currPost.Image.url;
        NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: stringImage]];
        [cell setupCell:[UIImage imageWithData: imageData] withVideo1:currPost.Video withVideo2:currPost.Video2 withBool:currPost.isFrontCamInForeground];
    }
    return cell;
}

- (void)calendar:(FSCalendar *)calendar willDisplayCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition: (FSCalendarMonthPosition)monthPosition {
    [self configureCell:cell forDate:date atMonthPosition:monthPosition];
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar {
    NSDate *currMonth = _calendarView.currentPage;
    if ([self isSameMonth:currMonth otherDay:[NSDate date]]) {
        _isCurMonth = YES;
        [_calendarView reloadData];
    } else {
        [[ParseCalendarAPIManager sharedManager] fetchCalendarDataWithCompletion:[PFUser currentUser] date:currMonth completion:^(NSArray * _Nonnull posts, NSError * _Nonnull error) {
            for (Post *post in posts) {
                NSDate *startDay = post.createdAt;
                [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay startDate:&startDay interval:NULL forDate:startDay];
                self->_dictOfPosts[startDay] = post;
            }
            self->_isCurMonth = NO;
            [self->_calendarView reloadData];
        }];
    }
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date {
    if ([_gregorian isDateInToday:date]) {
        return @[[UIColor orangeColor]];
    }
    return @[appearance.eventDefaultColor];
}

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar {
    PFUser *user = [PFUser currentUser];
    NSDate *date = user.createdAt;
    return date;
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar {
    return [NSDate date];
}

- (void)configureVisibleCells {
    [_calendarView.visibleCells enumerateObjectsUsingBlock:^(__kindof FSCalendarCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *date = [_calendarView dateForCell:obj];
        FSCalendarMonthPosition position = [_calendarView monthPositionForCell:obj];
        [self configureCell:obj forDate:date atMonthPosition:position];
    }];
}

- (void)configureCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    CalendarCell *diyCell = (CalendarCell *)cell;
    // Custom today circle
    diyCell.circleImageView.hidden = ![_gregorian isDateInToday:date];
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    CalendarCell *cell = [self calendar:_calendarView cellForDate:date atMonthPosition:monthPosition];
    PFFileObject *video1 = cell.video1;
    PFFileObject *video2 = cell.video2;
    if (video1) {
        NSString *vid1StringUrl = video1.url;
        NSString *vid2StringUrl = video2.url;
        NSURL *vid1Url = [NSURL URLWithString: vid1StringUrl];
        NSURL *vid2Url = [NSURL URLWithString: vid2StringUrl];
        PlayVideoViewController *playVideoVC = [[PlayVideoViewController alloc] init];
        playVideoVC.vid1 = vid1Url;
        playVideoVC.vid2 = vid2Url;
        playVideoVC.isFrontCamInForeground = cell.isFrontCamInForeground;
        [[self navigationController] pushViewController:playVideoVC animated:YES];
    }
}

- (BOOL)isSameMonth:(NSDate*)date1 otherDay:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    return [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

- (BOOL)isSameDay:(NSDate*)date1 otherDay:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    return [comp1 day] == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

- (IBAction)didLogout:(id)sender {
    [[ParseConnectionAPIManager sharedManager] logout];
}

@end
