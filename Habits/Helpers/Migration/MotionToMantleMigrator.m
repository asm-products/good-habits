//
//  MotionToMantleMigrator.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "MotionToMantleMigrator.h"
#import <NSArray+F.h>
#import "Habit.h"
#import "TimeHelper.h"
#import "Colors.h"
#import "Constants.h"
@implementation MotionToMantleMigrator
//@property (nonatomic, strong) NSString * title;
//@property (nonatomic) NSInteger colorIndex;
//@property (nonatomic, strong) NSDate * createdAt;
//@property (nonatomic, strong) NSArray * daysChecked;
//@property (nonatomic) NSInteger hourToDo;
//@property (nonatomic) NSInteger minuteToDo;
//@property (nonatomic) BOOL active;
//@property (nonatomic) NSInteger order;
//@property (nonatomic, strong) NSArray * daysRequired;
//@property (nonatomic, strong) NSArray * notifications;
+(BOOL)detectsMigrationRequired{
    return  [self habitsStoredByMotion] != nil;
}
+(NSArray*)habitsStoredByMotion{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"goodtohear.habits_habits"];
}
+(void)performMigration{
    NSArray * habits = [[self habitsStoredByMotion] map:^id(NSDictionary * dict) {
        Habit * habit = [Habit new];
        habit.isActive = dict[@"active"];
        habit.reminderTime = [TimeHelper dateComponentsForHour:[dict[@"time_to_do"] integerValue] minute:[dict[@"minute_to_do"] integerValue]];
        habit.daysChecked = dict[@"days_checked"]; // these will be BOOLs
        habit.order = dict[@"order"];
        habit.createdAt = dict[@"created_at"];
        habit.title = dict[@"title"];
        habit.daysRequired = dict[@"days_required"];
        habit.color = [Colors colorsFromMotion][[dict[@"color_index"] integerValue]];
        return habit;
    }];
    [Habit overwriteHabits: habits];
}

@end
