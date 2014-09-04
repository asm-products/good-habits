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
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        formatter.dateFormat = @"yyyy-MM-dd";
    });
    return formatter;
}
NSString * dayKey(NSDate* date){
    NSDateFormatter * formatter = dateKeyFormatter();
    NSDateComponents * components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    static NSTimeZone * gmt = nil;
    static NSCalendar * calendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gmt = [NSTimeZone timeZoneForSecondsFromGMT:0];
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        calendar.timeZone = gmt;
    });
    date = [calendar dateFromComponents:components];
    return [formatter stringFromDate:date];
}
NSDate * dateFromKey(NSString * key){
    static NSCalendar * calendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSTimeZone * gmt = [NSTimeZone timeZoneForSecondsFromGMT:0];
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        calendar.timeZone = gmt;
    });
    NSDateComponents * components = [NSDateComponents new];
    NSArray * d = [key componentsSeparatedByString:@"-"];
    components.year = [d[0] integerValue];
    components.month = [d[1] integerValue];
    components.day = [d[2] integerValue];
    NSDate * result = [calendar dateFromComponents:components];
    return result;

}
@implementation DayKeys

+(NSDate *)dateFromKey:(NSString *)key {
    return dateFromKey(key);
}
+(NSString *)keyFromDate:(NSDate *)date{
    return dayKey(date);
}
@end
