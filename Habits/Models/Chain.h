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
@property (nonatomic, strong) NSDate * firstDateCache;
@property (nonatomic, strong) NSDate * lastDateCache;
@property (nonatomic, strong) NSArray * daysRequired;

#pragma mark - Sugar
-(NSArray*)sortedDays;
-(NSInteger)length;
-(BOOL)isBroken;
-(NSDate*)nextRequiredDate;
-(NSDate*)startDate;
-(NSInteger)countOfDaysOverdue;
-(BOOL)overlapsDate:(NSDate*)date;
/**
 *  Is this the longest ever chain?   
 */
-(BOOL)isRecord;
-(NSInteger)currentChainLengthForDisplay;
#pragma mark - Chain manipulation

#pragma mark - User interaction
-(DayCheckedState)stepToNextStateForDate:(NSDate*)date;
-(DayCheckedState)dayState;
-(DayCheckedState)toggleDayInCalendarForDate:(NSDate*)date;
/**
 *  Should only be called when there are definitely no chains after this one
 */
-(void)checkNextRequiredDate;

-(void)save;


@end

@interface Chain(DaysAccessors)
-(void)addDays:(NSSet*)days;
-(void)addDaysObject:(HabitDay *)object;
-(void)removeDaysObject:(HabitDay*)object;
@end
