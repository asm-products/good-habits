//
//  DayKeys.m
//  Habits
//
//  Created by Michael Forrest on 16/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "DayKeys.h"
#import "TimeHelper.h"
NSDateFormatter * dateKeyFormatter(){
    static NSDateFormatter * formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [formatter setTimeZone:[[NSCalendar currentCalendar] timeZone]];
        formatter.dateFormat = @"yyyy-MM-dd";
    });
    return formatter;
}
NSString * dayKey(NSDate* date, NSTimeZone * timeZone){
    NSDateFormatter * formatter = dateKeyFormatter();
    formatter.timeZone = timeZone;
    return [formatter stringFromDate:date];
}
NSDate * dateFromKey(NSString * key, NSTimeZone*timeZone){
    NSDateFormatter * formatter = dateKeyFormatter();
    formatter.timeZone = timeZone;
    return [formatter dateFromString:key];
}
@implementation DayKeys

+(NSDate *)dateFromKey:(NSString *)key inTimeZone:(NSTimeZone *)timeZone{
    return dateFromKey(key,timeZone);
}
+(NSString *)keyFromDate:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone{
    return dayKey(date,timeZone);
}
@end
