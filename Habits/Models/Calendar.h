//
//  Calendar.h
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CalendarDayStateFuture,
    CalendarDayStateFirstInChain,
    CalendarDayStateLastInChain,
    CalendarDayStateMidChain,
    CalendarDayStateAlone,
    CalendarDayStateBetweenSubchains,
    CalendarDayStateMissed,
    CalendarDayStateBeforeStart,
    CalendarDayStateNotRequired,
    CalendarDayStateCount
} CalendarDayState;

@interface Calendar : NSObject
+(NSString*)labelForState:(CalendarDayState)state;
+(NSArray*)dayNamesPlural;
+(NSArray*)days;
@end
