//
//  ChainQueries.h
//  Habits
//
//  Created by Michael Forrest on 22/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Habit;
@interface ChainQueries : NSObject
+(NSArray *)chainsInMonthStarting:(NSDate *)date;
+(NSArray *)chainLengthsDistributionForHabit:(Habit*)habit;
@end
