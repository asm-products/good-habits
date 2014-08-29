//
//  HabitsList.h
//  Habits
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Habit.h"
#import "CoreDataClient.h"
#define HABITS_UPDATED @"HABITS_UPDATED"
#define REFRESH @"REFRESH"

@interface HabitsQueries : NSObject
+(void)refresh;
+(NSArray*)all;
#pragma  mark - Groups
+(NSArray*)active;
+(NSArray*)activeToday;
+(NSArray*)carriedOver;
+(NSArray*)activeButNotToday;
+(NSArray*)inactive;
+(NSInteger)habitCountForDate:(NSDate*)day;
+(Habit*)findHabitByIdentifier:(NSString*)identifier;

#pragma mark - Notifications
+(void)recalculateAllNotifications;

#pragma mark - Helper
+(NSInteger)nextUnusedColorIndex;

#pragma mark - Destructive
+(void)deleteAllHabits;

@end
