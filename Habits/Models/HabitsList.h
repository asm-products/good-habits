//
//  HabitsList.h
//  Habits
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Habit.h"

#define HABITS_UPDATED @"HABITS_UPDATED"

@interface HabitsList : NSObject
+(NSMutableArray*)all;
#pragma  mark - Groups
+(NSArray*)active;
+(NSArray*)activeToday;
+(NSArray*)carriedOver;
+(NSArray*)activeButNotToday;
+(NSArray*)inactive;
+(NSInteger)habitCountForDate:(NSDate*)day;
+(void)deleteHabit:(Habit*)habit;


#pragma mark - Data management
+(void)saveAll;
+(void)overwriteHabits:(NSArray*)array;
+(void)loadFromCoreData;
+(void)refreshFromManagedObjectContext:(NSManagedObjectContext*)context;
#pragma mark - Notifications
+(void)recalculateAllNotifications;

#pragma mark - Helper
+(NSInteger)nextUnusedColorIndex;

@end
