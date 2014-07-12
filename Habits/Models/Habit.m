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
             @"notifications": [NSNull null],
             @"latestAnalysis": [NSNull null]
             
             }; // mapping everything directly
}
#pragma mark - MTLJSONSerializing
+(NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{@"createdAt": @"created_at",
             @"daysChecked":@"days_checked",
             @"reminderTime":@"reminder_time",
             @"isActive":@"active",
             @"daysRequired":@"days_required",
             @"longestChain":@"longest_chain",
             @"notifications": [NSNull null]
             };
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
-(NSDate *)nextDayRequiredAfter:(NSDate *)date{
    date = [TimeHelper addDays:1 toDate:date];
    while(![self isRequiredOnWeekday:date]){
        date = [TimeHelper addDays:1 toDate:date];
    }
    return date;
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
        self.daysChecked[key] = @(-1);
    }
    [self recalculateLongestChain];
}
-(void)checkDays:(NSArray *)days{
    for(NSDate * date in days){
        NSString * key = dayKey(date);
        self.daysChecked[key] = @(-1); // TODO: Change this to use numbers instead of BOOLs
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
    [self calculateChainLengthFindLongest:YES];
}
-(NSNumber *)longestChain{
    return [self.daysChecked.allValues reduce:^id(id memo, id obj) {
        NSInteger result = MAX([memo integerValue], [obj integerValue]);
        return @(result);
    } withInitialMemo:@0];
}
-(NSInteger)currentChainLength{
    return [self calculateChainLengthFindLongest:NO];
}
-(NSInteger)calculateChainLengthFindLongest:(BOOL)shouldFindLongest{
    NSLog(@"Recalculating %@ chain from earliestDate %@", self.title, self.earliestDate);
    NSInteger result = 0;
    NSInteger count = 0;
    NSDate * earliestDate = [self earliestDate];
    NSDate * now = [TimeHelper now];
    YLMoment * lastDay = [[YLMoment momentWithDate:earliestDate] startOfCalendarUnit:NSDayCalendarUnit];
    while([lastDay.date timeIntervalSinceDate:now]  < 0){
        if([self includesDate: lastDay.date]){
            count += 1;
            self.daysChecked[ dayKey(lastDay.date) ] = @(count);
        }
        if(![self continuesActivityAfter:lastDay.date]){
            if(!shouldFindLongest) return count;
            count = 0;
            result = MAX(result,count);
        }
        
        [lastDay addAmountOfTime: 1 forCalendarUnit:NSDayCalendarUnit];
    }
    return MAX(result,count);
}

-(NSDate*)continuesActivityBefore:(NSDate*)date{
    return [self continuesActivityFromDate:date step:-1 limit:8];
}
/**
 *  AKA 'chain continues unbroken after the start date'
 */
-(NSDate*)continuesActivityAfter:(NSDate*)date{
    return [self continuesActivityFromDate:date step:1 limit:8];
}
-(NSDate*)continuesActivityFromDate:(NSDate*)date step:(NSInteger)step limit:(NSInteger)limit{
    NSInteger index = 1;
    YLMoment * moment = [YLMoment momentWithDate:date];
    while (index++ < limit) {
        [moment addAmountOfTime:step forCalendarUnit:NSDayCalendarUnit];
        if([self includesDate:moment.date]) return moment.date;
        if([self isRequiredOnWeekday:moment.date]) return nil;
    }
    return nil;
}

-(BOOL)includesDate:(NSDate*)date{
    return self.daysChecked[ dayKey(date) ] != nil;
}
-(NSNumber*)chainLengthOnDate:(NSDate *)date{
    NSNumber* result = [self includesDate:date] ? self.daysChecked[ dayKey(date) ]  : nil;
    if(!result){
        NSDate * foundOnDate = [self continuesActivityBefore:date];
        if(foundOnDate) result = self.daysChecked[ dayKey(foundOnDate)  ];
    }
    return result;
}
#pragma mark - Data management
-(NSString *)title{
    _title = _title ?: @"New Habit"; return _title;
}
-(UIColor *)color{
    _color = _color ?: [Colors colorsFromMotion][[HabitsList nextUnusedColorIndex]]; return _color;
}
-(NSNumber *)isActive{
    _isActive = _isActive ?: @YES; return _isActive;
}
-(NSMutableArray *)daysRequired{
    _daysRequired = _daysRequired ?: [[Calendar days] map:^id(id obj) {
        return @YES;
    }].mutableCopy;
    return _daysRequired;
}
-(NSMutableDictionary *)daysChecked{
    _daysChecked = _daysChecked ?: [NSMutableDictionary new]; return _daysChecked;
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
        YLMoment * moment =[ YLMoment momentWithDate: [TimeHelper addDays:dayOffset + n toDate:now]];
        if([self isRequiredOnWeekday:moment.date]){
            UILocalNotification * notification = [UILocalNotification new];
            NSDateComponents * components = self.reminderTime.copy;
            components.year = moment.year;
            components.month = moment.month;
            components.day = moment.day;
            notification.fireDate = [[NSCalendar currentCalendar] dateFromComponents:components];
            notification.alertBody = self.title;
            notification.repeatInterval = NSWeekCalendarUnit;
            [self.notifications addObject: notification];
        }
    }
}
@end
