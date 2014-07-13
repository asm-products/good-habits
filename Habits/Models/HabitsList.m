//
//  HabitsList.m
//  Habits
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "HabitsList.h"
#import <NSArray+F.h>
#import "Colors.h"
#import "CoreDataClient.h"
#import <Mantle.h>
#import "TimeHelper.h"
static NSMutableArray * __allHabits = nil;
static CoreDataClient * __coreDataClient = nil;

@implementation HabitsList
+(NSMutableArray *)all{
    if(!__allHabits) {
        __allHabits = [NSMutableArray new];
        [self loadFromCoreData];
    }
    return __allHabits;
}

#pragma mark - Groups
+(NSArray *)active{
    return [[[self all] filter:^BOOL(Habit* habit) {
        return habit.isActive.boolValue;
    }] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
}
+(NSArray *)activeToday{
    return [self.active filter:^BOOL(Habit * habit) {
        return habit.isRequiredToday;
    }];
}
+(NSArray *)activeButNotToday{
    return [self.active filter:^BOOL(Habit * habit) {
        return !habit.isRequiredToday && habit.currentChainLength != 0;
    }];
}
+(NSArray *)carriedOver{
    return [self.active filter:^BOOL(Habit * habit) {
        return !habit.isRequiredToday && habit.currentChainLength == 0;
    }];
}
+(NSArray *)inactive{
    return [self.all filter:^BOOL(Habit * habit) {
        return !habit.isActive.boolValue;
    }];
}
+(NSInteger)habitCountForDate:(NSDate *)day{
    NSInteger count = 0;
    for(Habit * habit in [self active]) {
        if([habit isRequiredOnWeekday:day]) count += 1;
    }
    return count;
}
+(NSInteger)nextOrder{
    return [[self all] count];
}

+(NSInteger)nextUnusedColorIndex{
    return self.all.count % [Colors colorsFromMotion].count;
}
#pragma mark - Data management
+(void)loadFromCoreData{
    [self refreshFromManagedObjectContext: [self coreDataClient].managedObjectContext ];
}
+(void)refreshFromManagedObjectContext:(NSManagedObjectContext *)context{
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Habit"];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES ]]];
    NSArray * entities = [context executeFetchRequest:request error:nil];
    if(!entities) return;
    __allHabits = [entities map:^id(NSManagedObject * entity) {
        if([entity valueForKey:@"identifier"] == nil) {
//            [entity setValue: [[NSUUID UUID] UUIDString] forKey:@"identifier"];
            [[self coreDataClient].managedObjectContext deleteObject:entity];
            return nil;
        }
        Habit * result = [MTLManagedObjectAdapter modelOfClass:[Habit class] fromManagedObject:entity error:nil];
        for (NSString * key in result.daysChecked) {
            if([[TimeHelper now] isBefore:[Habit dateFromString:key]]){
                NSLog(@"Removing future key %@", key);
                [result.daysChecked removeObjectForKey:key];
            }
        }
        return result;
    }].mutableCopy;
    
}
+(void)deleteHabit:(Habit *)habit{
    [__allHabits removeObject:habit];
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Habit"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier == %@", habit.identifier];
    NSArray * results = [self.coreDataClient.managedObjectContext executeFetchRequest:request error:nil];
    NSLog(@"Deleting %@", results);
    if (results.count > 0) {
        [self.coreDataClient.managedObjectContext deleteObject:results.firstObject];
    }
}
+(CoreDataClient*)coreDataClient{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __coreDataClient = [CoreDataClient new];
    });
    return __coreDataClient;
}
+(void)saveAll{
    for(Habit * habit in [self all]){
        NSError * error;
        [MTLManagedObjectAdapter managedObjectFromModel:habit insertingIntoContext:[self coreDataClient].managedObjectContext error:&error];
        if(error) NSLog(@"ERROR SAVING HABIT! %@", error);
    }
    [[self coreDataClient] saveInBackground];
}
+(NSString*)localPath{
    NSString * documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [documentsPath stringByAppendingPathComponent:@"habits"];
}
+(void)overwriteHabits:(NSArray *)array{
    __allHabits = array.mutableCopy;
    for(Habit * habit in __allHabits) [habit recalculateLongestChain];
    [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:nil userInfo:nil];
    
//    [self saveAll];
}
#pragma mark - Notifications
+(void)recalculateAllNotifications{
    for(Habit *habit in self.active){
        [habit recalculateNotifications];
    }
}

@end
