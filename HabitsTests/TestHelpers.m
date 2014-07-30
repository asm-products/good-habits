//
//  TestHelpers.m
//  Habits
//
//  Created by Michael Forrest on 09/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "TestHelpers.h"
#import "Calendar.h"
#import <NSArray+F.h>
#import "DayKeys.h"
@implementation TestHelpers
+(Habit *)habit:(NSDictionary *)dict daysChecked:(NSArray *)dayKeys{
    NSError * error;
    Habit * result = [[Habit alloc] initWithDictionary:dict error:&error];
    if(error) @throw [NSException exceptionWithName:@"Bad habit error" reason:error.localizedDescription userInfo:@{@"error":error}];
    if(dayKeys)
        [result checkDays:dayKeys];
    return result;
}
+(NSMutableArray *)everyDay{
    return [[Calendar days] map:^id(id obj) {
        return @YES;
    }].mutableCopy;
}
+(NSArray *)days:(NSArray *)dayStrings{
    return [dayStrings map:^id(NSString * string) {
        return [DayKeys dateFromKey:string];
    }];
}
@end
