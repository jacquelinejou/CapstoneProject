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
#import "APIManager.h"
#import "CacheManager.h"
#import "AVKit/AVKit.h"

@interface CalendarViewController () <FSCalendarDataSource, FSCalendarDelegate, UITabBarControllerDelegate>
@end

@implementation CalendarViewController {
    NSCalendar *_gregorian;
    FSCalendar *_calendarView;
    CGFloat _borderSpace;
    BOOL _isCurMonth;
    NSMutableDictionary *_dictOfPosts;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCache];
    _borderSpace = 10.0;
    _isCurMonth = YES;
    _dictOfPosts = [[NSMutableDictionary alloc] init];
    self.tabBarController.delegate = self;
    _gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    _calendarView.adjustsBoundingRectWhenChangingMonths = YES;
    _calendarView = [[FSCalendar alloc] initWithFrame:CGRectZero];
    _calendarView.dataSource = self;
    _calendarView.delegate = self;
    [self.view addSubview:_calendarView];
    [self setupCalendarImage];
    [self _setConstraints];
}

-(void)setupCache {
    if (![[CacheManager sharedManager] hasCached]) {
        [[APIManager sharedManager] fetchCalendarDataWithCompletion:PFUser.currentUser date:[NSDate date] completion:^(NSArray * _Nonnull posts, NSError * _Nonnull error) {
            if (!error) {
                [[CacheManager sharedManager] cacheMonth:posts];
                [self->_calendarView reloadData];
            }
        }];
    }
}

-(void)setupCalendarImage{
    _calendarView.appearance.titleFont = [UIFont fontWithName:@"VirtuousSlabRegular" size:15];
    _calendarView.appearance.headerTitleFont = [UIFont fontWithName:@"VirtuousSlabBold" size:20];
    _calendarView.appearance.weekdayFont = [UIFont fontWithName:@"VirtuousSlabBold" size:16];
    _calendarView.appearance.todayColor = [UIColor systemBrownColor];
    _calendarView.appearance.titleTodayColor = [UIColor whiteColor];
    _calendarView.appearance.titleDefaultColor = [UIColor systemBrownColor];
    _calendarView.appearance.weekdayTextColor = [UIColor systemBrownColor];
    _calendarView.appearance.headerTitleColor = [UIColor systemBrownColor];
    _calendarView.calendarHeaderView.backgroundColor = [[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0] colorWithAlphaComponent:0.2];
    _calendarView.calendarWeekdayView.backgroundColor = [[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0] colorWithAlphaComponent:0.05];
    _calendarView.placeholderType = FSCalendarPlaceholderTypeNone;
    [_calendarView registerClass:[CalendarCell class] forCellReuseIdentifier:@"CalendarCell"];
}

-(void)_setConstraints {
    [_calendarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_calendarView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:_borderSpace].active = YES;
    [_calendarView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:_borderSpace * -1].active = YES;
    [_calendarView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:self.view.frame.size.height * -0.1].active = YES;
    [_calendarView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:_borderSpace * 10].active = YES;
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated {
    // Do other updates here
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
        [cell setupCell:[UIImage imageWithData: imageData] withVideo:currPost.Video];
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
        [[APIManager sharedManager] fetchCalendarDataWithCompletion:[PFUser currentUser] date:currMonth completion:^(NSArray * _Nonnull posts, NSError * _Nonnull error) {
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
    PFFileObject *pffile = cell.video;
    NSString *stringUrl = pffile.url;
    NSURL *url = [NSURL URLWithString: stringUrl];
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = [AVPlayer playerWithURL:url];
    [self presentViewController:playerViewController animated:YES completion:^{
        //Start Playback
        [playerViewController.player play];
    }];
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
    [[APIManager sharedManager] logout];
}

@end
