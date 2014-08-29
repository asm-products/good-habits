//
//  Chain.h
//  Habits
//
//  Created by Michael Forrest on 22/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HabitDay.h"
@import CoreData;

typedef enum{
    DayCheckedStateNull,
    DayCheckedStateComplete,
    DayCheckedStateBroken,
    DayCheckedStateCount
} DayCheckedState;


@class Habit;
@interface Chain : NSManagedObject
/**
 *  Used for recording reasons the chain got broken.
 */
@property (nonatomic, strong) NSString * notes;
/**
 *  If the user specifies that the chain is broken.
 */
@property (nonatomic, strong) NSNumber * explicitlyBroken;
@property (nonatomic, strong) NSNumber * breakDetected;
@property (nonatomic, strong) NSSet * days;
@property (nonatomic, strong) Habit * habit;
@property (nonatomic, strong) NSNumber * daysCountCache;
@property (nonatomic, strong) NSDate * lastDateCache;

#pragma mark - Sugar
-(NSArray*)sortedDays;
-(NSInteger)length;
-(BOOL)isBroken;
-(NSDate*)nextRequiredDate;
-(NSDate*)startDate;
-(NSInteger)countOfDaysOverdue;
#pragma mark - Chain manipulation
/**
 *  It is the caller's responsibility to delete the joined chain (I think)
 *
 */
-(Chain*)chainByJoiningChain:(Chain*)chain;
/**
 *  It is the caller's responsibility to create another chain with the second result
 */
-(NSArray*)chainsBySplittingAtDay:(HabitDay*)day;

#pragma mark - User interaction
-(DayCheckedState)stepToNextStateForDate:(NSDate*)date;


@end

@interface Chain(DaysAccessors)
-(void)addDaysObject:(HabitDay *)object;
-(void)removeDaysObject:(HabitDay*)object;
@end
