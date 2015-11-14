//
//  SparklineHelper.m
//  Habits
//
//  Created by Michael Forrest on 11/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SparklineHelper.h"
#import "TimeHelper.h"
#import <NSArray+F.h>
#import "DayKeys.h"
@implementation SparklineHelper
+(NSArray *)dataForHabit:(Habit *)habit{
    return habit.sortedChains;
}
+(NSString *)periodText:(NSDate *)date{
    return [[Moment momentWithDate:date] fromDate:[TimeHelper now] withSuffix:NO];
}
@end
