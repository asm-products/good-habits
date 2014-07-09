//
//  TestHelpers.h
//  Habits
//
//  Created by Michael Forrest on 09/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Habit.h"
@interface TestHelpers : NSObject
+(Habit*)habit:(NSDictionary*)dictionary;
+(NSMutableArray*)everyDay;
+(NSArray*)days:(NSArray*)dayStrings;
@end

static inline NSDate * d(NSString* string){
    return [Habit dateFromString:string];
}

