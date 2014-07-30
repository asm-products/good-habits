//
//  Habit.h
//  Habits
//
//  Created by Michael Forrest on 27/04/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>
#import "HabitDay.h"

@class ChainAnalysis;

@interface Habit : MTLModel<MTLManagedObjectSerializing,MTLJSONSerializing>
@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) UIColor * color;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSMutableArray * habitDays;
@property (nonatomic, strong) NSDateComponents * reminderTime;
@property (nonatomic, strong) NSNumber * isActive;
@property (nonatomic, strong) NSNumber * order;
@property (nonatomic, strong) NSMutableArray * daysRequired;

@property (nonatomic, strong) NSMutableArray * notifications;


/**
 * legacy support: when this is assigned it means that we've just
 * imported a legacy JSON file
 */
@property (nonatomic, strong) NSDictionary * daysChecked;
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
-(void)toggle:(NSDate*)date;
-(void)checkDays:(NSArray*)days;
-(void)uncheckDays:(NSArray*)days;
-(void)setDaysChecked:(NSArray *)dayKeys checked:(BOOL)checked;
-(HabitDay*)habitDayForDate:(NSDate*)date;
-(HabitDay*)habitDayForKey:(NSString*)key;

#pragma mark - Chains
-(void)recalculateLongestChain;
-(NSInteger)currentChainLength;
-(BOOL)includesDate:(NSDate*)date;
-(NSDate*)continuesActivityBefore:(NSDate*)date;
-(NSDate*)continuesActivityAfter:(NSDate*)date;
-(NSNumber*)chainLengthOnDate:(NSDate*)date;
-(NSNumber*)longestChain;
-(NSArray*)chains;

#pragma mark - Data management
-(void)save;

#pragma mark - Notifications
-(void)recalculateNotifications;


@end
