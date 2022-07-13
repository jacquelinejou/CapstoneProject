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

@interface CalendarViewController () <FSCalendarDataSource, FSCalendarDelegate>
@property (strong, nonatomic) NSCalendar *gregorian;
@property (nonatomic, strong) NSMutableArray *arrayOfPosts;
- (void)configureCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position;
@end

@implementation CalendarViewController {
    FSCalendar *_calendarView;
    CGFloat borderSpace;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    borderSpace = 10.0;
    self.gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    _calendarView = [[FSCalendar alloc] initWithFrame:CGRectZero];
    _calendarView.dataSource = self;
    _calendarView.delegate = self;
    _calendarView.swipeToChooseGesture.enabled = YES;
    UIPanGestureRecognizer *scopeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:_calendarView action:@selector(handleScopeGesture:)];
    [_calendarView addGestureRecognizer:scopeGesture];
    [self.view addSubview:_calendarView];
    [self setupCalendarImage];
    [self setConstraints];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.arrayOfPosts = (NSMutableArray *)posts;
            [self->_calendarView reloadData];
        }
    }];
}

-(void)setupCalendarImage{
    _calendarView.calendarHeaderView.backgroundColor = [[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.25] colorWithAlphaComponent:0.9];
    _calendarView.calendarWeekdayView.backgroundColor = [[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.25] colorWithAlphaComponent:0.2];
    [_calendarView registerClass:[CalendarCell class] forCellReuseIdentifier:@"CalendarCell"];
}

-(void)setConstraints {
    [_calendarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_calendarView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:borderSpace].active = YES;
    [_calendarView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:borderSpace * -1].active = YES;
    [_calendarView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:borderSpace * -2].active = YES;
    [_calendarView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:borderSpace * 10].active = YES;
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated {
    // Do other updates here
    [self.view layoutIfNeeded];
}

- (FSCalendarCell *)calendar:(FSCalendar *)calendar cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    CalendarCell *cell = [_calendarView dequeueReusableCellWithIdentifier:@"CalendarCell" forDate:date atMonthPosition:monthPosition];
    return cell;
}

- (void)calendar:(FSCalendar *)calendar willDisplayCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition: (FSCalendarMonthPosition)monthPosition {
    [self configureCell:cell forDate:date atMonthPosition:monthPosition];
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date {
    if ([self.gregorian isDateInToday:date]) {
        return @[[UIColor orangeColor]];
    }
    return @[appearance.eventDefaultColor];
}

- (void)configureVisibleCells {
    [_calendarView.visibleCells enumerateObjectsUsingBlock:^(__kindof FSCalendarCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *date = [_calendarView dateForCell:obj];
        FSCalendarMonthPosition position = [_calendarView monthPositionForCell:obj];
        [self configureCell:obj forDate:date atMonthPosition:position];
    }];
}

- (void)configureCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    
    CalendarCell *diyCell = (CalendarCell *)cell;
    
    // Custom today circle
    diyCell.circleImageView.hidden = ![self.gregorian isDateInToday:date];
    
    // Configure selection layer
    if (monthPosition == FSCalendarMonthPositionCurrent) {
        
        SelectionType selectionType = SelectionTypeNone;
        if ([_calendarView.selectedDates containsObject:date]) {
            NSDate *previousDate = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:date options:0];
            NSDate *nextDate = [self.gregorian dateByAddingUnit:NSCalendarUnitDay value:1 toDate:date options:0];
            if ([_calendarView.selectedDates containsObject:date]) {
                if ([_calendarView.selectedDates containsObject:previousDate] && [_calendarView.selectedDates containsObject:nextDate]) {
                    selectionType = SelectionTypeMiddle;
                } else if ([_calendarView.selectedDates containsObject:previousDate] && [_calendarView.selectedDates containsObject:date]) {
                    selectionType = SelectionTypeRightBorder;
                } else if ([_calendarView.selectedDates containsObject:nextDate]) {
                    selectionType = SelectionTypeLeftBorder;
                } else {
                    selectionType = SelectionTypeSingle;
                }
            }
        } else {
            selectionType = SelectionTypeNone;
        }
        
        if (selectionType == SelectionTypeNone) {
            diyCell.selectionLayer.hidden = YES;
            return;
        }
        
        diyCell.selectionLayer.hidden = NO;
        diyCell.selectionType = selectionType;
        
    } else {
        
        diyCell.circleImageView.hidden = YES;
        diyCell.selectionLayer.hidden = YES;
        
    }
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
