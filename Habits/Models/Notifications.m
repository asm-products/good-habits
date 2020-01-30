//
//  Notifications.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "Notifications.h"
#import "TimeHelper.h"
#import "Habit.h"
#import <NSArray+F.h>
#import "HabitsCommon.h"
#import "HabitsQueries.h"
@import UserNotifications;

@implementation Notifications
+(void)reschedule{
    NSLog(@"Rescheduling notifications");
    [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
        NSLog(@"%lu pending notification(s)", (unsigned long)requests.count);
    }];
    NSDate * now = [TimeHelper now];
    NSDate * today = [TimeHelper today];
    NSInteger requiredTodayCount = [[HabitsQueries outstandingToday] count];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:requiredTodayCount];
    NSMutableArray * notifications = [[NSMutableArray alloc] initWithCapacity:100];
    for (Habit * habit in [HabitsQueries active]) {
        [notifications addObjectsFromArray:habit.notifications];
    }
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
//    [[UIApplication sharedApplication] cancelAllLocalNotifications]; // deprecated
    for(UILocalNotification * notification in notifications){
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    for(int n = 1; n < 7; n++){
        NSDate * day = [TimeHelper addDays:n toDate:now];
        UILocalNotification * notification = [UILocalNotification new];
        NSDateComponents * components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:day];
        components.hour = 6;
        components.minute = 0;
        notification.fireDate = [[NSCalendar currentCalendar] dateFromComponents:components];
        notification.applicationIconBadgeNumber = [HabitsQueries habitCountForDate: day];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}
+(void)registerCategories{
    UIMutableUserNotificationAction * check = [UIMutableUserNotificationAction new];
    check.identifier = @"check";
    check.title = NSLocalizedString(@"Mark completed", "Button to mark habit completed from notification");
    check.activationMode = UIUserNotificationActivationModeBackground;
    
    UIMutableUserNotificationAction * snooze = [UIMutableUserNotificationAction new];
    snooze.identifier = @"snooze";
    snooze.title = NSLocalizedString(@"Snooze", "Snooze button text");
    snooze.activationMode = UIUserNotificationActivationModeBackground;
    
    UIMutableUserNotificationCategory * category = [UIMutableUserNotificationCategory new];
    category.identifier = @"Checkable";
    [category setActions:@[check,snooze] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet * categories = [NSSet setWithObject:category];
    NSUInteger types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
    UIUserNotificationSettings * settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    
}
@end
