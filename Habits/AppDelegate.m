//
//  AppDelegate.m
//  Habits
//
//  Created by Michael Forrest on 27/04/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "AppDelegate.h"
#import "MotionToMantleMigrator.h"
#import "InfoTask.h"
#import "Habit.h"
#import "HabitsList.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [InfoTask trackInstallationDate];
    if([MotionToMantleMigrator detectsMigrationRequired]) [MotionToMantleMigrator performMigration];
    [HabitsList recalculateAllNotifications];
    return YES;
}
-(BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder{
    return YES;
}
-(BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder{
    NSString * restoringFrom = [coder decodeObjectForKey:UIApplicationStateRestorationBundleVersionKey];
    if(restoringFrom.integerValue < 2.0) return NO;
    return YES;
}

@end
