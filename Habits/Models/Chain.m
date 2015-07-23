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
#import "CoreDataClient.h"

@implementation Chain
@dynamic days,habit,breakDetected,daysCountCache,lastDateCache,firstDateCache,daysRequired;
-(BOOL)isBroken{
    return self.countOfDaysOverdue > 0;
}
-(void)save{
    [[CoreDataClient defaultClient].managedObjectContext save:nil];
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
    if(self.days.count == 0 && self.habit.chains.count == 1) return [TimeHelper today];
    HabitDay * lastDay = self.sortedDays.lastObject;
    if (self.days.count == 0) {
        return [TimeHelper today];
    }
    for (NSInteger i = 1; i < 8; i++) {
        result = [TimeHelper addDays:i toDate:lastDay.date];
        if([self.habit isRequiredOnWeekday:result]){
            return result;
        }
    }
    // just spotted a crash - what if somebody unchecks all the days of the week?
    return nil;
}
-(NSInteger)countOfDaysOverdue{
    NSDateComponents * components = [[TimeHelper UTCCalendar] components:NSDayCalendarUnit fromDate:self.nextRequiredDate toDate:[TimeHelper today] options:0];
    return components.day;
}
-(NSDate *)startDate{
    return self.firstDateCache;
}
-(HabitDay*)habitDayForDate:(NSDate*)date{
    return [self.days filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"date == %@", date]].anyObject;
}
-(BOOL)overlapsDate:(NSDate *)date{
    NSTimeInterval dateInterval = date.timeIntervalSinceReferenceDate;
    return dateInterval >= self.startDate.timeIntervalSinceReferenceDate && dateInterval <= self.lastDateCache.timeIntervalSinceReferenceDate;
}
-(BOOL)isRecord{
    NSInteger currentChainLength = self.currentChainLengthForDisplay;
    return currentChainLength >= 28 && currentChainLength == self.habit.longestChain.daysCountCache.integerValue;
}
-(NSInteger)currentChainLengthForDisplay{
    NSInteger countOfDaysOverdue = self.countOfDaysOverdue;
    NSInteger currentChainLength = countOfDaysOverdue > 0 ? -(countOfDaysOverdue) : self.length;
    return currentChainLength;
}
-(DayCheckedState)revertToNullStateForToday{
    NSLog(@"Clearing explicit break on %@ from %@", self.habit.title, self.firstDateCache);
    return DayCheckedStateNull;
}
-(DayCheckedState)createNewChainAndCheckDate:(NSDate*)date{
    Chain * chain = [self.habit addNewChainForToday];
    [chain tickLastDayInChainOnDate:date];
    return DayCheckedStateComplete;
}
-(DayCheckedState)uncheckDay:(HabitDay*)existingDay andBreakChain:(NSDate*)date{
    [self removeDaysObject:existingDay];
    Chain * chain = self;
    Habit * habit = chain.habit;
    if(self.days.count == 0){
        [self.habit removeChainsObject:self];
        chain = [habit chainForDate:date];
    }
    chain.lastDateCache = chain.days.count > 0 ? [chain.sortedDays.lastObject date] : [TimeHelper today];
    if(chain.countOfDaysOverdue < 2){
        NSLog(@"Explicitly breaking %@ chain from %@", chain.habit.title, chain.firstDateCache);
        return DayCheckedStateBroken;
    }else{
        return DayCheckedStateNull;
    }
}
-(DayCheckedState)toggleDayInCalendarForDate:(NSDate *)date{
    HabitDay * existingDay = [self habitDayForDate:date];
    DayCheckedState result;
    BOOL dateIsAtEndOfChain = (self.days.count > 0 && ( [date isEqualToDate:self.lastDateCache] || date.timeIntervalSinceReferenceDate >= self.nextRequiredDate.timeIntervalSinceReferenceDate)) || self.days.count == 0 ;
    BOOL dateIsTooLateForThisChain = self.days.count > 0 && (date.timeIntervalSinceReferenceDate > self.nextRequiredDate.timeIntervalSinceReferenceDate);
    if (existingDay == nil) { // only happens if day was not required
        if(dateIsAtEndOfChain){
            if(dateIsTooLateForThisChain){
                Chain * chain = [self.habit addNewChain];
                [chain tickLastDayInChainOnDate:date];
            }else{
                [self tickLastDayInChainOnDate:date];
            }
        }else{
            [self createHabitDayAtDate:date];
        }
    }else{
        if(self.days.count == 1) {
            // delete this chain
            [self.habit removeChainsObject:self];
            
        }else if(dateIsAtEndOfChain){
            [self removeDaysObject:existingDay];
            self.lastDateCache = [self.sortedDays.lastObject date];
        }else{
            result = [self handleMidChainDeletionForHabitDay:existingDay date:date];
        }
    }
    [[CoreDataClient defaultClient].managedObjectContext save:nil];
    return result;
}
-(void)createHabitDayAtDate:(NSDate*)date{
    HabitDay * habitDay = [NSEntityDescription insertNewObjectForEntityForName:@"HabitDay" inManagedObjectContext:self.managedObjectContext];
    habitDay.date = date;
    habitDay.runningTotalCache = @(self.days.count);
    [self addDaysObject:habitDay];
    self.daysCountCache = @(self.days.count);
}
-(DayCheckedState)tickLastDayInChainOnDate:(NSDate*)date{
    [self createHabitDayAtDate:date];
    self.lastDateCache = date;
    
    
    NSDate * nextRequiredDate = self.nextRequiredDate;
    Chain * chain = [self.habit chainForDate:nextRequiredDate];
    if(chain != self){
        NSSet * nextChainDays = chain.days;
        [self.habit removeChainsObject:chain]; // wondering if the cascade thing will hurt me here.
        NSInteger runningTotal = self.days.count;
        for (HabitDay * day in [nextChainDays sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES ]]]) {
            runningTotal ++;
            day.runningTotalCache = @(runningTotal);
        }
        [self addDays:nextChainDays];
    }
    
    self.daysCountCache = @(self.days.count);
    self.lastDateCache = [self.sortedDays.lastObject date];
    
    
    return DayCheckedStateComplete;
}
-(DayCheckedState)handleMidChainDeletionForHabitDay:(HabitDay*)existingDay date:(NSDate*)date{
    if ([self.habit isRequiredOnWeekday:date]) {
        NSArray * sortedDays = self.sortedDays;
        
        if(sortedDays.count == 2){
            // remove the day, update the caches, return
            [self removeDaysObject:existingDay];
            self.lastDateCache = self.firstDateCache = [self.days.anyObject date];
        }else{
            // need to split the chain in two
            
            NSInteger index = [sortedDays indexOfObject:existingDay];
            NSArray * firstList  = [sortedDays subarrayWithRange:NSMakeRange(0, index )];
            NSArray * secondList = [sortedDays subarrayWithRange:NSMakeRange(index + 1, sortedDays.count - index - 1)];
            self.days = [NSSet setWithArray:firstList];
            Chain * chain = [self.habit addNewChain];
            chain.days = [NSSet setWithArray:secondList];
            chain.daysCountCache = @(secondList.count);
            
            chain.firstDateCache = [secondList.firstObject date];
            chain.lastDateCache = [secondList.lastObject date];

            self.lastDateCache = [firstList.lastObject date];
            self.daysCountCache = @(firstList.count);
            
            NSLog(@"Remaining days: %@", [secondList valueForKey:@"date"]);
        }
        
        return DayCheckedStateBroken;
    }else{
        [self removeDaysObject:existingDay];
        return DayCheckedStateNull;
    }

}
-(DayCheckedState)dayState{
    if([self.habit existingFailureForDate:[TimeHelper today]].active.boolValue){
        return DayCheckedStateBroken;
    }else if([self.lastDateCache isEqualToDate:[TimeHelper today]]){
        return self.days.count > 0 ? DayCheckedStateComplete : DayCheckedStateNull;
    }else{
        return DayCheckedStateNull;
    }
}
-(void)checkNextRequiredDate{
    if(self.nextRequiredDate.timeIntervalSince1970 >= [TimeHelper today].timeIntervalSince1970) return;
    [self createHabitDayAtDate:self.nextRequiredDate];
}
#pragma mark - Caches in case they didn't get set for whatever reason
-(NSNumber *)daysCountCache{
    NSNumber * result = [self primitiveValueForKey:@"daysCountCache"];
    if(result == nil) {
        result = @(self.days.count);
        [self setPrimitiveValue:result forKey:@"daysCountCache"];
    }
    return result;
}
-(NSDate *)firstDateCache{
    NSDate * result = [self primitiveValueForKey:@"firstDateCache"];
    if(result == nil){
        result = [self.sortedDays.firstObject date];
        [self setPrimitiveValue:result forKey:@"firstDateCache"];
    }
    return result;
}
-(NSDate *)lastDateCache{
    NSDate * result = [self primitiveValueForKey:@"lastDateCache"];
    if(result == nil){
        result = [self.sortedDays.lastObject date];
        [self setPrimitiveValue:result forKey:@"lastDateCache"];
    }
    return result;
}

@end
