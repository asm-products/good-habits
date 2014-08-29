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
        return !habit.isRequiredToday;// && [habit.sortedChains.lastObject runningTotalCache] != 0;
    }];
}
+(NSArray *)carriedOver{
    return [self.active filter:^BOOL(Habit * habit) {
        return !habit.isRequiredToday;// && [habit.sortedChains.lastObject runningTotalCache] == 0;
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

@end
