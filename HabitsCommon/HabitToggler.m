//
//  HabitToggler.m
//  Habits
//
//  Created by Michael Forrest on 11/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

#import "HabitToggler.h"
#import "TimeHelper.h"
#import "Failure.h"
#import "CoreDataClient.h"
#import "HabitsQueries.h"

@implementation HabitToggler
-(instancetype)init{
    if(self = [super init]){
        self.shouldNotify = YES;
    }
    return self;
}
-(instancetype)initWithNotifications:(BOOL)shouldNotify{
    if(self = [super init]){
        self.shouldNotify = shouldNotify;
    }
    return self;
}
-(DayCheckedState)toggleTodayForHabit:(Habit*)habit{
    return [self toggleHabit:habit day:[TimeHelper today]];
}
-(DayCheckedState)toggleHabit:(Habit*)habit day:(NSDate*) day{
    
    Failure * failure = [habit existingFailureForDate:day];
    Chain * chain = [habit chainForDate:day]; // should never be nil; lazily created if habit has no chains
    HabitDay * habitDay = [chain habitDayForDate:day];
    DayCheckedState state;
    if(failure && failure.active.boolValue){ // we had a failure so uncheck it
        failure.active = @NO;
        state = DayCheckedStateNull;
    }else if(habitDay){ // we had a day so turn it into a failure
        [chain removeDaysObject:habitDay];
        chain.lastDateCache = [chain.sortedDays.lastObject valueForKey:@"date"];
        chain.daysCountCache = @(chain.days.count);
        if(chain.days.count == 0) [habit removeChainsObject:chain];
        if(!failure){
            failure = [habit createFailureForDate:day];
        }else{
            failure.active = @YES;
        }
        state = DayCheckedStateBroken;
    }else if(habitDay == nil){ // we need to add a check for today
        BOOL dateIsTooLateForExistingChain = chain.days.count > 0 && (day.timeIntervalSinceReferenceDate > chain.nextRequiredDate.timeIntervalSinceReferenceDate);
        if(dateIsTooLateForExistingChain){
            chain = [habit addNewChainForToday];
        }
        state = [chain tickLastDayInChainOnDate:day];
    }
    [[CoreDataClient defaultClient] save];
    self.failure = failure;
    if(self.shouldNotify){
        if(state == DayCheckedStateComplete) [[NSNotificationCenter defaultCenter] postNotificationName:TODAY_CHECKED_FOR_CHAIN object:chain];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHAIN_MODIFIED object:chain userInfo:nil];
        NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.goodtohear.habits"];
        [defaults setObject:[NSDate date] forKey:@"updatedDate"];
        
        [defaults synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:HABIT_TOGGLE_COMPLETE object:nil];
    }
    return state;
}
@end
