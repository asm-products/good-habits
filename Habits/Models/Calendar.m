//
//  Calendar.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "Calendar.h"

@implementation Calendar
+(NSString *)labelForState:(CalendarDayState)state{
    switch (state) {
        case CalendarDayStateAlone: return @"isolated day";
        case CalendarDayStateBeforeStart: return @"before start";
        case CalendarDayStateBetweenSubchains: return @"between subchains";
        case CalendarDayStateFirstInChain: return @"first in chain";
        case CalendarDayStateFuture: return @"future";
        case CalendarDayStateLastInChain: return @"last in chain";
        case CalendarDayStateMidChain: return @"mid-chain";
        case CalendarDayStateMissed: return @"missed day";
        case CalendarDayStateNotRequired: return @"not required";
    }
    return @"";
}
+(NSArray *)dayNamesPlural{
    return @[@"Sundays", @"Mondays", @"Tuesdays", @"Wednesdays", @"Thursdays", @"Fridays", @"Saturdays"];
}
+(NSArray *)days{
    return @[@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat" ];
}
@end
