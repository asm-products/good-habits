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
#import <AVHexColor.h>
#import "DayKeys.h"

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
             @"habitDays": [NSNull null]
             };
}
#pragma mark - MTLJSONSerializing
+(NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{@"createdAt": @"created_at",
             @"daysChecked":@"days_checked",
             @"reminderTime":@"time_to_do",
             @"isActive":@"active",
             @"daysRequired":@"days_required",
             @"identifier": @"id",
             @"habitDays": @"days",
             @"notifications": [NSNull null]
             };
}
+(NSValueTransformer*)colorJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString * colorString) {
        return [AVHexColor colorWithHexString:colorString];
    } reverseBlock:^id(UIColor * color) {
        return [AVHexColor hexStringFromColor:color];
    }];
}
+(NSValueTransformer*)createdAtJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString * string) {
        return [[TimeHelper jsonDateFormatter] dateFromString:string];
    } reverseBlock:^id(NSDate*date) {
        return [[TimeHelper jsonDateFormatter] stringFromDate:date];
    }];
}
+(NSValueTransformer*)daysRequiredJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSArray * array) {
        return [[Calendar days] map:^id(NSString * dayName) {
            return @([array indexOfObject:dayName] != NSNotFound);
        }];
    } reverseBlock:^id(NSArray*array){
        return [[[Calendar days] map:^id(NSString *day) {
            NSInteger index = [[Calendar days] indexOfObject:day];
            if (index > array.count - 1) return [NSNull null];
            return [array[index] boolValue] ? day : [NSNull null];
        }] filter:^BOOL(id obj) {
            return obj == [NSNull null] ? NO : YES;
        }];
    }];
}
+(NSValueTransformer*)reminderTimeJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString*string) {
        NSArray * bits = [string componentsSeparatedByString:@":"];
        NSDateComponents * result = [NSDateComponents new];
        if(bits.count < 2) return nil;
        result.hour = [bits[0] integerValue];
        result.minute = [bits[1] integerValue];
        return result;
        
    } reverseBlock:^id(NSDateComponents*components) {
        static NSDateFormatter * formatter = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            formatter = [NSDateFormatter new];
            formatter.dateFormat = @"HH:mm";
        });
        NSDate * date = [[NSCalendar currentCalendar] dateFromComponents:components];
        NSString* result = [formatter stringFromDate:date];
        return result;
    }];
}
+(NSValueTransformer*)habitDaysJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSArray*json) {
        NSError * error;
        return [MTLJSONAdapter modelsOfClass:[HabitDay class] fromJSONArray:json error:&error];
    } reverseBlock:^id(NSArray*models) {
        return [MTLJSONAdapter JSONArrayFromModels:models];
    }];
}
#pragma mark - Individual state
-(BOOL)isRequiredToday{
    return [self isRequiredOnWeekday:[TimeHelper now]];
}
-(BOOL)done:(NSDate *)date{
    return [self habitDayForDate:date].isChecked.boolValue;
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
    if(self.habitDays.count == 0) return [TimeHelper now];
    NSInteger index = [self.habitDays indexOfObjectWithOptions:0 passingTest:^BOOL(HabitDay * day, NSUInteger idx, BOOL *stop) {
        return day.isChecked.boolValue && day.userInterventionStatus.boolValue;
    }];
    if(index != NSNotFound) return [self.habitDays[index] date];
    return [TimeHelper now];
}
#pragma mark - Interactions
-(void)toggle:(NSDate *)date{
    HabitDay * day = [self habitDayForDate:date];
    day.isChecked = @(!day.isChecked.boolValue);
    [self recalculateLongestChain];
}
-(void)checkDays:(NSArray *)days{
    [self setDaysChecked:days checked:YES];
}
-(void)uncheckDays:(NSArray *)days{
    [self setDaysChecked:days checked:NO];
}
/**
 *  Always assume user intervention when these methods were called
 */
