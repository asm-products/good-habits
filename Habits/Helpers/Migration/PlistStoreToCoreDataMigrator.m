//
//  MotionToMantleMigrator.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "PlistStoreToCoreDataMigrator.h"
#import <NSArray+F.h>
#import "Habit.h"
#import "TimeHelper.h"
#import "Colors.h"
#import "Constants.h"
#import "HabitsQueries.h"
#import "CoreDataClient.h"
#import "Chain.h"
#import "HabitDay.h"
#import "DayKeys.h"

@implementation PlistStoreToCoreDataMigrator
+(BOOL)dataCanBeMigrated{
    return [self habitsStoredByMotion] != nil;
}
+(NSArray*)habitsStoredByMotion{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"goodtohear.habits_habits"];
}
+(void)performMigrationWithArray:(NSArray*)source progress:(void (^)(float))progressCallback;
{
    float storedCount = source.count;
    __block float progress = 0;
    CoreDataClient * client = [CoreDataClient defaultClient];
    NSManagedObjectContext * context = [client createPrivateContext];
    for (NSDictionary * dict in source) {
        Habit * habit = [HabitsQueries findHabitByIdentifier:dict[@"title"]];
        if(habit == nil){
            habit = [NSEntityDescription insertNewObjectForEntityForName:@"Habit" inManagedObjectContext:context];
            habit.isActive = dict[@"active"];
            habit.reminderTime = [TimeHelper dateComponentsForHour:[dict[@"time_to_do"] integerValue] minute:[dict[@"minute_to_do"] integerValue]];
            habit.order = dict[@"order"];
            habit.createdAt = dict[@"created_at"];
            habit.title = dict[@"title"];
            habit.daysRequired = dict[@"days_required"];
            habit.color = [Colors colorsFromMotion][[dict[@"color_index"] integerValue]];
            habit.identifier = habit.title;

            NSDictionary * daysChecked = dict[@"days_checked"]; // these will be BOOLs
            [self generateChainsForHabit:habit fromDaysChecked:daysChecked context:context];
            
            NSLog(@"Imported %@, chain count %@", habit.title, @(habit.chains.count));
            
            NSError * error;
            [context save:&error];
            if(error) NSLog(@"Error saving private context %@: %@", context, error.localizedDescription);
            [context reset];
        }else{
            NSLog(@"Skipping import of %@", habit.title);
        }
        progress += 1;
        progressCallback( progress / storedCount );
    };
}
+(void)generateChainsForHabit:(Habit*)habit fromDaysChecked:(NSDictionary*)daysChecked context:(NSManagedObjectContext*)context{
    Chain * chain = [NSEntityDescription insertNewObjectForEntityForName:@"Chain" inManagedObjectContext:context];
    [habit addChainsObject:chain];
    NSArray * dayKeys = [daysChecked.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString * dayKey in dayKeys) { // all values are @YES so I can just iterate through the keys
        NSDate * date = [DayKeys dateFromKey:dayKey];
        if(!chain.firstDateCache) chain.firstDateCache = date;
        
        chain = [self returnOrReplaceChain:chain forHabit:habit inContext:context withKey:dayKey onDate: date];
        
        HabitDay * habitDay = [NSEntityDescription insertNewObjectForEntityForName:@"HabitDay" inManagedObjectContext:context];
        habitDay.date = date;
        habitDay.dayKey = dayKey; // just for posterity really.
        [chain addDaysObject:habitDay];

        habitDay.runningTotalCache = @(chain.days.count);
        chain.daysCountCache = @(chain.days.count);
        chain.lastDateCache = date;
    }
    // This affects testing and should hopefully not cause any problems in real life...
    
    if(!chain.firstDateCache) {
        NSLog(@"Warning, setting firstDateCache to %@ for %@", [TimeHelper today], habit.title);
        chain.firstDateCache = [TimeHelper today];
    }
    if(!chain.lastDateCache) {
        NSLog(@"Warning, setting lastDateCache to %@ on %@", [TimeHelper today], habit.title);
        chain.lastDateCache = [TimeHelper today];
    }
}
/**
 *  Is the supplied date longer than one day after the previous chain's latest required date?
 */
+(Chain*)returnOrReplaceChain:(Chain*)chain forHabit:(Habit*)habit inContext:(NSManagedObjectContext*)context withKey:(NSString*)dayKey onDate:(NSDate*) date{
    if(chain.days.count == 0) return chain;
    if([chain.nextRequiredDate compare:date] == NSOrderedAscending){
        // create a new chain
        chain.breakDetected = @YES;
        Chain * newChain = [NSEntityDescription insertNewObjectForEntityForName:@"Chain" inManagedObjectContext:context];
        [habit addChainsObject:newChain];
//        NSLog(@"Replaced chain at date %@", date);
        return newChain;
    }else{
        return chain;
    }
}
@end
