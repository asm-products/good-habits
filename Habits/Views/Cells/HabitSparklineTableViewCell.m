//
//  HabitSparklineTableViewCell.m
//  Habits
//
//  Created by Michael Forrest on 10/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "HabitSparklineTableViewCell.h"
#import "DailySparklineView.h"
#import "TimeHelper.h"
@implementation HabitSparklineTableViewCell{
    
    __weak IBOutlet DailySparklineView *sparklineView;
}

- (void)awakeFromNib
{
}
-(void)setHabit:(Habit *)habit{
    _habit = habit;
    if (habit.daysChecked.count < 2) return;
    
    NSMutableArray * dataPoints = [NSMutableArray new];
    NSDate * now = [TimeHelper now];
    NSDate * date = habit.earliestDate;
    while ([date isBefore: now]) {
        NSNumber * value = [habit includesDate:date] ? [habit chainLengthOnDate:date] : @0;
        [dataPoints addObject:value];
        date = [TimeHelper addDays:1 toDate:date];
    }
    sparklineView.color = habit.color;
    sparklineView.dataPoints = dataPoints;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
