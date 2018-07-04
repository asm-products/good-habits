//
//  LegacyJSONConverter.m
//  Habits
//
//  Created by Michael Forrest on 15/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "LegacyJSONImporter.h"
#import <NSArray+F.h>
#import "CoreDataClient.h"
#import "Habit.h"
#import "HabitsQueries.h"
#import "TimeHelper.h"
#import "Calendar.h"
#import <AVHexColor.h>
#import "Chain.h"
#import "PlistStoreToCoreDataMigrator.h"
@implementation LegacyJSONImporter
/**
 *  Similar to PlistStoreToCoreDataMigrator
 */
+(void)performMigrationWithArray:(NSArray*)array;
{
    CoreDataClient * client = [CoreDataClient defaultClient];
    NSManagedObjectContext * context = [client createPrivateContext];
    for (NSDictionary * dict in array) {
        NSString * title = dict[@"title"];
        Habit * habit = [HabitsQueries findHabitByIdentifier:title];
        if(habit == nil){
            habit = [NSEntityDescription insertNewObjectForEntityForName:@"Habit" inManagedObjectContext:context];
            habit.isActive = dict[@"active"];
            // time_to_do: 11:0 , 8:0, null, etc...
            if(dict[@"time_to_do"] != [NSNull null]){
                NSArray * components = [dict[@"time_to_do"] componentsSeparatedByString:@":"];
                if(components.count == 2){
                    habit.reminderTime = [TimeHelper dateComponentsForHour:[components[0
                                                                                   ] integerValue] minute:[components[1] integerValue]];
                }else{
                    NSLog(@"Error parsing reminder time %@", dict[@"time_to_do"]);
                }
            }
            habit.order = dict[@"order"];
            habit.createdAt = [[TimeHelper jsonDateFormatter] dateFromString:dict[@"created_at"]];
            habit.title = title;
            NSArray * days = dict[@"days_required"];
            habit.daysRequired = [[Calendar days] map:^id(NSString * dayName) {
                return @([days indexOfObject:dayName] != NSNotFound);
            }];
            habit.color = [AVHexColor colorWithHexString:dict[@"color"]];
            habit.identifier = title;
            
            NSArray * daysChecked = dict[@"days_checked"];
            [PlistStoreToCoreDataMigrator generateChainsForHabit: habit fromDaysChecked:daysChecked context: context];
            NSLog(@"Imported %@, chain count %@", habit.title, @(habit.chains.count));
            
            
            NSError * error;
            [context save:&error];
            if(error) NSLog(@"Error saving private context %@: %@", context, error.localizedDescription);
//            [context reset];
        }else{
            NSLog(@"Skipping import of %@", title);
        }
    }
}
@end
