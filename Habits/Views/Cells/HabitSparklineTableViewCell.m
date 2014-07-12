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
#import <NSArray+F.h>
#import <NSDictionary+F.h>
@implementation HabitSparklineTableViewCell{
    
    __weak IBOutlet DailySparklineView *sparklineView;
    __weak IBOutlet UILabel *periodLabel;
    __weak IBOutlet UILabel *longestChainLabel;
    __weak IBOutlet UILabel *chainCountLabel;
    __weak IBOutlet UILabel *averageChainLengthLabel;
}

- (void)awakeFromNib
{
}
-(void)setHabit:(Habit *)habit{
    _habit = habit;
    if (habit.daysChecked.count < 2) return;
   
    periodLabel.text = [SparklineHelper periodText:self.habit.earliestDate].uppercaseString;
    NSArray * chains = habit.chains;
    longestChainLabel.text = [[chains reduce:^id(NSNumber *memo, NSDictionary* obj) {
        if (obj.allKeys.count > memo.integerValue) {
            memo = @(obj.allKeys.count);
        }
        return memo;
    } withInitialMemo:@0] stringValue];
    
    chainCountLabel.text = @(chains.count).stringValue;
    
    CGFloat averageLength = [[chains reduce:^id(NSNumber* memo, NSDictionary* obj) {
        return @(obj.allKeys.count + memo.integerValue);
    } withInitialMemo:@0] floatValue] / (CGFloat)chains.count;
    
    averageChainLengthLabel.text = [NSString stringWithFormat:@"%1.1f", averageLength];
    
    chainCountLabel.textColor = habit.color;
    longestChainLabel.textColor = habit.color;
    averageChainLengthLabel.textColor = habit.color;
    
    sparklineView.color = habit.color;
    sparklineView.dataPoints = [SparklineHelper dataForHabit:habit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
