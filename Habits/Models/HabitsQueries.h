//
//  HabitsList.h
//  Habits
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataClient.h"
#import "Habit.h"
#define HABITS_UPDATED @"HABITS_UPDATED"
#define REFRESH @"REFRESH"
#define PURCHASE_COMPLETED @"PURCHASE_COMPLETED"

@interface HabitsQueries : NSObject
+(NSFetchedResultsController*)fetchedResultsControllerForClient:(CoreDataClient*)client;
+(void)refresh;
+(NSArray*)all;
#pragma  mark - Groups
+(NSArray*)active;
+(NSArray*)outstandingToday;
+(NSArray*)activeToday;
+(NSArray*)carriedOver;
+(NSArray*)activeButNotToday;
+(NSArray*)inactive;
+(NSInteger)habitCountForDate:(NSDate*)day;
+(Habit*)findHabitByIdentifier:(NSString*)identifier;
/**
 *  Only really intended to be used in tests
 */
+(Habit *)findHabitByTitle:(NSString *)identifier;
#pragma mark - Notifications
+(void)recalculateAllNotifications;

#pragma mark - Helper
+(NSInteger)nextUnusedColorIndex;

#pragma mark - Destructive
+(void)deleteAllHabits;

@end
