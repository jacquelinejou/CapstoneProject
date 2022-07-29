//
//  CalendarViewController.m
//  Capstone
//
//  Created by jacquelinejou on 7/6/22.
//

#import "CalendarViewController.h"
#import <Parse/Parse.h>
#import "WelcomeViewController.h"
#import "SceneDelegate.h"
#import "FSCalendar.h"
#import "CalendarCell.h"
#import "Post.h"

@interface CalendarViewController () <FSCalendarDataSource, FSCalendarDelegate, UITabBarControllerDelegate>
@property (strong, nonatomic) NSCalendar *gregorian;
- (void)configureCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position;
@end

@implementation CalendarViewController {
    FSCalendar *_calendarView;
    CGFloat borderSpace;
    BOOL isFirstCell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    borderSpace = 10.0;
    isFirstCell = YES;
    self.tabBarController.delegate = self;
    self.gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    _calendarView.adjustsBoundingRectWhenChangingMonths = YES;
    _calendarView = [[FSCalendar alloc] initWithFrame:CGRectZero];
    _calendarView.dataSource = self;
    _calendarView.delegate = self;
    [self.view addSubview:_calendarView];
    [self setupCalendarImage];
    [self _setConstraints];
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
    [_calendarView registerClass:[CalendarCell class] forCellReuseIdentifier:@"CalendarCell"];
}

-(void)_setConstraints {
    [_calendarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_calendarView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:borderSpace].active = YES;
    [_calendarView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:borderSpace * -1].active = YES;
    [_calendarView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:borderSpace * -6].active = YES;
    [_calendarView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:borderSpace * 10].active = YES;
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated {
    // Do other updates here
    [self.view layoutIfNeeded];
}

- (FSCalendarCell *)calendar:(FSCalendar *)calendar cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    CalendarCell *cell = [_calendarView dequeueReusableCellWithIdentifier:@"CalendarCell" forDate:date atMonthPosition:monthPosition];
    NSDate *newDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:date];
    [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay startDate:&newDate interval:NULL forDate:newDate];
    if (self.currMonthDictOfPosts[newDate]) {
        [cell setupCell:self.currMonthDictOfPosts[newDate]];
    }
    return cell;
}

- (void)calendar:(FSCalendar *)calendar willDisplayCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition: (FSCalendarMonthPosition)monthPosition {
    [self configureCell:cell forDate:date atMonthPosition:monthPosition];
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar {
    self.currMonthDictOfPosts = [[NSMutableDictionary alloc] init];
    for (NSDate *date in self.dictOfPosts) {
        if ([self isSameMonth:date otherDay:_calendarView.currentPage]) {
            self.currMonthDictOfPosts[date] = self.dictOfPosts[date];
        }
    }
    [_calendarView reloadData];
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date {
    if ([self.gregorian isDateInToday:date]) {
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
    diyCell.circleImageView.hidden = ![self.gregorian isDateInToday:date];
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
}

-(void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
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
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        SceneDelegate *mySceneDelegate = (SceneDelegate * ) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WelcomeViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeView"];
        mySceneDelegate.window.rootViewController = welcomeViewController;
    }];
}

@end
