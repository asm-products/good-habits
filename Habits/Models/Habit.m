//
//  Habit.m
//  Habits
//
//  Created by Michael Forrest on 27/04/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "Habit.h"
#import <NSArray+F.h>
#import <NSNumber+F.h>
#import <NSDictionary+F.h>
#import "Colors.h"
#import "TimeHelper.h"
#import <YLMoment.h>
#import "Calendar.h"
#import "HabitsQueries.h"
#import <AVHexColor.h>
#import "DayKeys.h"
#import "Chain.h"

@implementation Habit
@dynamic identifier,title,color,createdAt,reminderTime,isActive,order,daysRequired,chains;
@synthesize notifications;
#pragma mark - MTLManagedObjectSerializing
+(NSString *)managedObjectEntityName{
    return @"Habit";
}
+(NSSet *)propertyKeysForManagedObjectUniquing{
    return [NSSet setWithObject:@"identifier"];
}
+(NSDictionary *)managedObjectKeysByPropertyKey{
    return @{
             @"notifications": [NSNull null],
             @"habitDays": [NSNull null],
             @"entity": [NSNull null]
             };
}
#pragma mark - MTLJSONSerializing
+(NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{@"createdAt": @"created_at",
             @"daysChecked":@"days_checked",
             @"reminderTime":@"time_to_do",
             @"isActive":@"active",
             @"daysRequired":@"days_required",
             @"identifier": @"id",
             @"habitDays": @"days",
             @"notifications": [NSNull null],
             @"entity": [NSNull null]
             };
}
+(NSValueTransformer*)colorJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString * colorString) {
        return [AVHexColor colorWithHexString:colorString];
    } reverseBlock:^id(UIColor * color) {
        return [AVHexColor hexStringFromColor:color];
    }];
}
+(NSValueTransformer*)createdAtJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString * string) {
        return [[TimeHelper jsonDateFormatter] dateFromString:string];
    } reverseBlock:^id(NSDate*date) {
        return [[TimeHelper jsonDateFormatter] stringFromDate:date];
    }];
}
+(NSValueTransformer*)daysRequiredJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSArray * array) {
        return [[Calendar days] map:^id(NSString * dayName) {
            return @([array indexOfObject:dayName] != NSNotFound);
        }];
    } reverseBlock:^id(NSArray*array){
        return [[[Calendar days] map:^id(NSString *day) {
            NSInteger index = [[Calendar days] indexOfObject:day];
            if (index > array.count - 1) return [NSNull null];
            return [array[index] boolValue] ? day : [NSNull null];
        }] filter:^BOOL(id obj) {
            return obj == [NSNull null] ? NO : YES;
        }];
    }];
}
+(NSValueTransformer*)reminderTimeJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString*string) {
        NSArray * bits = [string componentsSeparatedByString:@":"];
        NSDateComponents * result = [NSDateComponents new];
        if(bits.count < 2) return nil;
        result.hour = [bits[0] integerValue];
        result.minute = [bits[1] integerValue];
        return result;
        
    } reverseBlock:^id(NSDateComponents*components) {
        static NSDateFormatter * formatter = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            formatter = [NSDateFormatter new];
            formatter.dateFormat = @"HH:mm";
        });
        NSDate * date = [[NSCalendar currentCalendar] dateFromComponents:components];
        NSString* result = [formatter stringFromDate:date];
        return result;
    }];
}
+(NSValueTransformer*)habitDaysJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSArray*json) {
        NSError * error;
        return [MTLJSONAdapter modelsOfClass:[HabitDay class] fromJSONArray:json error:&error];
    } reverseBlock:^id(NSArray*models) {
        return [MTLJSONAdapter JSONArrayFromModels:models];
    }];
}
#pragma mark - Individual state
-(BOOL)isRequiredToday{
    return [self isRequiredOnWeekday:[TimeHelper today]];
}
-(BOOL)done:(NSDate *)date{
//    [self chainForDate:date]
    return YES; //[self habitDayForDate:date].isChecked.boolValue;
}
-(BOOL)due:(NSDate *)date{
    if(!self.isActive.boolValue) return NO;
    if(![self isRequiredOnWeekday:date]) return NO;
    if(!self.reminderTime) return NO;
    NSDateComponents * components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:date];
    return components.hour > self.reminderTime.hour && components.minute > self.reminderTime.minute;
}
-(BOOL)isRequiredOnWeekday:(NSDate *)date{
    return [self.daysRequired[[TimeHelper weekday:date]] boolValue];
}
-(BOOL)needsToBeDone:(NSDate *)date{
    return NO; //![self done:date] && [self isRequiredOnWeekday:date];
}
-(BOOL)hasReminders{
    return self.reminderTime != nil;
}
-(BOOL)isNew{
    return [self.title isEqualToString:@"New Habit"]; // brittle
}
-(NSDate *)nextDayRequiredAfter:(NSDate *)date{
    date = [TimeHelper addDays:1 toDate:date];
    while(![self isRequiredOnWeekday:date]){
        date = [TimeHelper addDays:1 toDate:date];
    }
    return date;
}
#pragma mark - Meta
-(NSDate*)earliestDate{
    Chain * chain = self.sortedChains.firstObject;
    HabitDay * firstDay = chain.sortedDays.firstObject;
    return firstDay.date;
}
#pragma mark - Interactions

