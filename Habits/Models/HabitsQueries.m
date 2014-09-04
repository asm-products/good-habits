//
//  HabitsList.m
//  Habits
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "HabitsQueries.h"
#import <NSArray+F.h>
#import "Colors.h"
#import "CoreDataClient.h"
#import <Mantle.h>
#import "TimeHelper.h"
#import "HabitDay.h"
#import <SVProgressHUD.h>
#import "CoreDataClient.h"
#import "Chain.h"
@implementation HabitsQueries
+(NSFetchedResultsController*)fetched{
    static NSFetchedResultsController * fetched = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Habit"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]];
        fetched = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[CoreDataClient defaultClient].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        NSError * error;
        [fetched performFetch:&error];
        if(error) NSLog(@"Error initially fetching habits %@", error.localizedDescription);
    });
    return fetched;
}
+(NSArray*)all{
    return [self fetched].fetchedObjects;
}
+(void)refresh{
    NSError * error;
    [self.fetched performFetch:&error];
    if(error) NSLog(@"Error fetching habits %@", error.localizedDescription);
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
        NSLog(@"%@ activeButNotToday: required today? %@ nextRequiredDate: %@, today: %@", habit.title, @(habit.isRequiredToday), habit.currentChain.nextRequiredDate, [TimeHelper today] );
        return !habit.isRequiredToday && habit.currentChain.nextRequiredDate.timeIntervalSinceReferenceDate > [TimeHelper today].timeIntervalSinceReferenceDate;
    }];
}
+(NSArray *)carriedOver{
    return [self.active filter:^BOOL(Habit * habit) {
        BOOL chainHasNotBeenBroken = habit.currentChain.nextRequiredDate.timeIntervalSinceReferenceDate <= [TimeHelper today].timeIntervalSinceReferenceDate;
//        BOOL wasNotDoneOnTheScheduledDay =
        // I'm gonna come back to these when I have implemented the ticking saving and chain breaking flow
        return !habit.isRequiredToday && chainHasNotBeenBroken;
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
+(Habit *)findHabitByIdentifier:(NSString *)identifier{
    return [[[self all] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", identifier]] firstObject];
}
+(Habit *)findHabitByTitle:(NSString *)identifier{
    return [[[self all] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title == %@", identifier]] firstObject];
}
#pragma mark - Data management
+(NSString*)localPath{
    NSString * documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [documentsPath stringByAppendingPathComponent:@"habits"];
}
#pragma mark - Notifications
+(void)recalculateAllNotifications{
    for(Habit *habit in self.active){
        [habit recalculateNotifications];
    }
}
#pragma mark - Destructive
+(void)deleteAllHabits{
    [self refresh];
    for (Habit*habit in [self all]) {
        [[CoreDataClient defaultClient].managedObjectContext deleteObject:habit];
    }
    NSError * error;
    [[CoreDataClient defaultClient].managedObjectContext save:&error];
    if(error) NSLog(@"Error deleting all habits %@", error);
}
@end
