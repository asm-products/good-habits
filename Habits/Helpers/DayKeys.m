//
//  DayKeys.m
//  Habits
//
//  Created by Michael Forrest on 16/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "DayKeys.h"
#import "TimeHelper.h"
static NSArray * dateKeys = nil;
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
NSString * dayKey(NSDate* date){
    return [dateKeyFormatter() stringFromDate:date];
}
NSDate * dateFromKey(NSString * key){
    return [dateKeyFormatter() dateFromString:key];
}
@implementation DayKeys

+(NSDate *)dateFromKey:(NSString *)key{
    return dateFromKey(key);
}
+(NSString *)keyFromDate:(NSDate *)date{
    return dayKey(date);
}
+(NSArray *)dateKeysIncluding:(NSString *)first last:(NSString *)last forwardPadding:(NSInteger)numberOfDays{
    if(numberOfDays > 0){
        last = [self keyFromDate:[TimeHelper addDays:numberOfDays toDate:[self dateFromKey:last]]];
    }
    if(!dateKeys){
        dateKeys = [self generateKeysFrom:first toLast:last];
    }
    if([dateKeys indexOfObject:first] == NSNotFound && [first compare:dateKeys.firstObject] == NSOrderedAscending){
        dateKeys = [[self generateKeysFrom:first toLast:dateKeys.firstObject] arrayByAddingObjectsFromArray:dateKeys];
    }
    if ([dateKeys indexOfObject:last] == NSNotFound && [last compare:dateKeys.firstObject] == NSOrderedDescending) {
        dateKeys = [dateKeys arrayByAddingObjectsFromArray:[self generateKeysFrom:dateKeys.lastObject toLast:last]];
    }
    return dateKeys;
}
+(NSArray*)generateKeysFrom:(NSString*)first toLast:(NSString*)last{
    NSDateComponents * components = [NSDateComponents new];
    components.day = 1;
    NSDate * date = [self dateFromKey:first];
    NSMutableArray * result = [[NSMutableArray alloc] initWithCapacity:100];
    while ([result indexOfObject:last] == NSNotFound) {
        [result addObject:[self keyFromDate:date]];
        date = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:date options:0];
    }
    return result;
}
+(void)clearDateKeysCache{
    dateKeys = nil;
}
@end
