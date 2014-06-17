//
//  TimeHelper.h
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeHelper : NSObject
+(NSDate*)now;
+(void)selectDate:(NSDate*)date;
+(NSInteger)weekday:(NSDate*)date;
+(NSDateComponents*)dateComponentsForHour:(NSInteger)hour minute:(NSInteger)minute;
+(NSDate*)addDays:(NSInteger)count toDate:(NSDate*)date;
+(NSString*)formattedTime:(NSDateComponents*)components;
@end
