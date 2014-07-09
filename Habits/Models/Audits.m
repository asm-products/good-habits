//
//  Audits.m
//  Habits
//
//  Created by Michael Forrest on 08/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "Audits.h"
#import "TimeHelper.h"
#import "HabitsList.h"
#import <NSArray+F.h>
#import "ChainAnalysis.h"
#define ScheduledAuditTimeKey @"ScheduledAuditTime"

@implementation Audits
+(void)initialize{
    NSDateComponents * components = [TimeHelper dateComponentsForHour:21 minute:0];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:components];
    NSDictionary * defaults = @{ScheduledAuditTimeKey:data };
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}
+(void)saveScheduledTime:(NSDateComponents *)components{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:components] forKey:ScheduledAuditTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSDateComponents *)scheduledTime{
    NSData * data = [[NSUserDefaults standardUserDefaults] valueForKey:ScheduledAuditTimeKey];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}
+(NSArray *)habitsToBeAudited{

    return [[HabitsList active] filter:^BOOL(Habit * habit) {
        NSDate * startDate = [[TimeHelper addDays:-7 toDate:[TimeHelper now]] laterDate:habit.earliestDate];
        NSDate * endDate = [[TimeHelper now] laterDate:habit.earliestDate];
        ChainAnalysis * analysis = [[ChainAnalysis alloc] initWithHabit:habit startDate:startDate endDate:endDate calculateImmediately:YES];
        habit.latestAnalysis = analysis;
        return analysis.freshChainBreaks.count > 0;
    }];
}
@end
