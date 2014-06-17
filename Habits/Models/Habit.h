//
//  Habit.h
//  Habits
//
//  Created by Michael Forrest on 27/04/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>
@interface Habit : MTLModel
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) UIColor * color;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSMutableDictionary * daysChecked;
@property (nonatomic, strong) NSDateComponents * reminderTime;
@property (nonatomic, strong) NSNumber * isActive;
@property (nonatomic, strong) NSNumber * order;
@property (nonatomic, strong) NSMutableArray * daysRequired;
@property (nonatomic, strong) NSArray * notifications;
@property (nonatomic, strong) NSNumber * longestChain;

+(NSMutableArray*)all;
#pragma  mark - Groups
+(NSArray*)active;
+(NSArray*)activeToday;
+(NSArray*)carriedOver;
+(NSArray*)activeButNotToday;
+(NSArray*)inactive;
+(NSInteger)habitCountForDate:(NSDate*)day;
+(void)deleteHabit:(Habit*)habit;

#pragma mark - Meta
-(NSDate*)earliestDate;

#pragma mark - Individual item state
-(BOOL)isRequiredOnWeekday:(NSDate*)date;
-(BOOL)done:(NSDate*)date;
-(BOOL)due:(NSDate*)date;
-(BOOL)needsToBeDone:(NSDate*)date;

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
+(void)saveAll;
+(void)overwriteHabits:(NSArray*)array;

#pragma mark - Helper
+(NSDate*)dateFromString:(NSString*)date;
@end
