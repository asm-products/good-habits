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
@dynamic notes,explicitlyBroken,days,habit,breakDetected,daysCountCache,lastDateCache,firstDateCache;
-(BOOL)isBroken{
    NSLog(@"isBroken needs implementing!");
    return self.explicitlyBroken.boolValue;
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
#pragma mark - Interaction
-(DayCheckedState)stepToNextStateForDate:(NSDate *)date{
    HabitDay * existingDay = [self habitDayForDate:date];
    DayCheckedState result;
    BOOL dateIsAtEndOfChain = [date isEqualToDate:self.lastDateCache] || date.timeIntervalSinceReferenceDate >= self.nextRequiredDate.timeIntervalSinceReferenceDate;
    if(dateIsAtEndOfChain && (self.days.count > 1 || existingDay == nil) ){
        // toggle check / explicit break / null:
        
#pragma mark - actions for last item in chain
        if(self.explicitlyBroken.boolValue == YES){
            // Was explicity broken - null out the broken
            self.explicitlyBroken = nil;
            result = DayCheckedStateNull;
         
        }else{
            if(existingDay == nil){
                // Tick the day
                result = [self tickLastDayInChainOnDate: date];
                
            }else{
                // Was checked - make explicitly broken.
                [self removeDaysObject:existingDay];
                self.lastDateCache = [self.sortedDays.lastObject date];
                self.explicitlyBroken = @YES;
                
                
                result = DayCheckedStateBroken;
            }
        }
    }else{
        // either split or join to another chain
        if (existingDay == nil) { // only happens if day was not required
            [self createHabitDayAtDate:date];
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
    [self addDaysObject:habitDay];
}
-(DayCheckedState)tickLastDayInChainOnDate:(NSDate*)date{
    [self createHabitDayAtDate:date];
    self.lastDateCache = date;
    
    
    NSDate * nextRequiredDate = self.nextRequiredDate;
    Chain * chain = [self.habit chainForDate:nextRequiredDate];
    if(chain != self){
        NSSet * nextChainDays = chain.days;
        [self.habit removeChainsObject:chain]; // wondering if the cascade thing will hurt me here.
         [self addDays:nextChainDays];
    }
    
    self.daysCountCache = @(self.days.count);
    
    
    
    return DayCheckedStateComplete;
}
-(DayCheckedState)handleMidChainDeletionForHabitDay:(HabitDay*)existingDay date:(NSDate*)date{
    if ([self.habit isRequiredOnWeekday:date]) {
        NSArray * sortedDays = self.sortedDays;
        
        if(sortedDays.count == 1) {
            // delete this chain
            [self.habit removeChainsObject:self];
            
        }else if(sortedDays.count == 2){
            // remove the day, update the caches, return
            [self removeDaysObject:existingDay];
            self.lastDateCache = self.firstDateCache = [self.days.anyObject date];
        }else{
            // need to split the chain in two
            
            NSInteger index = [sortedDays indexOfObject:existingDay];
            NSArray * firstList  = [sortedDays subarrayWithRange:NSMakeRange(0, index )];
            NSArray * secondList = [sortedDays subarrayWithRange:NSMakeRange(index + 1, sortedDays.count - index - 1)];
            self.days = [NSSet setWithArray:firstList];
            Chain * chain = [NSEntityDescription insertNewObjectForEntityForName:@"Chain" inManagedObjectContext:[CoreDataClient defaultClient].managedObjectContext];
            chain.days = [NSSet setWithArray:secondList];
            chain.daysCountCache = @(secondList.count);
            [self.habit addChainsObject:chain];
            
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

@end