-(void)setDaysChecked:(NSArray *)dayKeys checked:(BOOL)checked{
    assert([dayKeys.firstObject isKindOfClass:[NSString class]]);
    [self ensureHabitDaysAreContinuousIncluding:dayKeys];
    for(NSString* key in dayKeys){
        HabitDay * day = [self habitDayForKey:key];
        day.isChecked = @(checked);
        day.chainBreakStatus = nil;
        day.userInterventionStatus = @YES;
    }
    [self recalculateLongestChain];
}
-(void)ensureHabitDaysAreContinuousIncluding:(NSArray*)dayKeys{
    dayKeys = [dayKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray * possibleKeys = [DayKeys dateKeysIncluding:dayKeys.firstObject last:dayKeys.lastObject forwardPadding:0];
    for (NSString * key in possibleKeys) {
        [self habitDayForKey:key];
    }
}
-(HabitDay*)habitDayForDate:(NSDate*)date{
    NSString * key = [DayKeys keyFromDate:date];
    return [self habitDayForKey:key];
}
-(HabitDay*)habitDayForKey:(NSString*)key{
    NSInteger index =  [self.habitDays indexOfObjectWithOptions:NSEnumerationReverse passingTest:^BOOL(HabitDay*day, NSUInteger idx, BOOL *stop) {
        return [day.day isEqualToString:key];
    }];
    if(index == NSNotFound){
        BOOL required = [self isRequiredOnWeekday:[DayKeys dateFromKey:key]];
        HabitDay * day = [[HabitDay alloc] initWithDictionary:@{
                                                                @"habitIdentifier": self.identifier,
                                                                @"day": key,
                                                                @"required": @(required)
                                                                } error:nil];
        [self.habitDays addObject:day];
        [self.habitDays sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"day" ascending:YES]]];
        return day;
    }else{
        return self.habitDays[index];
    }
}
#pragma mark - Chains
-(void)recalculateLongestChain{
    [self calculateChainLengthFindLongest:YES];
}
-(NSNumber *)longestChain{
    return [self.habitDays reduce:^id(id memo, HabitDay * day) {
        NSInteger result = MAX([memo integerValue], [day.runningTotal integerValue]);
        return @(result);
    } withInitialMemo:@0];
}
-(NSArray *)chains{
    __block NSNumber * previousNumber = @0;
    NSMutableArray * result = [NSMutableArray new];
    [self.habitDays reduce:^id(id memo, HabitDay * day) {
        if (previousNumber.integerValue < day.runningTotal.integerValue) {
            [memo addObject:day];
        }else{
            [result addObject:memo];
            memo = [NSMutableArray new];
            [memo addObject:day];
        }
        previousNumber = day.runningTotal;
        return memo;
    } withInitialMemo:[NSMutableArray new]];
    return result;
}
-(NSInteger)currentChainLength{
    HabitDay * day = [self habitDayForDate:[TimeHelper now]];
    return day.runningTotal.integerValue;
}
-(NSInteger)calculateChainLengthFindLongest:(BOOL)shouldFindLongest{
    __block HabitDay * previousDay = self.habitDays.firstObject;
    NSString * todayKey = [DayKeys keyFromDate:[TimeHelper now]];
    [self.habitDays enumerateObjectsUsingBlock:^(HabitDay * habitDay, NSUInteger index, BOOL *stop) {
        if(index == 0){
            habitDay.runningTotal = habitDay.isChecked.boolValue ? @1 : @0;
        }else{
            if(habitDay.isChecked.boolValue){
                habitDay.runningTotal = @(previousDay.runningTotal.integerValue + 1);
            }else{
                NSLog(@"%@day not checked. required ? %@ ",habitDay.habitIdentifier, habitDay.required);
                if(habitDay.required.boolValue){
                    if(!habitDay.chainBreakStatus){
                        habitDay.chainBreakStatus = @"fresh";
                        habitDay.runningTotalWhenChainBroken = previousDay.runningTotal;
                        habitDay.runningTotal = @0;
                        NSLog(@"There was a chain break for habit '%@' on '%@' with running total %@", self.title, habitDay.day, habitDay.runningTotal);
                    }
                }else{
                    habitDay.runningTotal = previousDay.runningTotal;
                }
            }
        }
        previousDay = habitDay;
        if([previousDay.day isEqualToString:todayKey]){
            *stop = YES;
        }
    }];
    if(shouldFindLongest){
        return [[self.habitDays reduce:^id(id memo, HabitDay * day) {
            return @(MAX(day.runningTotal.integerValue, [memo integerValue]));
        } withInitialMemo:@0] integerValue];
    }else{
        return [self habitDayForDate:[TimeHelper now]].runningTotal.integerValue;
    }
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
    [moment addAmountOfTime:step forCalendarUnit:NSDayCalendarUnit];
    while (index++ < limit && [moment.date isBefore:[TimeHelper now]]) {
        if([self includesDate:moment.date]) return moment.date;
        if([self isRequiredOnWeekday:moment.date]) {
            NSLog(@"Activity interrupted because it was required on %@", moment);
            return nil;
        }
        [moment addAmountOfTime:step forCalendarUnit:NSDayCalendarUnit];
    }
    if(![moment.date isBefore:[TimeHelper now]]) return [TimeHelper now];
    NSLog(@"Activity interrupted because we reached the limit");
    return nil;
}

-(BOOL)includesDate:(NSDate*)date{
    return [[[self habitDayForDate:date] isChecked] boolValue];
}
-(NSNumber*)chainLengthOnDate:(NSDate *)date{
    HabitDay * day = [self habitDayForDate:date];
    return day.runningTotal;
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
-(NSMutableArray*)habitDays{
    _habitDays = _habitDays ?: [NSMutableArray new]; return _habitDays;
}
//-(NSMutableArray *)daysChecked{
//    _daysChecked = _daysChecked ?: [NSMutableArray new]; return _daysChecked;
//}
-(void)save{
    [HabitsList saveAll];
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
