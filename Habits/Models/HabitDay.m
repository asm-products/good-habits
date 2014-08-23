//
//  HabitDay.m
//  Habits
//
//  Created by Michael Forrest on 15/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "HabitDay.h"
#import "Habit.h"
#import "DayKeys.h"
#import "Chain.h"
@implementation HabitDay
@dynamic dayKey,dayStateCache,date,chain,runningTotalCache,timeZoneOffset;

+(NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"habitIdentifier": @"habit_id",
             @"isChecked": @"checked",
             @"runningTotal": @"running_total",
             @"renderStatus": [NSNull null],
             @"chainBreakStatus": @"chain_break"
             };
}
-(CalendarDayState)dayState{
    if(self.chain.length == 1) return CalendarDayStateAlone;
    if (self.chain.sortedDays.firstObject == self) {
        return CalendarDayStateFirstInChain;
    }else if (self.chain.sortedDays.lastObject == self){
        return CalendarDayStateLastInChain;
    }
    return CalendarDayStateMidChain;
}
@end