#pragma mark - Chains
-(NSArray *)sortedChains{
    return [self.chains sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastDateCache" ascending:YES]]];
}
-(Chain*)longestChain{
    return [[self.chains sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"daysCountCache" ascending:YES]]] lastObject];
}
-(NSInteger)currentChainLength{
    return [self.currentChain.daysCountCache integerValue];
}
-(Chain *)currentChain{
    return self.sortedChains.lastObject;
}
-(Chain *)chainForDate:(NSDate *)date{
    NSArray * chains = [self.sortedChains filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"firstDateCache <= %@", date]];
    if(chains.count == 0){
        Chain * chain = [NSEntityDescription insertNewObjectForEntityForName:@"Chain" inManagedObjectContext:[CoreDataClient defaultClient].managedObjectContext];
        [self addChainsObject:chain];
        return chain;
    }else{
        return chains.lastObject;
    }
}
-(void)recalculateRunningTotalsInBackground:(void (^)())completionCallback{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext * privateContext = [[CoreDataClient defaultClient] createPrivateContext];
        Habit * habit = (Habit*)[privateContext objectWithID:self.objectID];
        for (Chain * chain in habit.chains) {
            [chain.sortedDays enumerateObjectsUsingBlock:^(HabitDay *day, NSUInteger index, BOOL *stop) {
                day.runningTotalCache = @(index);
            }];
        }
        NSError * error;
        [privateContext save:&error];
        if(error) NSLog(@"Error saving private context %@", error.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^{
            completionCallback();
        });
    });

}
#pragma mark - Data management
+(Habit *)createNew{
    NSManagedObjectContext * context = [CoreDataClient defaultClient].managedObjectContext;
    Habit * result = [NSEntityDescription insertNewObjectForEntityForName:@"Habit" inManagedObjectContext:context];
    result.title = @"New Habit";
    result.color = [Colors colorsFromMotion][[HabitsQueries nextUnusedColorIndex]];
    result.isActive = @YES;
    result.daysRequired = [[Calendar days] map:^id(id obj) {
        return @YES;
    }].mutableCopy;
    return result;
}
#pragma mark - Notifications

#define TOMORROW 1
#define TODAY 0
-(void)recalculateNotifications{
    self.notifications = @[].mutableCopy;
    if (!self.hasReminders) return;
    NSDate * now = [TimeHelper now];
    NSInteger dayOffset = ([self due:now] || [self done:now]) ? TOMORROW : TODAY;
    for(int n = 0; n < 7; n ++){
        YLMoment * moment =[ YLMoment momentWithDate: [TimeHelper addDays:dayOffset + n toDate:now]];
        if([self isRequiredOnWeekday:moment.date]){
            UILocalNotification * notification = [UILocalNotification new];
            NSDateComponents * components = self.reminderTime.copy;
            components.year = moment.year;
            components.month = moment.month;
            components.day = moment.day;
            notification.fireDate = [[NSCalendar currentCalendar] dateFromComponents:components];
            notification.alertBody = self.title;
            notification.repeatInterval = NSWeekCalendarUnit;
            [self.notifications addObject: notification];
        }
    }
}
@end
