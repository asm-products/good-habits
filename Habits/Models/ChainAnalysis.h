//
//  ChainAnalysis.h
//  Habits
//
//  Created by Michael Forrest on 09/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Habit.h"
@interface ChainAnalysis : NSObject
-(instancetype)initWithHabit:(Habit*)habit startDate:(NSDate*)startDate endDate:(NSDate*)endDate calculateImmediately:(BOOL)shouldCalculateImmediately;
@property (nonatomic, strong) Habit * habit;
@property (nonatomic, strong) NSDate * startDate;
@property (nonatomic, strong) NSDate * endDate;
-(void)calculate;
@property (nonatomic, strong) NSArray * freshChainBreaks;
@property (nonatomic, strong) NSArray * chainBreaks;

@end
