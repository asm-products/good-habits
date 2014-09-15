//
//  TestHelpers.h
//  Habits
//
//  Created by Michael Forrest on 09/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Habit.h"
#import "DayKeys.h"
@interface TestHelpers : NSObject
+(Habit*)habit:(NSDictionary*)dictionary daysChecked:(NSArray*)dayKeys;
+(NSMutableArray*)everyDay;
+(NSArray*)days:(NSArray*)dayStrings;
+(void)deleteAllData;
+(void)loadFixtureFromUserDefaultsNamed:(NSString*)name;
+(void)setStatsEnabled:(BOOL)enabled;
@end

static inline NSDate * d(NSString* string){
    return [DayKeys dateFromKey:string];
}

