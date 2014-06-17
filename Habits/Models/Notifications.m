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
@implementation Notifications
+(void)reschedule{
    NSDate * now = [TimeHelper now];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[[Habit active] filter:^BOOL(Habit * h) {
        return [h needsToBeDone: now];
    }] count]];
    NSMutableArray * notifications = [[NSMutableArray alloc] initWithCapacity:100];
    for (Habit * habit in [Habit active]) {
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
        notification.applicationIconBadgeNumber = [Habit habitCountForDate: day];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
}
@end
