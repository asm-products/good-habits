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
#import "SparklineHelper.h"
@implementation HabitSparklineTableViewCell{
    
    __weak IBOutlet DailySparklineView *sparklineView;
}

- (void)awakeFromNib
{
}
-(void)setHabit:(Habit *)habit{
    _habit = habit;
    if (habit.daysChecked.count < 2) return;
    

    sparklineView.color = habit.color;
    sparklineView.dataPoints = [SparklineHelper dataForHabit:habit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
