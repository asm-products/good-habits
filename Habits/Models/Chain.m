//
//  Chain.m
//  Habits
//
//  Created by Michael Forrest on 22/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "Chain.h"
#import "Habit.h"
#import "TimeHelper.h"

@implementation Chain
@dynamic notes,explicitlyBroken,days,habit,breakDetected,daysCountCache,lastDateCache;
-(BOOL)isBroken{
    NSLog(@"isBroken needs implementing!");
    return YES;
}
#pragma mark - chain manipulation
-(Chain *)chainByJoiningChain:(Chain *)chain{
    // add other chain's days to this chain
    // delete the other chain
    NSLog(@"chainByJoiningChain: needs implementing!");
    return nil;
}
-(NSArray *)chainsBySplittingAtDay:(HabitDay *)day{
    // remove days after `day`
    // create a new chain
    // add removed chains
    NSLog(@"chainsBySplittingAtDay:day: needs implementing!");
    return nil;
}
#pragma mark - sugar
-(NSArray *)sortedDays{
    return [self.days sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
}
-(NSInteger)length{
    return [self.days count];
}
-(NSDate *)nextRequiredDate{
    NSDate * result;
    HabitDay * lastDay = self.sortedDays.lastObject;
    for (NSInteger i = 0; i < 7; i++) {
        result = [TimeHelper addDays:i toDate:lastDay.date];
        if([self.habit isRequiredOnWeekday:result]){
            return result;
        }
    }
    // just spotted a crash - what if somebody unchecks all the days of the week?
    return nil;
}
-(NSDate *)startDate{
    return [[self.sortedDays firstObject] date];
}
-(HabitDay*)habitDayForDate:(NSDate*)date{
    return nil;
}
#pragma mark - Interaction
-(DayCheckedState)stepToNextStateForDate:(NSDate *)date{
    HabitDay * existingDay = [self habitDayForDate:date];
    if(existingDay == nil && self.explicitlyBroken == nil){
        HabitDay * habitDay = [NSEntityDescription insertNewObjectForEntityForName:@"HabitDay" inManagedObjectContext:self.managedObjectContext];
        habitDay.date = date;
        [self addDaysObject:habitDay];
//        TODO: save
        return DayCheckedStateComplete;
    }else if(!self.explicitlyBroken){
        [self removeDaysObject:existingDay];
        self.explicitlyBroken = @YES;
        // TODO: save
        return DayCheckedStateBroken;
    }else{
        self.explicitlyBroken = nil;
        // TODO: save
        return DayCheckedStateNull;
    }
}
@end
