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
#import "CoreDataClient.h"
#import "Notifications.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [InfoTask trackInstallationDate];
    [self trackCoreDataChanges]; // put this before dealing with core data to ensure that events are handled (see https://developer.apple.com/library/Mac/documentation/DataManagement/Conceptual/UsingCoreDataWithiCloudPG/UsingSQLiteStoragewithiCloud/UsingSQLiteStoragewithiCloud.html)
    
    if([MotionToMantleMigrator dataCanBeMigrated] && [HabitsList all].count == 0) {
        [MotionToMantleMigrator performMigration];
    }
    [HabitsList recalculateAllNotifications];
    [Notifications reschedule];
    return YES;
}
-(void)afterEvent:(NSString*)event performBlock:(void(^)())block{
    [[NSNotificationCenter defaultCenter]
     addObserverForName:event
     object:nil
     queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification *note) {
         block();
     }];
}
-(void)trackCoreDataChanges{
    // WILL CHANGE - disable UI
    [self afterEvent:NSPersistentStoreCoordinatorStoresWillChangeNotification performBlock:^{
        self.window.userInteractionEnabled = NO;
    }];
    // DID CHANGE - re-enable
    [self afterEvent:NSPersistentStoreCoordinatorStoresDidChangeNotification performBlock:^{
        self.window.userInteractionEnabled = YES;
    }];
}

-(void)applicationWillEnterForeground:(UIApplication *)application{
    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH object:nil userInfo:nil];
}
-(void)applicationSignificantTimeChange:(UIApplication *)application{
    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH object:nil userInfo:nil];
    
}
//-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
//    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH object:nil userInfo:nil];
//    [HabitsList recalculateAllNotifications];
//    [Notifications reschedule];
//}
-(void)applicationWillResignActive:(UIApplication *)application{
    [HabitsList recalculateAllNotifications];
    [Notifications reschedule];
}
-(void)applicationDidBecomeActive:(UIApplication *)application{
    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH object:nil userInfo:nil];
    
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
