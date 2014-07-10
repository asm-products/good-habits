//
//  Audits.h
//  Habits
//
//  Created by Michael Forrest on 08/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Habit.h"

@interface Audits : NSObject
+(void)initialize;
+(NSDateComponents*)scheduledTime;
+(void)saveScheduledTime:(NSDateComponents*)scheduledTime;
+(NSArray*)habitsToBeAudited;
+(ChainAnalysis*)recalculateAnalysisForHabit:(Habit*)habit;
@end
