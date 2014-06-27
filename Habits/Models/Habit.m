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
#import <YLMoment.h>
#import "Calendar.h"
#import "HabitsList.h"

NSDateFormatter * dateKeyFormatter(){
    static NSDateFormatter * formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        formatter.dateFormat = @"yyyy-MM-dd";
    });
    return formatter;
}
NSString * dayKey(NSDate* date){
    return [dateKeyFormatter() stringFromDate:date];
}
NSDate * dateFromKey(NSString * key){
    return [dateKeyFormatter() dateFromString:key];
}
@implementation Habit


#pragma mark - MTLManagedObjectSerializing
+(NSString *)managedObjectEntityName{
    return @"Habit";
}
+(NSSet *)propertyKeysForManagedObjectUniquing{
    return [NSSet setWithObject:@"identifier"];
}
+(NSDictionary *)managedObjectKeysByPropertyKey{
    return @{
             @"notifications": [NSNull null]
             }; // mapping everything directly
}

#pragma mark - Individual state
-(BOOL)isRequiredToday{
    return [self isRequiredOnWeekday:[TimeHelper now]];
}
-(BOOL)done:(NSDate *)date{
    return [self.daysChecked[ dayKey(date) ] boolValue];
}
-(BOOL)due:(NSDate *)date{
    if(!self.isActive.boolValue) return NO;
    if(![self isRequiredOnWeekday:date]) return NO;
    if(!self.reminderTime) return NO;
    NSDateComponents * components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:date];
    return components.hour > self.reminderTime.hour && components.minute > self.reminderTime.minute;
}
-(BOOL)isRequiredOnWeekday:(NSDate *)date{
    return [self.daysRequired[[TimeHelper weekday:date]] boolValue];
}
-(BOOL)needsToBeDone:(NSDate *)date{
    return ![self done:date] && [self isRequiredOnWeekday:date];
}
-(BOOL)hasReminders{
    return self.reminderTime != nil;
}
-(BOOL)isNew{
    return [self.title isEqualToString:@"New Habit"]; // brittle
}
#pragma mark - Meta
-(NSDate*)earliestDate{
    if(self.daysChecked.count == 0) return [TimeHelper now];
    NSDate * date = dateFromKey( [[self.daysChecked.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] firstObject] );
    return date;
}
#pragma mark - Interactions
-(void)toggle:(NSDate *)date{
    NSString * key = dayKey(date);
    if (self.daysChecked[key]) {
        [self.daysChecked removeObjectForKey:key];
    }else{
        //TODO: change this to store the chain length
        self.daysChecked[key] = @YES;
    }
    [self recalculateLongestChain];
}
-(void)checkDays:(NSArray *)days{
    for(NSDate * date in days){
        NSString * key = dayKey(date);
        self.daysChecked[key] = @YES; // TODO: Change this to use numbers instead of BOOLs
    }
    [self recalculateLongestChain];
}
-(void)uncheckDays:(NSArray *)days{
    for(NSDate * date in days){
        NSString * key = dayKey(date);
        [self.daysChecked removeObjectForKey:key];
    }
    [self recalculateLongestChain];
}
#pragma mark - Chains
-(void)recalculateLongestChain{
    self.longestChain = @([self calculateChainLengthFindLongest:YES]);
}
-(NSInteger)currentChainLength{
    return [self calculateChainLengthFindLongest:NO];
}
-(NSInteger)calculateChainLengthFindLongest:(BOOL)shouldFindLongest{
    NSInteger result = 0;
    NSInteger count = 0;
    NSDate * earliestDate = [self earliestDate];
    NSDate * now = [TimeHelper now];
    YLMoment * lastDay = [[YLMoment momentWithDate:now] startOfCalendarUnit:NSDayCalendarUnit];
    while([lastDay.date timeIntervalSinceDate:earliestDate]  >= 0){
        if([self includesDate: lastDay.date]){
            count += 1;
        }
        if(![self continuesActivityBefore:lastDay.date]){
            if(!shouldFindLongest) return count;
            result = MAX(result,count);
        }
        
        [lastDay addAmountOfTime: -1 forCalendarUnit:NSDayCalendarUnit];
    }
    return MAX(result,count);
}

-(BOOL)continuesActivityBefore:(NSDate*)date{
    return [self continuesActivityFromDate:date step:-1 limit:7];
}
-(BOOL)continuesActivityAfter:(NSDate*)date{
    return [self continuesActivityFromDate:date step:1 limit:7];
}
-(BOOL)continuesActivityFromDate:(NSDate*)date step:(NSInteger)step limit:(NSInteger)limit{
    NSInteger index = 1;
    YLMoment * moment = [YLMoment momentWithDate:date];
    while (index++ < limit) {
        [moment addAmountOfTime:step forCalendarUnit:NSDayCalendarUnit];
        if([self includesDate:moment.date]) return YES;
        if([self isRequiredOnWeekday:moment.date]) return NO;
    }
    return NO;
}

-(BOOL)includesDate:(NSDate*)date{
    NSLog(@"Date: %@, key: %@", date, dayKey(date));
    return self.daysChecked[ dayKey(date) ] != nil;
}
#pragma mark - Data management
-(void)loadDefaultValues{
    self.identifier = [[NSUUID UUID] UUIDString];
    self.title = @"New Habit";
    self.color = [Colors colorsFromMotion][[HabitsList nextUnusedColorIndex]];
    self.isActive = @YES;
    self.daysRequired = [[Calendar days] map:^id(id obj) {
        return @YES;
    }].mutableCopy;
    self.daysChecked = [NSMutableDictionary new];
}
-(void)save{
    [HabitsList saveAll];
}
#pragma mark - Helper
+(NSDate*)dateFromString:(NSString*)date{
    return dateFromKey(date);
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
        NSDate * date = [TimeHelper addDays:dayOffset toDate:now];
        if([self isRequiredOnWeekday:date]){
            UILocalNotification * notification = [UILocalNotification new];
            notification.fireDate = date;
            notification.alertBody = self.title;
            notification.repeatInterval = NSWeekCalendarUnit;
            [self.notifications addObject: notification];
        }
    }
}
@end
