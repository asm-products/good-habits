//
//  SparklineHelper.h
//  Habits
//
//  Created by Michael Forrest on 11/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Habit.h"
@interface SparklineHelper : NSObject
+(NSArray*)dataForHabit:(Habit*)habit;
@end
