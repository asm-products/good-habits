//
//  Habit.h
//  Habits
//
//  Created by Michael Forrest on 27/04/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>
@interface Habit : MTLModel<MTLManagedObjectSerializing>
@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) UIColor * color;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSMutableDictionary * daysChecked;
@property (nonatomic, strong) NSDateComponents * reminderTime;
@property (nonatomic, strong) NSNumber * isActive;
@property (nonatomic, strong) NSNumber * order;
@property (nonatomic, strong) NSMutableArray * daysRequired;
@property (nonatomic, strong) NSNumber * longestChain;

@property (nonatomic, strong) NSMutableArray * notifications;


#pragma mark - Individual item state
-(BOOL)isRequiredToday;
-(BOOL)isRequiredOnWeekday:(NSDate*)date;
-(BOOL)done:(NSDate*)date;
-(BOOL)due:(NSDate*)date;
-(BOOL)needsToBeDone:(NSDate*)date;
-(BOOL)hasReminders;
-(BOOL)isNew;

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
-(BOOL)continuesActivityBefore:(NSDate*)date;
-(BOOL)continuesActivityAfter:(NSDate*)date;

#pragma mark - Data management
-(void)loadDefaultValues;
-(void)save;

#pragma mark - Helper
+(NSDate*)dateFromString:(NSString*)date;

#pragma mark - Notifications
-(void)recalculateNotifications;
@end
