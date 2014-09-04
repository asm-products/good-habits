//
//  HabitDayQueries.h
//  Habits
//
//  Created by Michael Forrest on 22/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Habit.h"
@interface HabitDayQueries : NSObject

#pragma mark - Queries
+(NSArray *)daysForHabit:(Habit *)habit betweenDate:(NSDate *)startDate andDate:(NSDate*)date;
@end
