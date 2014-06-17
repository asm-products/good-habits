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
#import <YLMoment.h>
#import "MonthGridViewController.h"
@interface CalendarViewController (){
    NSDate * dayInPreviousMonth;
    NSDate * dayInNextMonth;
    BOOL navigationIsDisabled;
}
@property (nonatomic, strong) CalendarTopView * top;
@property (nonatomic, strong) UIScrollView * scroller;
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
    
    self.scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 56, 320, 220)];
    [self.view addSubview:self.scroller];
    [self showMonthIncludingTime:[TimeHelper now]];
}
-(void)didPressPrevButton{
    if(!navigationIsDisabled) [self showMonthIncludingTime:dayInPreviousMonth];
}
-(void)didPressNextButton{
     if(!navigationIsDisabled) [self showMonthIncludingTime:dayInNextMonth];
}
-(NSDateFormatter*)topTimeFormatter{
    static NSDateFormatter * result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [NSDateFormatter new];
        result.dateFormat = @"MMM YYYY";
    });
    return result;
}
-(void)showMonthIncludingTime:(NSDate*)time{
    NSInteger month = [YLMoment momentWithDate:time].month;
    if(self.grid && self.grid.month == month) return;
    if(self.grid.view.superview)[self.grid.view removeFromSuperview];
    self.grid = nil;
    
    self.top.label.text = [self.topTimeFormatter stringFromDate:time];
    NSDate * firstDay = [[YLMoment momentWithDate:time] startOfCalendarUnit:NSMonthCalendarUnit].date;
    dayInPreviousMonth = [TimeHelper addDays:-10 toDate:firstDay];
    dayInNextMonth = [TimeHelper addDays:46 toDate:firstDay];
    
    while ([TimeHelper weekday:firstDay] != 0) {
        firstDay = [TimeHelper addDays: -1 toDate: firstDay];
    }
    
    self.grid = [MonthGridViewController new];
    self.grid.firstDay = firstDay;
    self.grid.month = month;
    [self.scroller addSubview:self.grid.view];
    if(self.habit) [self showChainsForHabit:self.habit];
    
}
-(void)showChainsForHabit:(Habit *)habit{
    self.habit = habit;
    navigationIsDisabled = YES;
    [self.grid showChainsForHabit:habit callback:^{
        navigationIsDisabled = NO;
    }];
}
@end
