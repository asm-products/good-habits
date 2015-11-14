//
//  Habit.h
//  Habits
//
//  Created by Michael Forrest on 27/04/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HabitDay.h"
#import "Failure.h"
#import "Chain.h"
@import CoreData;
@import UIKit;

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
@property (nonatomic, strong) NSSet * failures;

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

#pragma mark - Chains
-(Chain*)addNewChain;
-(Chain*)addNewChainForToday;
-(Chain*)addNewChainInContext:(NSManagedObjectContext*)context;
-(NSArray*)sortedChains;
-(Chain*)longestChain;
-(NSInteger)currentChainLength;
-( Chain* _Nullable )currentChain;
-(Chain* _Nonnull)chainForDate:(NSDate*_Nonnull)date;
-(void)recalculateRunningTotalsInBackground:(void(^_Nonnull)())completionCallback;

#pragma mark - Failures
-(Failure*_Nullable)existingFailureForDate:(NSDate*_Nonnull)date;
-(Failure*_Nonnull)createFailureForDate:(NSDate*_Nonnull)date;

#pragma mark - Data management
+(Habit*_Nonnull)createNew;
#pragma mark - Notifications
-(void)recalculateNotifications;

@end


@interface Habit(CoreDataAccessors)
-(void)addChainsObject:(Chain *)object;
-(void)removeChainsObject:(Chain*)object;
-(void)addFailuresObject:(Failure*)object;
-(void)removeFailuresObject:(Failure*)object;
@end


