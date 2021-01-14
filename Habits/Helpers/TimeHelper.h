//
//  TimeHelper.h
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLMoment.h"

@interface NSDate(rounding)
-(NSDate*)beginningOfDay;
-(BOOL)isBefore:(NSDate*)date;
@end

@interface Moment : YLMoment
//-(void) momentInitiated;
@end

@interface TimeHelper : NSObject
+(NSCalendar*)UTCCalendar;
+(NSDate*)startOfDayInUTC:(NSDate*)date;
/**
 *  Start of today in UTC
 */
+(nonnull NSDate*)today;
/**
 *  Now in local time
 */
+(NSDate*)now;
+(void)selectDate:(NSDate*)date;
+(NSInteger)weekdayIndex:(NSDate*)date;
+(NSDateComponents*)dateComponentsForHour:(NSInteger)hour minute:(NSInteger)minute;
+(NSDate*)addDays:(NSInteger)count toDate:(NSDate*)date;
+(NSString*)formattedTime:(NSDateComponents*)components;
+(NSString*)timeAgoString:(NSDate*)date;
+(NSDate*)dateForTimeToday:(NSDateComponents*)components;
//+(NSDateFormatter*)iso8601Formatter;
+(NSDateFormatter*)jsonDateFormatter;
+(NSDateFormatter*)accessibilityDateFormatter;

+(NSDateFormatter*)fullDateFormatter;
/* It's a string because it might be a float value (average day count)*/
+(NSString*)formattedDayCount:(NSNumber*)numberOfDays;
+(NSString*)formattedDaysAgoCount:(NSInteger)numberOfDays;
@end
