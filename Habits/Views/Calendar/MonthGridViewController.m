//
//  MonthGridViewController.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "MonthGridViewController.h"
#import "CalendarDayView.h"
#import "Calendar.h"
#import "TimeHelper.h"
#import <YLMoment.h>
#import "HabitsQueries.h"
#import "DayKeys.h"
#import "HabitDay.h"
#import "Chain.h"
#import "HabitDayQueries.h"
#import <SVProgressHUD.h>
#define CELL_SIZE CGSizeMake(45, 44)
#define CELL_COUNT (7*5)

@interface MonthGridViewController (){
    dispatch_queue_t queue;
    NSMutableArray * cells;
    BOOL togglingOn;
}

@end

@implementation MonthGridViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    queue = dispatch_queue_create("goodtohear.habits.calendar", DISPATCH_QUEUE_CONCURRENT);
    CGPoint nextPoint = CGPointZero;
    cells = [[NSMutableArray alloc] initWithCapacity:CELL_COUNT];
    NSDateComponents * components = [NSDateComponents new];
    for (int gridIndex = 0; gridIndex < CELL_COUNT; gridIndex ++) {
        components.day = gridIndex;
        assert(self.firstDay);
        NSDate * day = [[TimeHelper UTCCalendar] dateByAddingComponents:components toDate:self.firstDay options:0];
        CalendarDayView * cell = [[CalendarDayView alloc] initWithFrame:CGRectMake(nextPoint.x + 1, nextPoint.y, CELL_SIZE.width, 43)];
        cell.day = day;
        cell.label.text = [[self dayFormatter] stringFromDate:day];
        [self.view addSubview:cell];
        [cells addObject:cell];
        nextPoint.x += cell.frame.size.width;
        if(nextPoint.x + CELL_SIZE.width > self.view.frame.size.width){
            nextPoint.x = 0;
            nextPoint.y += CELL_SIZE.height;
        }
    }
    [self addGestures];
}
-(NSDateFormatter*)dayFormatter{
    static NSDateFormatter * formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"d";
        formatter.calendar = [TimeHelper UTCCalendar];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });
    return formatter;
}
-(void)showChainsForHabit:(Habit*)habit callback:(void(^)())callback{
    for (CalendarDayView * cell in cells) {
        [cell setSelectionState:CalendarDayStateFuture color:habit.color];
    }
    
    
    self.habit = habit;
    CalendarDayView * firstCell = cells.firstObject;
    CalendarDayView * lastCell = cells.lastObject;
    NSArray * days = [HabitDayQueries daysForHabit:habit betweenDate:firstCell.day andDate:lastCell.day];
    NSSet * chains = [NSSet setWithArray:[days valueForKey:@"chain"]];
    Chain * chainOverlappingFirstDay;
    for (Chain * chain in chains) {
        if([chain overlapsDate: firstCell.day]){
            chainOverlappingFirstDay = chain;
        }
    }
    
    CalendarDayState previousState = chainOverlappingFirstDay ? CalendarDayStateFirstInChain : CalendarDayStateBeforeStart;
    
    for (NSInteger gridIndex = 0; gridIndex < CELL_COUNT; gridIndex ++) {
        CalendarDayView * cell = cells[gridIndex];
        NSInteger dayIndex = [days indexOfObjectPassingTest:^BOOL(HabitDay * day, NSUInteger idx, BOOL *stop) {
            return [day.date isEqualToDate:cell.day];
        }];
        if(dayIndex == NSNotFound){
            cell.accessibilityLabel = [[TimeHelper accessibilityDateFormatter] stringFromDate:cell.day];
            if (( previousState == CalendarDayStateMidChain || previousState == CalendarDayStateFirstInChain)) {
                [cell setSelectionState:CalendarDayStateBetweenSubchains color:habit.color];
            }
        }else{
            HabitDay * habitDay = days[dayIndex];
            cell.habitDay = habitDay;
            [cell setSelectionState:habitDay.dayState color:habit.color];
            cell.accessibilityLabel = [NSString stringWithFormat:@"%@, %@", [[TimeHelper accessibilityDateFormatter] stringFromDate:cell.day], [Calendar labelForState:habitDay.dayState] ];
            previousState = habitDay.dayState;
        }
    }
//    for (Chain * chain in chains) {
//        if(chain.isBroken){
//            NSInteger cellIndex = [cells indexOfObjectPassingTest:^BOOL(CalendarDayView*cell, NSUInteger idx, BOOL *stop) {
//                return [cell.day isEqualToDate:[chain nextRequiredDate]];
//            }];
//            if(cellIndex != NSNotFound){
//                CalendarDayView * cell = cells[cellIndex];
//                [cell setSelectionState:CalendarDayStateBrokenChain color:habit.color];
//                cell.accessibilityLabel = [NSString stringWithFormat:@"%@, %@", [[TimeHelper accessibilityDateFormatter] stringFromDate:cell.day], [Calendar labelForState:CalendarDayStateBrokenChain] ];
//            }
//        }
//    }
}

+(BOOL)isFutureDate:(NSDate*)date{
    return [[TimeHelper today] timeIntervalSinceDate:date] < 0;
}
#pragma mark - Interaction
-(void)addGestures{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:tap];
}
-(void)tapped:(UITapGestureRecognizer*)tap{
    CGPoint location = [tap locationInView:self.view];
    UIView * subview = [self.view hitTest:location withEvent:nil];
    if(subview.class == [CalendarDayView class]){
        CalendarDayView * cell = (CalendarDayView*)subview;
        if([[self class] isFutureDate:cell.day]) return;
        Chain * chain = [self.habit chainForDate:cell.day];
        
        [chain toggleDayInCalendarForDate:cell.day];
        [self showChainsForHabit:self.habit callback:nil];

        [self.habit recalculateRunningTotalsInBackground:^{
        }];
        
        
    }
}
@end
