//
//  Habit.m
//  Habits
//
//  Created by Michael Forrest on 27/04/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "Habit.h"
#import <NSArray+F.h>
#import <NSNumber+F.h>
#import <NSDictionary+F.h>
#import "Colors.h"
#import "TimeHelper.h"
#import "Calendar.h"
#import "HabitsQueries.h"
#import <AVHexColor.h>
#import "Chain.h"
#import "HabitToggler.h"

@implementation Habit
@dynamic identifier,title,color,createdAt,reminderTime,isActive,order,daysRequired,chains,failures;
@synthesize notifications;
#pragma mark - Individual state
-(BOOL)isRequiredToday{
    return [self isRequiredOnWeekday:[TimeHelper today]];
}
-(BOOL)done:(NSDate *)date{
    date = [TimeHelper startOfDayInUTC:date];
    return [[[self chainForDate:date] lastDateCache] isEqualToDate:date];
}
-(BOOL)due:(NSDate *)date{
    date = [TimeHelper startOfDayInUTC:date];
    if(!self.isActive.boolValue) return NO;
    if(![self isRequiredOnWeekday:date]) return NO;
    if(!self.reminderTime) return NO;
    NSDateComponents * components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    return components.hour > self.reminderTime.hour && components.minute > self.reminderTime.minute;
}
-(BOOL)isRequiredOnWeekday:(NSDate *)date{
    date = [TimeHelper startOfDayInUTC:date];
    return [self.daysRequired[[TimeHelper weekday:date]] boolValue];
}
-(BOOL)needsToBeDone:(NSDate *)date{
    date = [TimeHelper startOfDayInUTC:date];
    Failure * failure = [self existingFailureForDate:date];
    BOOL failedToday = failure && failure.active.boolValue;
    return ![self done:date] && [self isRequiredOnWeekday:date] && !failedToday;
}
-(BOOL)hasReminders{
    return self.reminderTime != nil;
}
-(BOOL)isNew{
    return [self.title isEqualToString:@"New Habit"]; // brittle
}
-(NSDate *)nextDayRequiredAfter:(NSDate *)date{
    date = [TimeHelper addDays:1 toDate:date];
    while(![self isRequiredOnWeekday:date]){
        date = [TimeHelper addDays:1 toDate:date];
    }
    return date;
}
-(void)ensureDayCheckedStateForDate:(NSDate *)date dayState:(DayCheckedState)dayCheckedState{
    Chain * chain = [self chainForDate:date];
    if(chain.dayState == dayCheckedState){
        return;
    }
    HabitToggler * toggler = [[HabitToggler alloc] initWithNotifications:NO];
    NSDate * day = [TimeHelper startOfDayInUTC:date];
    if ([chain dayState] == dayCheckedState && [chain.lastDateCache isEqualToDate:day]){
        return; // might be wrong
    }
    NSInteger count = DayCheckedStateCount; // just because I don't know what could go wrong with this while loop
    while([toggler toggleHabit:self day:day] != dayCheckedState){
        count --;
        if (count <= 0){
            break;
        }
    }
}

#pragma mark - Meta
-(NSDate*)earliestDate{
    Chain * chain = self.sortedChains.firstObject;
    HabitDay * firstDay = chain.sortedDays.firstObject;
    return firstDay.date;
}
#pragma mark - Interactions



