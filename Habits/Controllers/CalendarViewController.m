//
//  CalendarViewController.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "CalendarViewController.h"
#import "CalendarTopView.h"
#import "TimeHelper.h"
#import "MonthGridViewController.h"
@interface CalendarViewController (){
    NSDate * dayInPreviousMonth;
    NSDate * dayInNextMonth;
    BOOL navigationIsDisabled;
}
@property (nonatomic, strong) CalendarTopView * top;
@property (nonatomic, strong) UIView * container;
@property (nonatomic, strong) MonthGridViewController * grid;
@end

@implementation CalendarViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizesSubviews = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.top = [[CalendarTopView alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
    [self.view addSubview:self.top];
    
    [self.top.prevButton addTarget:self action:@selector(didPressPrevButton) forControlEvents:UIControlEventTouchUpInside];
    [self.top.nextButton addTarget:self action:@selector(didPressNextButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 56, 320, 220)];
    [self.view addSubview:self.container];
    [self showMonthIncludingTime:self.dateToShow];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.habit) [self showChainsForHabit:self.habit];
}
-(void)didPressPrevButton{
    [self.navigationDelegate backward];
}
-(void)didPressNextButton{
    [self.navigationDelegate forward];
}
-(NSDateFormatter*)topTimeFormatter{
    static NSDateFormatter * result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [NSDateFormatter new];
        result.dateFormat = @"MMM yyyy";
    });
    return result;
}
-(void)showMonthIncludingTime:(NSDate*)time{
    NSInteger month = [Moment momentWithDate:time].month;
    if(self.grid && self.grid.month == month) return;
    if(self.grid.view.superview)[self.grid.view removeFromSuperview];
    self.grid = nil;
    
    self.top.label.text = [self.topTimeFormatter stringFromDate:time];
    Moment * moment = [Moment momentWithDate:time];
    
    // always work with GMT 
    moment.calendar = [TimeHelper UTCCalendar];
    NSDate * firstDay = [moment startOfCalendarUnit:NSCalendarUnitMonth].date;
    dayInPreviousMonth = [TimeHelper addDays:-10 toDate:firstDay];
    dayInNextMonth = [TimeHelper addDays:46 toDate:firstDay];
    NSInteger firstWeekdayForLocale = [NSCalendar currentCalendar].firstWeekday - 1;
    while ([TimeHelper weekdayIndex:firstDay] != firstWeekdayForLocale) {
        firstDay = [TimeHelper addDays: -1 toDate: firstDay];
    }
    NSLog(@"First day of calendar %@", firstDay);
    
    self.grid = [MonthGridViewController new];
    self.grid.firstDay = firstDay;
    self.grid.month = month;
    [self.container addSubview:self.grid.view];
//    if(self.habit) [self showChainsForHabit:self.habit];
    
}
-(NSDate *)dayInPreviousMonth{
    return dayInPreviousMonth;
}
-(NSDate *)dayInNextMonth{
    return dayInNextMonth;
}
-(void)showChainsForHabit:(Habit *)habit{
    self.habit = habit;
    navigationIsDisabled = YES;
    [self.grid showChainsForHabit:habit callback:^{
        navigationIsDisabled = NO;
    }];
}
@end
