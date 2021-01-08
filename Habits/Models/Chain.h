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

typedef NS_ENUM(NSUInteger,DayCheckedState){
    DayCheckedStateNull,
    DayCheckedStateComplete,
    DayCheckedStateBroken,
    DayCheckedStateCount // number of enums for iteration - not, like, the chain length count or anything
};


@class Habit;
@interface Chain : NSManagedObject
/**
 *  If the user specifies that the chain is broken.
 */
//@property (nonatomic, strong) NSNumber * explicitlyBroken;
@property (nonatomic, strong) NSNumber * breakDetected;
@property (nonatomic, strong) NSSet * days;
@property (nonatomic, strong) Habit * habit;
@property (nonatomic, strong, nullable) NSNumber * daysCountCache;
@property (nonatomic, strong, nullable) NSDate * firstDateCache;
@property (nonatomic, strong, nullable) NSDate * lastDateCache;
@property (nonatomic, strong) NSArray * daysRequired;

-(void)emergencyCacheRefresh;

#pragma mark - Sugar
-(NSArray<HabitDay*>*)sortedDays;
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
-(HabitDay*)habitDayForDate:(NSDate*)date;
-(DayCheckedState)tickLastDayInChainOnDate:(NSDate*)date;

#pragma mark - User interaction
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
