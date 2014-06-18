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
static NSMutableArray * allHabits = nil;

@implementation HabitsList
+(NSMutableArray *)all{
    if(!allHabits){
        allHabits = [NSMutableArray new];
    }
    return allHabits;
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
//+(User*)read{
//    NSData * data = [NSData dataWithContentsOfFile:[self currentUserPath]];
//    NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//    if(unarchiver == nil) return nil;
//    User * result = [[User alloc] initWithCoder:unarchiver];
//    [unarchiver finishDecoding];
//    return result;
//}
+(void)saveAll{
//    NSMutableData * data = [NSMutableData data];
//    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//    [[self all] encodeWithCoder:archiver];
//    [archiver finishEncoding];
//    NSLog(@"data: %@", data);
//    [data writeToFile:[self localPath] atomically:YES];
}
+(NSString*)localPath{
    NSString * documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [documentsPath stringByAppendingPathComponent:@"habits"];
}
+(void)overwriteHabits:(NSArray *)array{
    allHabits = array.mutableCopy;
}
#pragma mark - Notifications
+(void)recalculateAllNotifications{
    
}

@end
