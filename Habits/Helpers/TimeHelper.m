//
//  TimeHelper.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "TimeHelper.h"
#import <YLMoment.h>

#define ABOUT_ONE_DAY (60 * 60 * 24)

@implementation NSDate(rounding)
-(NSDate *)beginningOfDay{
    return [[YLMoment momentWithDate:self] startOfCalendarUnit:NSDayCalendarUnit].date;
}
-(BOOL)isBefore:(NSDate *)date{
    return [self compare:date] == NSOrderedAscending;
}
@end


static NSDate * selectedDate = nil;
@implementation TimeHelper
+(NSDateComponents *)dateComponentsForHour:(NSInteger)hour minute:(NSInteger)minute{
    NSDateComponents * result = [NSDateComponents new];
    result.hour = hour;
    result.minute = minute;
    return result;
}
+(void)selectDate:(NSDate *)date{
    selectedDate = date;
}
+(NSDate *)now{
    if(selectedDate) return selectedDate;
    return [NSDate date];
}
+(NSInteger)weekday:(NSDate *)date{
    NSDateComponents * components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    return components.weekday - 1;
}
+(NSDate *)addDays:(NSInteger)count toDate:(NSDate *)date{
    NSDateComponents * dateComponents = [NSDateComponents new];
    dateComponents.day = count;
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
}
+(NSString*)formattedTime:(NSDateComponents *)components{
    static NSDateFormatter * formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterNoStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
    });
    return [formatter stringFromDate:[[NSCalendar currentCalendar] dateFromComponents:components]];
}
+(NSString *)timeAgoString:(NSDate *)date{
    YLMoment * moment = [YLMoment momentWithDate:date];
    NSString * result = [moment fromDate:[self now]];
    if([result isEqualToString:@"a day ago"]) result = @"Yesterday";
    if([result isEqualToString:@"a few seconds ago"]) result = @"Today";
    return result;
}
+(NSDate *)dateForTimeToday:(NSDateComponents *)components{
    NSDateComponents * todayComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[TimeHelper now]];
    todayComponents.hour = components.hour;
    todayComponents.minute = components.minute;
    return [[NSCalendar currentCalendar] dateFromComponents:todayComponents];
}
@end
