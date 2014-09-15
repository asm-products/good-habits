//
//  Habit.h
//  Habits
//
//  Created by Michael Forrest on 27/04/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HabitDay.h"
@import CoreData;

@class ChainAnalysis;

@interface Habit : NSManagedObject

@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) UIColor * color;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSDateComponents * reminderTime;
@property (nonatomic, strong) NSNumber * isActive;
@property (nonatomic, strong) NSNumber * order;
@property (nonatomic, strong) NSArray * daysRequired;

@property (nonatomic, strong) NSSet * chains;

@property (nonatomic, strong) NSMutableArray * notifications;

#pragma mark - Individual item state
-(BOOL)isRequiredToday;
-(BOOL)isRequiredOnWeekday:(NSDate*)date;
-(BOOL)done:(NSDate*)date;
-(BOOL)due:(NSDate*)date;
-(BOOL)needsToBeDone:(NSDate*)date;
-(BOOL)hasReminders;
-(BOOL)isNew;
-(NSDate*)nextDayRequiredAfter:(NSDate*)date;

#pragma mark - Meta
-(NSDate*)earliestDate;

#pragma mark - Interactions
//-(void)toggle:(NSDate*)date;
//-(void)checkDays:(NSArray*)days;
//-(void)uncheckDays:(NSArray*)days;
//-(void)setDaysChecked:(NSArray *)dayKeys checked:(BOOL)checked;
//-(HabitDay*)habitDayForDate:(NSDate*)date;
//-(HabitDay*)habitDayForKey:(NSString*)key;

#pragma mark - Chains
-(Chain*)addNewChain;
-(Chain*)addNewChainInContext:(NSManagedObjectContext*)context;
-(NSArray*)sortedChains;
-(Chain*)longestChain;
-(NSInteger)currentChainLength;
-(Chain*)currentChain;
-(Chain*)chainForDate:(NSDate*)date;
-(void)recalculateRunningTotalsInBackground:(void(^)())completionCallback;
#pragma mark - Data management
+(Habit*)createNew;
#pragma mark - Notifications
-(void)recalculateNotifications;

@end


@interface Habit(ChainsAccessors)
-(void)addChainsObject:(Chain *)object;
-(void)removeChainsObject:(Chain*)object;
@end
