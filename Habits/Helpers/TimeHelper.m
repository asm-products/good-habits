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
+(NSCalendar *)UTCCalendar{
    static NSCalendar * calendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });
    return calendar;
}
+(NSDate *)startOfDayInUTC:(NSDate *)date{
    YLMoment * moment = [YLMoment momentWithDate:date];
    moment.calendar = [self UTCCalendar];
    return [moment startOfCalendarUnit:NSDayCalendarUnit].date;
}
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
+(NSDate *)today{
    return [self startOfDayInUTC: selectedDate ? selectedDate : [NSDate date]];
}
+(NSInteger)weekday:(NSDate *)date{
    NSDateComponents * components = [[self UTCCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    return components.weekday - 1;
}
+(NSDate *)addDays:(NSInteger)count toDate:(NSDate *)date{
    NSDateComponents * dateComponents = [NSDateComponents new];
    dateComponents.day = count;
    return [[self UTCCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
}
+(NSString*)formattedTime:(NSDateComponents *)components{
    static NSDateFormatter * formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterNoStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
    });
    return [formatter stringFromDate:[[self UTCCalendar] dateFromComponents:components]];
}
+(NSString *)timeAgoString:(NSDate *)date{
    YLMoment * moment = [YLMoment momentWithDate:date];
    NSString * result = [moment fromDate:[self now]];
    if([result isEqualToString:@"a day ago"]) result = @"Yesterday";
    if([result isEqualToString:@"a few seconds ago"]) result = @"Today";
    if ([[moment startOfCalendarUnit:NSDayCalendarUnit] isEqualToMoment:[[YLMoment momentWithDate:[TimeHelper now]] startOfCalendarUnit:NSDayCalendarUnit]]) {
        return @"Today";
    }
    return result;
}
+(NSDate *)dateForTimeToday:(NSDateComponents *)components{
    NSDateComponents * todayComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[TimeHelper now]];
    todayComponents.hour = components.hour;
    todayComponents.minute = components.minute;
    return [[NSCalendar currentCalendar] dateFromComponents:todayComponents];
}
//+ (NSDateFormatter *)iso8601Formatter{
+ (NSDateFormatter *)jsonDateFormatter{
    static NSDateFormatter *__dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __dateFormatter = [[NSDateFormatter alloc] init];
//        __dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        __dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
    });
    return __dateFormatter;
}


+(NSDateFormatter*)accessibilityDateFormatter{
    static NSDateFormatter * formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"d MMMM";
    });
    return formatter;
}
@end
