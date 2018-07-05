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
#import "Habits-Swift.h"
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
    
    source = [self useProperty:@"title" toPopulateUniqueIdentifierProperty: @"identifier" withArray:source];
    
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
            habit.identifier = dict[@"identifier"];

            NSDictionary * daysChecked = dict[@"days_checked"]; // these will be BOOLs
            [self generateChainsForHabit:habit fromDaysChecked:daysChecked.allKeys context:context];
            
            NSLog(@"Imported %@, chain count %@", habit.title, @(habit.chains.count));
            
            NSError * error;
            [context save:&error];
            if(error) NSLog(@"Error saving private context %@: %@", context, error.localizedDescription);
//            [context reset];
        }else{
            NSLog(@"Skipping import of %@", habit.title);
        }
        progress += 1;
        progressCallback( progress / storedCount );
    };
}
/**
 *  Returns an array with unique identifiers based on the @sourceKey value. Basically just appends full stops.
 *
 *  @param sourceKey      Key to use (e.g. @"title")
 *  @param destinationKey Key to populate in result (e.g. @"identifier")
 *  @param source         Array of dictionaries
 */
+(NSArray *)useProperty:(NSString *)sourceKey toPopulateUniqueIdentifierProperty:(NSString *)destinationKey withArray:(NSArray *)source{
   NSMutableDictionary * uniquelyNamedItems = [[NSMutableDictionary alloc] initWithCapacity:source.count];
    [source enumerateObjectsUsingBlock:^(NSDictionary * dict, NSUInteger index, BOOL *stop) {
        NSMutableString * identifier = [dict[sourceKey] mutableCopy];
        while (uniquelyNamedItems[identifier] != nil) {
            [identifier appendString:@"."];
        }
        NSMutableDictionary * mutableDict = dict.mutableCopy;
        mutableDict[destinationKey] = identifier;
        mutableDict[@"__sort"] = @(index);
        uniquelyNamedItems[identifier] = mutableDict;
    }];
    return [uniquelyNamedItems.allValues sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"__sort" ascending:YES]]];
}
+(void)generateChainsForHabit:(Habit*)habit fromDaysChecked:(NSArray*)daysChecked context:(NSManagedObjectContext*)context{
    NSArray * dayKeys = [daysChecked sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    Chain * chain = [habit addNewChainInContext:context];
    for (NSString * dayKey in dayKeys) { // all values are @YES so I can just iterate through the keys
        NSDate * date = [DayKeys convertKeyToDate:dayKey];
        
        chain = [self returnOrReplaceChain:chain forHabit:habit inContext:context withKey:dayKey onDate: date];
        
        HabitDay * habitDay = [NSEntityDescription insertNewObjectForEntityForName:@"HabitDay" inManagedObjectContext:context];
        habitDay.date = date;
        habitDay.dayKey = dayKey; // just for posterity really.
        [chain addDaysObject:habitDay];
        if(!chain.firstDateCache) chain.firstDateCache = date;

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
        Chain * newChain = [habit addNewChainInContext:context];
        newChain.firstDateCache = date;
//        NSLog(@"Replaced chain at date %@", date);
        NSLog(@"Chain %@, firstDateCache: %@ lastDateCache: %@", [chain.sortedDays valueForKey:@"date"], chain.firstDateCache, chain.lastDateCache);

        return newChain;
    }else{
        return chain;
    }
}
@end
