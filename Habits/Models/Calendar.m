//
//  Calendar.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "Calendar.h"
#import <NSArray+F.h>

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
        case CalendarDayStateBrokenChain: return @"broken";
    }
    return @"";
}
+(NSArray *)dayNamesPlural{
    return [@[@"Sundays", @"Mondays", @"Tuesdays", @"Wednesdays", @"Thursdays", @"Fridays", @"Saturdays"] map:^NSString*(NSString* dayName) {
        NSString * key = [NSString stringWithFormat:@"Not on %@", dayName];
        return NSLocalizedString(key, @"");
    }];
}
+(NSArray *)days{
    return [[NSCalendar currentCalendar] shortWeekdaySymbols];    
}

+ (NSInteger)weekdayIndexForColumn:(NSInteger)i{
    return (i + NSCalendar.currentCalendar.firstWeekday - 1) % 7;
}
@end
