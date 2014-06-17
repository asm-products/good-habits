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
        NSDate * day = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.firstDay options:0];
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
    });
    return formatter;
}
-(NSDateFormatter*)accessibilityDateFormatter{
    static NSDateFormatter * formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"d MMMM";
    });
    return formatter;
}
-(void)showChainsForHabit:(Habit*)habit callback:(void(^)())callback{
    self.habit = habit;
    dispatch_async(queue, ^{
        for (int gridIndex = 0; gridIndex < CELL_COUNT; gridIndex ++) {
            CalendarDayView * cell = cells[gridIndex];
            CalendarDayState state = [MonthGridViewController cellStateForHabit:habit date: cell.day];
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell setSelectionState:state color: habit.color];
                cell.accessibilityLabel = [NSString stringWithFormat:@"%@, %@", [[self accessibilityDateFormatter] stringFromDate:cell.day], [Calendar labelForState:state] ];
            });
        }
        if(callback) dispatch_async(dispatch_get_main_queue(), callback);
    });

}
+(CalendarDayState)cellStateForHabit:(Habit*)habit date:(NSDate*)date{
    if(!date) return CalendarDayStateBeforeStart;
    if( [self isFutureDate:date] ) return CalendarDayStateFuture;
    NSDate * day = [[YLMoment momentWithDate:date] startOfCalendarUnit:NSDayCalendarUnit].date;
    NSDate * dayAfter = [TimeHelper addDays:1 toDate:day];
    if([habit includesDate: day]){
        BOOL isFirstInChain = ![habit continuesActivityBefore: day];
        BOOL isLastInChain = ![habit continuesActivityAfter:day] || [dayAfter timeIntervalSinceDate:[TimeHelper now]] > 0;
        BOOL alone = isFirstInChain && isLastInChain;
        if(alone) return CalendarDayStateAlone;
        if(isFirstInChain) return CalendarDayStateFirstInChain;
        if(isLastInChain) return CalendarDayStateLastInChain;
        return CalendarDayStateMidChain;
    }
    if([habit.earliestDate timeIntervalSinceDate:date] > 0) return CalendarDayStateBeforeStart;
    if(![habit isRequiredOnWeekday:date]){
        if([habit continuesActivityBefore:day] && [habit continuesActivityAfter:day]) return CalendarDayStateBetweenSubchains;
        return CalendarDayStateNotRequired;
    }
    return CalendarDayStateMissed;
}
+(BOOL)isFutureDate:(NSDate*)date{
    return [[TimeHelper now] timeIntervalSinceDate:date] < 0;
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
        togglingOn = ![self.habit includesDate:cell.day];
        [cell setSelectionState:togglingOn ? CalendarDayStateAlone : CalendarDayStateBeforeStart color:self.habit.color];
        if(togglingOn){
            [self.habit checkDays: @[cell.day]];
        }else{
            [self.habit uncheckDays: @[cell.day]];
        }
        [Habit saveAll];
        [self showChainsForHabit:self.habit callback:nil];
        
    }
}
@end
