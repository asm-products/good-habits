//
//  HabitDay.h
//  Habits
//
//  Created by Michael Forrest on 15/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Mantle.h>
@import CoreData;

@class Chain;

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
    CalendarDayStateBrokenChain
} CalendarDayState;

@interface HabitDay : NSManagedObject<MTLJSONSerializing>

/**
 *  Not sure what I'm using this for if I'm gonna start using date like a grown-up. Might even delete it.
 */
@property (nonatomic, strong) NSString * dayKey;
/**
 *  Maps to CalendarDayState enum
 */
@property (nonatomic, strong) NSNumber * dayStateCache;
/**
 *  This is a cache intended to help with graphing. The running
 *  total is really a property of the chain
 */
@property (nonatomic, strong) NSNumber * runningTotalCache;
/**
 * This is annoying to store as a date but as long as I always
 * force dates into the time zone they were in when recorded
 * I should be able to avoid weird behaviour
 */
@property (nonatomic, strong) NSDate * date;
/**
 *  NSInteger value representing time zone offset from GMT for the stored date.
 */
@property (nonatomic, strong) NSNumber * timeZoneOffset;

@property (nonatomic, strong) Chain * chain;


-(CalendarDayState)dayState;
@end
