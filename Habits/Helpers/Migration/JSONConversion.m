//
//  JSONImporter.m
//  Habits
//
//  Created by Michael Forrest on 15/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "JSONConversion.h"
#import "Habit.h"
#import "HabitsQueries.h"
#import <NSArray+F.h>
#import <AVHexColor.h>
#import "TimeHelper.h"
#import "Calendar.h"
#import <Mantle.h>
#import "Chain.h"
#import "HabitDay.h"
@implementation JSONConversion
+(NSArray *)allHabitsAsJSONWithClient:(CoreDataClient *)coreDataClient{
    NSArray * allHabits = [HabitsQueries fetchedResultsControllerForClient:coreDataClient].fetchedObjects;
    return [allHabits map:^NSDictionary*(Habit * habit) {
        NSMutableDictionary * result = [NSMutableDictionary new];
        result[@"identifier"] = habit.identifier;
        result[@"title"] = habit.title;
        result[@"color"] = [AVHexColor hexStringFromColor:habit.color];
        result[@"createdAt"] =  [[TimeHelper jsonDateFormatter] stringFromDate:habit.createdAt ? habit.createdAt : [NSDate date]]; // this hack is because during testing I accidentally created habits with no createdAt date but I didn't want to go back and repopulate everything. 
        if(habit.reminderTime)
            result[@"reminderTime"] = [[self reminderTimeJSONTransformer] reverseTransformedValue:habit.reminderTime];
        
        result[@"isActive"] = habit.isActive;
        result[@"order"] = habit.order;
        result[@"daysRequired"] = [[self daysRequiredJSONTransformer] reverseTransformedValue:habit.daysRequired];
        result[@"chains"] = [habit.sortedChains map:^NSDictionary*(Chain *chain) {
            NSMutableDictionary * result = [NSMutableDictionary new];
            result[@"days"] = [chain.sortedDays map:^NSDictionary*(HabitDay *day) {
                NSMutableDictionary * result = [NSMutableDictionary new];
                result[@"date"] = [[TimeHelper jsonDateFormatter] stringFromDate:day.date];
                result[@"runningTotal"] = day.runningTotalCache;
                return result;
            }];
            return result;
        }];
        
        return result;
    }];
}
+(void)performImportWithArray:(NSArray *)array{
    CoreDataClient * client = [CoreDataClient defaultClient];
    NSManagedObjectContext * context = [client createPrivateContext];
    for (NSDictionary * dict in array) {
        NSString * identifier = dict[@"identifier"];
        Habit * habit = [HabitsQueries findHabitByIdentifier:identifier];
        if(habit == nil){
            habit = [NSEntityDescription insertNewObjectForEntityForName:@"Habit" inManagedObjectContext:context];
            habit.isActive = dict[@"isActive"];
            if(dict[@"reminderTime"]) habit.reminderTime = [[self reminderTimeJSONTransformer] transformedValue:dict[@"reminderTime"]];
            habit.order = dict[@"order"];
            habit.createdAt = [[TimeHelper jsonDateFormatter] dateFromString:dict[@"createdAt"]];
            habit.title = dict[@"title"];
            habit.identifier = dict[@"identifier"];
            habit.daysRequired = [[self daysRequiredJSONTransformer] transformedValue:dict[@"daysRequired"]];
            habit.color = [AVHexColor colorWithHexString:dict[@"color"]];
            
            for (NSDictionary * chainDict in dict[@"chains"]) {
                Chain * chain = [NSEntityDescription insertNewObjectForEntityForName:@"Chain" inManagedObjectContext:context];
                [habit addChainsObject:chain];
                for (NSDictionary * dayDict in chainDict[@"days"]) {
                    HabitDay * day = [NSEntityDescription insertNewObjectForEntityForName:@"HabitDay" inManagedObjectContext:context];
                    day.date = [[TimeHelper jsonDateFormatter] dateFromString:dayDict[@"date"]];
                    day.runningTotalCache = dayDict[@"runningTotal"];
                    [chain addDaysObject:day];
                }
            }
            
            
            NSLog(@"Imported %@, chain count %@", habit.title, @(habit.chains.count));
            
            NSError * error;
            [context save:&error];
            if(error) NSLog(@"Error saving private context %@: %@", context, error.localizedDescription);
            [context reset];
        }else{
            NSLog(@"Skipped importing habit data for %@", identifier);
        }
    }
    [HabitsQueries refresh];
}
#pragma mark - Value transformers

+(NSValueTransformer*)daysRequiredJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSArray * array) {
        return [[Calendar days] map:^id(NSString * dayName) {
            return @([array indexOfObject:dayName] != NSNotFound);
        }];
    } reverseBlock:^id(NSArray*array){
        return [[[Calendar days] map:^id(NSString *day) {
            NSInteger index = [[Calendar days] indexOfObject:day];
            if (index > array.count - 1) return [NSNull null];
            return [array[index] boolValue] ? day : [NSNull null];
        }] filter:^BOOL(id obj) {
            return obj == [NSNull null] ? NO : YES;
        }];
    }];
}
+(NSValueTransformer*)reminderTimeJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString*string) {
        NSArray * bits = [string componentsSeparatedByString:@":"];
        NSDateComponents * result = [NSDateComponents new];
        if(bits.count < 2) return nil;
        result.hour = [bits[0] integerValue];
        result.minute = [bits[1] integerValue];
        return result;
        
    } reverseBlock:^id(NSDateComponents*components) {
        static NSDateFormatter * formatter = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            formatter = [NSDateFormatter new];
            formatter.dateFormat = @"HH:mm";
        });
        NSDate * date = [[NSCalendar currentCalendar] dateFromComponents:components];
        NSString* result = [formatter stringFromDate:date];
        return result;
    }];
}

@end
