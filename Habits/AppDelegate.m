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
#import "AppFeatures.h"
#import "StatisticsFeaturePurchaseController.h"
#import "Colors.h"
#import <Crashlytics/Crashlytics.h>
//#import <Lookback/Lookback.h>
#import "TimeHelper.h"
#import "HabitDay.h"
#import "Chain.h"
@implementation AppDelegate{
    BOOL hasBeenActiveYet;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [[SVProgressHUD appearance] setHudBackgroundColor:[Colors cobalt]];
//    [[SVProgressHUD appearance] setHudForegroundColor:[UIColor whiteColor]];
//    [[SVProgressHUD appearance] setHudRingBackgroundColor:[UIColor blackColor]];
    [Crashlytics startWithAPIKey:@"3254ccee18a98f4b57c4dc9d4fdd5d961828f59d"];
    [InfoTask trackInstallationDate];
    [AppFeatures setDefaults];
    
//    [Lookback_Weak setupWithAppToken:@"bGofRBSyqLvCF98Nj"];
    
    [[StatisticsFeaturePurchaseController sharedController] listenForTransactions];
//    [Audits initialize];
    [self trackCoreDataChanges]; // put this before dealing with core data to ensure that events are handled (see https://developer.apple.com/library/Mac/documentation/DataManagement/Conceptual/UsingCoreDataWithiCloudPG/UsingSQLiteStoragewithiCloud/UsingSQLiteStoragewithiCloud.html)
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [Notifications registerCategories];
    }
    return YES;
}
-(void)performAnyNecessaryUpgrades{
    if([PlistStoreToCoreDataMigrator dataCanBeMigrated] && [HabitsQueries all].count == 0) {
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
    }
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
////    if([notification.userInfo[@"type"] isEqualToString:@"audit"]){
////        [self showAuditScreenIfNeeded];
////    }
////    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH object:nil userInfo:nil];
////    [HabitsList recalculateAllNotifications];
////    [Notifications reschedule];
//}
-(void)applicationWillResignActive:(UIApplication *)application{
    [HabitsQueries recalculateAllNotifications];
    [Notifications reschedule];
}
-(void)applicationDidBecomeActive:(UIApplication *)application{
    return;
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
    [DataExport scanForJSONFile:^(BOOL success) {
    }];
}
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSArray * components = [url.absoluteString componentsSeparatedByString:@"goodhabits://import?json="];
    if(components.count > 1){
        [[[UIAlertView alloc] initWithTitle:@"Restore data?" message:@"Restore your data? This action will delete your current data. It might also make any iCloud syncing behave strangely. Proceed with caution." cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] otherButtonItems:[RIButtonItem itemWithLabel:@"Restore Data" action:^{
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                BOOL success = [DataExport importDataFromBase64EncodedString:components[1]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if(!success){
                        [[[UIAlertView alloc] initWithTitle:@"Too much data for restore link" message:@"The email restore links turned out to be unreliable for users with a lot of data. To restore from a backup, please copy the `habits_data.json` file to your device using iTunes." cancelButtonItem:[RIButtonItem itemWithLabel:@"Ok"] otherButtonItems:nil] show];
                    }
                });
            });
        }], nil] show];
        return YES;
    }
//    if([url.absoluteString isEqualToString:@"goodhabits://lookback"]){
//        [LookbackRecordingViewController presentOntoScreenAnimated:YES];
//    }
    return NO;
}
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    // Get the notifications types that have been allowed, do whatever with them
    UIUserNotificationType allowedTypes = [notificationSettings types];
    
    NSLog(@"Registered for notification types: %lu", (unsigned long)allowedTypes);
    
    // You can get this setting anywhere in your app by using this:
    // UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
}
-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler{
    if([identifier isEqualToString:@"check"]){
        NSString * identifier = notification.userInfo[@"identifier"];
        Habit * habit = [HabitsQueries findHabitByIdentifier:identifier];
        NSDate * day = [TimeHelper today];
        // some logic duplicated from HabitCell onCheckboxTapped
        Chain * chain = habit.currentChain; // should never be nil; lazily created if habit has no chains
        HabitDay * habitDay = [chain habitDayForDate:day];
        if(habitDay == nil){
            BOOL dateIsTooLateForExistingChain = chain.days.count > 0 && (day.timeIntervalSinceReferenceDate > chain.nextRequiredDate.timeIntervalSinceReferenceDate);
            if(dateIsTooLateForExistingChain){
                chain = [habit addNewChainForToday];
            }
            [chain tickLastDayInChainOnDate:day];
            [[CoreDataClient defaultClient] save];
            [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH object:nil];
            [Notifications reschedule]; // updates badge count
        }
    }
    if([identifier isEqualToString:@"snooze"]){
        UILocalNotification * snooze = [UILocalNotification new];
        snooze.alertBody = [NSString stringWithFormat:@"%@ (snoozed)", notification.alertBody];
        snooze.category = notification.category;
        snooze.fireDate = [[NSDate new] dateByAddingTimeInterval: 60 * 9]; // 9 minutes from now
        snooze.userInfo = notification.userInfo;
        [application scheduleLocalNotification:snooze];
    }
    completionHandler();
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
