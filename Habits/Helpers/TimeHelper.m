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
    return [[Moment momentWithDate:self] startOfCalendarUnit:NSCalendarUnitDay].date;
}
-(BOOL)isBefore:(NSDate *)date{
    return [self compare:date] == NSOrderedAscending;
}
@end

@implementation Moment

//- (void)dealloc
//{
//    // no KVO
//}
//-(void)momentInitiated{
//    // no KVO
//}

@end

static NSDate * selectedDate = nil;
@implementation TimeHelper
+(NSCalendar *)UTCCalendar{
    static NSCalendar * calendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });
    return calendar;
}
+(NSDate *)startOfDayInUTC:(NSDate *)date{
    YLMoment * moment = [Moment momentWithDate:date];
    moment.calendar = [self UTCCalendar];
    return [moment startOfCalendarUnit:NSCalendarUnitDay].date;
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
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDate * result = [self.now dateByAddingTimeInterval:calendar.timeZone.secondsFromGMT];
    return [self startOfDayInUTC: selectedDate ? selectedDate : result];
}
+(NSInteger)weekdayIndex:(NSDate *)date{
    NSDateComponents * components = [[self UTCCalendar] components:NSCalendarUnitWeekday fromDate:date];
    return components.weekday - 1; // weekday returned by calendar is 1-based (i.e. 
}
+(NSDate *)addDays:(NSInteger)count toDate:(NSDate *)date{
    NSDateComponents * dateComponents = [NSDateComponents new];
    dateComponents.day = count;
//    assert(date);
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
    return [formatter stringFromDate:[[NSCalendar currentCalendar] dateFromComponents:components]];
}
+(NSString *)timeAgoString:(NSDate *)date{
    YLMoment * moment = [Moment momentWithDate:date];
    NSString * result = [moment fromDate:[self now]];
    if([result isEqualToString:@"a day ago"]) result = @"Yesterday";
    if([result isEqualToString:@"a few seconds ago"]) result = @"Today";
    if ([[moment startOfCalendarUnit:NSDayCalendarUnit] isEqualToMoment:[[Moment momentWithDate:[TimeHelper now]] startOfCalendarUnit:NSDayCalendarUnit]]) {
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
        __dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });
    return __dateFormatter;
}

+(NSDateFormatter*)fullDateFormatter{
    static NSDateFormatter * formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"EEEE d MMMM yyyy";
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });
    return formatter;
    
}
+(NSDateFormatter*)accessibilityDateFormatter{
    static NSDateFormatter * formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"d MMMM";
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });
    return formatter;
}
@end
