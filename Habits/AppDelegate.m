//
//  AppDelegate.m
//  Habits
//
//  Created by Michael Forrest on 27/04/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "AppDelegate.h"
#import "PlistStoreToCoreDataMigrator.h"
#import "InfoTask.h"
#import "Habit.h"
#import "HabitsQueries.h"
#import "CoreDataClient.h"
#import "Notifications.h"
#import "DataExport.h"
#import <UIAlertView+Blocks.h>
#import <SVProgressHUD.h>
#import "StatisticsFeaturePurchaseController.h"
@implementation AppDelegate{
    BOOL hasBeenActiveYet;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [InfoTask trackInstallationDate];
    [[StatisticsFeaturePurchaseController sharedController] listenForTransactions];
//    [Audits initialize];
    [self trackCoreDataChanges]; // put this before dealing with core data to ensure that events are handled (see https://developer.apple.com/library/Mac/documentation/DataManagement/Conceptual/UsingCoreDataWithiCloudPG/UsingSQLiteStoragewithiCloud/UsingSQLiteStoragewithiCloud.html)
    
    return YES;
}
-(void)performAnyNecessaryUpgrades{
//    if([MotionToMantleMigrator dataCanBeMigrated] && [HabitsList all].count == 0) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PlistStoreToCoreDataMigrator performMigrationWithArray:[PlistStoreToCoreDataMigrator habitsStoredByMotion] progress:^(float progress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showProgress:progress status:@"Upgrading" maskType:SVProgressHUDMaskTypeBlack];
                });
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [HabitsQueries refresh];
                [SVProgressHUD dismiss];
                [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:nil];
            });
        });
//    }
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
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
//    if([notification.userInfo[@"type"] isEqualToString:@"audit"]){
//        [self showAuditScreenIfNeeded];
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH object:nil userInfo:nil];
//    [HabitsList recalculateAllNotifications];
//    [Notifications reschedule];
}
-(void)applicationWillResignActive:(UIApplication *)application{
    [HabitsQueries recalculateAllNotifications];
    [Notifications reschedule];
}
-(void)applicationDidBecomeActive:(UIApplication *)application{
    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH object:nil userInfo:nil];
//    [self showAuditScreenIfNeeded];
    [HabitsQueries recalculateAllNotifications];
    [Notifications reschedule];
    if(!TEST_ENVIRONMENT){
        if(!hasBeenActiveYet){
            [self performAnyNecessaryUpgrades];
        }
    }
    hasBeenActiveYet = YES;
    
}
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSArray * components = [url.absoluteString componentsSeparatedByString:@"goodhabits://import?json="];
    if(components.count > 1){
        [[[UIAlertView alloc] initWithTitle:@"Restore data?" message:@"Restore your data? This action will delete your current data. It might also make any iCloud syncing behave strangely. Proceed with caution." cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] otherButtonItems:[RIButtonItem itemWithLabel:@"Restore Data" action:^{
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [DataExport importDataFromBase64EncodedString:components[1]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            });


        }], nil] show];
        return YES;
    }
    return NO;
}
//-(BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder{
//    return YES;
//}
//-(BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder{
//    NSString * restoringFrom = [coder decodeObjectForKey:UIApplicationStateRestorationBundleVersionKey];
//    if(restoringFrom.integerValue < 2.0) return NO;
//    return YES;
//}

@end
