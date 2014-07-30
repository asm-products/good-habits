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
#import "HabitAnalysis.h"
#import "DayKeys.h"
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
    NSDate * auditTime = [TimeHelper dateForTimeToday:[self scheduledTime]];
    NSString * today = [DayKeys keyFromDate:[TimeHelper now]];
    return [[HabitsList active] filter:^BOOL(Habit * habit) {
        HabitAnalysis * analysis = [[HabitAnalysis alloc] initWithHabit:habit];
        HabitDay * habitDay = [analysis nextUnauditedDay];
        if([habitDay.day isEqualToString:today] && auditTime == NO) return NO;
        return [analysis hasUnauditedChainBreaks];
    }];
}
@end
