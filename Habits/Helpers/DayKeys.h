//
//  DayKeys.h
//  Habits
//
//  Created by Michael Forrest on 16/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DayKeys : NSObject
+(NSDate*)dateFromKey:(NSString*)key;
+(NSString*)keyFromDate:(NSDate*)date;
@end
