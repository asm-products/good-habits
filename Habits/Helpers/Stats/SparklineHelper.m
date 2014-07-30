//
//  SparklineHelper.m
//  Habits
//
//  Created by Michael Forrest on 11/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SparklineHelper.h"
#import "TimeHelper.h"
#import <YLMoment.h>
#import <NSArray+F.h>
#import "DayKeys.h"
@implementation SparklineHelper
+(NSArray *)dataForHabit:(Habit *)habit{
    NSString * earliestDayKey = [DayKeys keyFromDate:habit.earliestDate];
    NSLog(@"Earliest date %@", earliestDayKey);
    return [habit.habitDays filter:^BOOL(HabitDay * habitDay) {
        BOOL comparison = [habitDay.day compare:earliestDayKey];
        BOOL result = comparison == NSOrderedDescending || comparison == NSOrderedSame;
        NSLog(@"%@ included ? %@", habitDay.day, @(result));
        return result;
    }];
//    NSMutableArray * dataPoints = [NSMutableArray new];
//    NSDate * now = [TimeHelper now];
//    NSDate * date = habit.earliestDate;
//    while ([date isBefore: now]) {
//        NSNumber * value = [habit includesDate:date] ? [habit chainLengthOnDate:date] : @0;
//        [dataPoints addObject:value];
//        date = [TimeHelper addDays:1 toDate:date];
//    }
//    return dataPoints;
}
+(NSString *)periodText:(NSDate *)date{
    return [[YLMoment momentWithDate:date] fromDate:[TimeHelper now] withSuffix:NO];
}
@end
