//
//  Habit.h
//  Habits
//
//  Created by Michael Forrest on 27/04/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

@class ChainAnalysis;

@interface Habit : MTLModel<MTLManagedObjectSerializing,MTLJSONSerializing>
@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) UIColor * color;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSMutableDictionary * daysChecked;
@property (nonatomic, strong) NSDateComponents * reminderTime;
@property (nonatomic, strong) NSNumber * isActive;
@property (nonatomic, strong) NSNumber * order;
@property (nonatomic, strong) NSMutableArray * daysRequired;

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
-(void)toggle:(NSDate*)date;
-(void)checkDays:(NSArray*)days;
-(void)uncheckDays:(NSArray*)days;

#pragma mark - Chains
-(void)recalculateLongestChain;
-(NSInteger)currentChainLength;
-(BOOL)includesDate:(NSDate*)date;
-(NSDate*)continuesActivityBefore:(NSDate*)date;
-(NSDate*)continuesActivityAfter:(NSDate*)date;
-(NSNumber*)chainLengthOnDate:(NSDate*)date;
-(NSNumber*)longestChain;

#pragma mark - Data management
-(void)save;

#pragma mark - Helper
+(NSDate*)dateFromString:(NSString*)date;

#pragma mark - Notifications
-(void)recalculateNotifications;


#pragma mark - Caching
/**
 *  This is initially calculated in [Audits habitsToBeAudited] and is based on a time range decided there. It might be slow to compute so it gets cached here
    for use in AuditItemViewController
 */
@property (nonatomic, strong) ChainAnalysis * latestAnalysis;
@end
