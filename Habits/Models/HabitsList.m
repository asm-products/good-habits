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
+(void)deleteHabit:(Habit *)habit{
    [[self all] removeObject:habit];
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
    __allHabits = [entities map:^id(NSManagedObject * entity) {
        return [MTLManagedObjectAdapter modelOfClass:[Habit class] fromManagedObject:entity error:nil];
    }].mutableCopy;
 
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
//    [self saveAll];
}
#pragma mark - Notifications
+(void)recalculateAllNotifications{
    for(Habit *habit in self.active){
        [habit recalculateNotifications];
    }
}

@end