#pragma mark - Chains
-(Chain *)addNewChainInContext:(NSManagedObjectContext *)context{
    Chain * result = [NSEntityDescription insertNewObjectForEntityForName:@"Chain" inManagedObjectContext:context];
    result.daysRequired = self.daysRequired;
    Habit * habitInContext = (Habit*) [context objectWithID:self.objectID];
    [habitInContext addChainsObject:result];
    return result;
}
-(Chain *)addNewChain{
    return [self addNewChainInContext:[CoreDataClient defaultClient].managedObjectContext];
}
-(Chain*)addNewChainForToday{
    Chain * chain = [self addNewChain];
    chain.firstDateCache = [TimeHelper today];
    chain.lastDateCache = [TimeHelper today];
    chain.daysCountCache = @0;
    return chain;
}
-(NSArray *)sortedChains{
    return [self.chains sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastDateCache" ascending:YES]]];
}
-(Chain*)longestChain{
    return [[self.chains sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"daysCountCache" ascending:YES]]] lastObject];
}
-(NSInteger)currentChainLength{
    return [self.currentChain.daysCountCache integerValue];
}
-(Chain *)currentChain{
    return self.sortedChains.lastObject;
}
-(Chain *)chainForDate:(NSDate *)date{  
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"firstDateCache <= %@", date];
    NSArray * chains = [self.sortedChains filteredArrayUsingPredicate:predicate];
    Chain * lastObject = chains.lastObject;
    if(chains.count == 0 ){
        Chain * chain = [self addNewChain];
        chain.firstDateCache = date;
        chain.lastDateCache = date;
        chain.daysCountCache = @0;
        return chain;
    }else{
        return lastObject;
    }
}
#pragma mark - Failures
-(Failure*)existingFailureForDate:(NSDate*)date;
{
    NSSet * results = [self.failures filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"date == %@", date]];
    assert(results.count <= 1);
    return results.anyObject;
}
-(Failure*)createFailureForDate:(NSDate*)date;
{
    Failure * failure = [NSEntityDescription insertNewObjectForEntityForName:@"Failure" inManagedObjectContext:[CoreDataClient defaultClient].managedObjectContext];
    failure.date = date;
    failure.active = @YES;
    [self addFailuresObject:failure];
    return failure;
}

-(void)recalculateRunningTotalsInBackground:(void (^)())completionCallback{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext * privateContext = [[CoreDataClient defaultClient] createPrivateContext];
        Habit * habit = (Habit*)[privateContext objectWithID:self.objectID];
        for (Chain * chain in habit.chains) {
            [chain.sortedDays enumerateObjectsUsingBlock:^(HabitDay *day, NSUInteger index, BOOL *stop) {
                day.runningTotalCache = @(index);
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError * error;
            [privateContext save:&error];
            if(error) NSLog(@"Error saving private context %@", error.localizedDescription);
            completionCallback();
        });
    });

}

#pragma mark - Data management
+(Habit *)createNew{
    NSManagedObjectContext * context = [CoreDataClient defaultClient].managedObjectContext;
    Habit * result = [NSEntityDescription insertNewObjectForEntityForName:@"Habit" inManagedObjectContext:context];
    result.createdAt = [NSDate date];
    result.title = @"New Habit";
    result.color = [Colors colorsFromMotion][[HabitsQueries nextUnusedColorIndex]];
    result.isActive = @YES;
    result.daysRequired = [[Calendar days] map:^id(id obj) {
        return @YES;
    }].mutableCopy;
    return result;
}
#pragma mark - Notifications

#define TOMORROW 1
#define TODAY 0
-(void)recalculateNotifications{
    self.notifications = @[].mutableCopy;
    if (!self.hasReminders) return;
    NSDate * now = [TimeHelper now];
    NSInteger dayOffset = ([self due:now] || [self done:now]) ? TOMORROW : TODAY;
    for(int n = 0; n < 7; n ++){
        Moment * moment =[Moment momentWithDate: [TimeHelper addDays:dayOffset + n toDate:now]];
        if([self isRequiredOnWeekday:moment.date]){
            UILocalNotification * notification = [UILocalNotification new];
            NSDateComponents * components = self.reminderTime.copy;
            components.year = moment.year;
            components.month = moment.month;
            components.day = moment.day;
            notification.fireDate = [[NSCalendar currentCalendar] dateFromComponents:components];
            notification.alertBody = self.title;
            notification.repeatInterval = NSCalendarUnitWeekday; // FIXME: is this right?
            notification.category = @"Checkable";
            notification.userInfo = @{
                                      @"identifier": self.identifier
                                      };
            [self.notifications addObject: notification];
        }
    }
}
@end
