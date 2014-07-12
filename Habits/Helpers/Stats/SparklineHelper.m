//
//  SparklineHelper.m
//  Habits
//
//  Created by Michael Forrest on 11/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SparklineHelper.h"
#import "TimeHelper.h"
@implementation SparklineHelper
+(NSArray *)dataForHabit:(Habit *)habit{
    NSMutableArray * dataPoints = [NSMutableArray new];
    NSDate * now = [TimeHelper now];
    NSDate * date = habit.earliestDate;
    while ([date isBefore: now]) {
        NSNumber * value = [habit includesDate:date] ? [habit chainLengthOnDate:date] : @0;
        [dataPoints addObject:value];
        date = [TimeHelper addDays:1 toDate:date];
    }
    return dataPoints;
}
@end
