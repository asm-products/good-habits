//
//  MotionToMantleMigrator.h
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Habit.h"

@interface PlistStoreToCoreDataMigrator : NSObject
+(BOOL)dataCanBeMigrated;
/**
 *  Always assume we're starting fresh.
 *
 */
+(void)performMigrationWithArray:(NSArray*)source progress:(void (^)(float))progressCallback;
/**
 *  Migrate from the RubyMotion version (<2.0)
 */
+(NSArray*)habitsStoredByMotion;
+(void)generateChainsForHabit:(Habit*)habit fromDaysChecked:(NSArray*)dayKeys context:(NSManagedObjectContext*)context;
+(NSArray*)useProperty:(NSString*)sourceKey toPopulateUniqueIdentifierProperty:(NSString*)destinationKey withArray:(NSArray*)array;
@end
