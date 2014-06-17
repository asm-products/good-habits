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

static NSMutableArray * allHabits = nil;

NSDateFormatter * dateKeyFormatter(){
    static NSDateFormatter * formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"YYYY-MM-dd";
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
+(NSInteger)nextOrder{
    return [[self all] count];
}

+(NSInteger)nextUnusedColorIndex{
    return self.all.count % [Colors colorsFromMotion].count;
}
+(NSMutableArray *)all{
    if(!allHabits){
        allHabits = [NSMutableArray new];
    }
    return allHabits;
}
+(void)deleteHabit:(Habit *)habit{
    [[self all] removeObject:habit];
}

#pragma mark - Groups
+(NSArray *)active{
    return [[[self all] filter:^BOOL(Habit* habit) {
        return habit.isActive.boolValue;
    }] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
}
+(NSArray *)activeToday{
    return [self.active filter:^BOOL(Habit * habit) {
        return habit.isRequiredToday;
    }];
}
+(NSArray *)activeButNotToday{
    return [self.active filter:^BOOL(Habit * habit) {
        return !habit.isRequiredToday && habit.currentChainLength != 0;
    }];
}
+(NSArray *)carriedOver{
    return [self.active filter:^BOOL(Habit * habit) {
        return !habit.isRequiredToday && habit.currentChainLength == 0;
    }];
}
+(NSArray *)inactive{
    return [self.all filter:^BOOL(Habit * habit) {
        return !habit.isActive.boolValue;
    }];
}
#pragma mark - Individual state
-(BOOL)isRequiredToday{
    return [self isRequired:[TimeHelper now]];
}
-(BOOL)done:(NSDate *)date{
    return [self.daysChecked[ dayKey(date) ] boolValue];
}
-(BOOL)due:(NSDate *)date{
    if(!self.isActive.boolValue) return NO;
    if(![self isRequired:date]) return NO;
    if(!self.reminderTime) return NO;
    NSDateComponents * components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:date];
    return components.hour > self.reminderTime.hour && components.minute > self.reminderTime.minute;
}
-(BOOL)isRequired:(NSDate *)date{
    return self.daysRequired[[TimeHelper weekday:date]] != nil;
}
#pragma mark - Interactions
-(void)toggle:(NSDate *)date{
    NSString * key = dayKey(date);
    if (self.daysChecked[key]) {
        [self.daysChecked removeObjectForKey:key];
    }else{
#warning will change this to store the chain length
        self.daysChecked[key] = @YES;
    }
    [self recalculateLongestChain];
    [Habit saveAll];
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
    while([lastDay.date timeIntervalSinceDate:earliestDate]  > 0){
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
        if([self isRequired:moment.date]) return NO;
    }
    return NO;
}

-(BOOL)includesDate:(NSDate*)date{
    return self.daysChecked[ dayKey(date) ] != nil;
}
-(NSDate*)earliestDate{
    if(self.daysChecked.count == 1) return [TimeHelper now];
    NSDate * date = dateFromKey( [[self.daysChecked.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] firstObject] );
    return date;
}
#pragma mark - Data management
+(void)saveAll{
    
}
+(void)overwriteHabits:(NSArray *)array{
    allHabits = array.mutableCopy;
}
#pragma mark - Helper
+(NSDate*)dateFromString:(NSString*)date{
    return dateFromKey(date);
}
@end
