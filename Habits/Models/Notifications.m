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
#import "HabitsList.h"
#import "Audits.h"
@implementation Notifications
+(void)reschedule{
    NSLog(@"Rescheduling notifications");
    NSDate * now = [TimeHelper now];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[[HabitsList active] filter:^BOOL(Habit * h) {
        return [h needsToBeDone: now];
    }] count]];
    NSMutableArray * notifications = [[NSMutableArray alloc] initWithCapacity:100];
    for (Habit * habit in [HabitsList active]) {
        [notifications addObjectsFromArray:habit.notifications];
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
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
        notification.applicationIconBadgeNumber = [HabitsList habitCountForDate: day];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
    [self scheduleAuditNotification];
}
+(void)scheduleAuditNotification{
    NSDateComponents * components = [Audits scheduledTime];
    if(!components) return;
    UILocalNotification * notification = [UILocalNotification new];
    NSDateComponents * todayComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[TimeHelper now]];
    todayComponents.hour = components.hour;
    todayComponents.minute = components.minute;
    NSDate * nextDate = [[NSCalendar currentCalendar] dateFromComponents:todayComponents];
    NSArray * habitsDue = [Audits habitsToBeAudited];
    if(habitsDue.count == 0){
        nextDate = [TimeHelper addDays:1 toDate:nextDate];
    }
    notification.fireDate = nextDate;
    notification.repeatInterval = NSDayCalendarUnit;
    notification.soundName = UILocalNotificationDefaultSoundName;
    NSInteger count = (habitsDue.count == 0) ? [HabitsList habitCountForDate:nextDate] : habitsDue.count;
    NSString * message = [NSString stringWithFormat:@"%@ habit%@ due", @(count), count == 1 ? @"" : @"s"];
    notification.alertBody = message;
    notification.userInfo = @{@"type": @"audit"};
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}
@end
