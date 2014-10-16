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
#import "Chain.h"
@implementation HabitSparklineTableViewCell{
    
    __weak IBOutlet DailySparklineView *sparklineView;
    __weak IBOutlet UILabel *periodLabel;
    __weak IBOutlet UILabel *currentChainLengthLabel;
    __weak IBOutlet UILabel *longestChainLabel;
    __weak IBOutlet UILabel *chainCountLabel;
    __weak IBOutlet UILabel *totalDaysCheckedLabel;
    __weak IBOutlet UILabel *averageChainLengthLabel;
}

- (void)awakeFromNib
{
}
-(void)setHabit:(Habit *)habit{
    _habit = habit;
//    if (habit.habitDays.count < 2) return;
   
    periodLabel.text = [SparklineHelper periodText:self.habit.earliestDate].uppercaseString;
    
    currentChainLengthLabel.text = [self labelInDays: self.habit.currentChainLength];
    
    NSSet * chains = habit.chains;
    longestChainLabel.text = [self labelInDays:[[chains.allObjects reduce:^id(NSNumber *memo, Chain* chain) {
        if (chain.length > memo.integerValue) {
            memo = @(chain.length);
        }
        return memo;
    } withInitialMemo:@0] integerValue]];
    
    chainCountLabel.text = @(chains.count).stringValue;
    
    CGFloat averageLength = chains.count == 0 ? 0 : [[chains.allObjects reduce:^id(NSNumber* memo, Chain* chain) {
        return @(chain.length + memo.integerValue);
    } withInitialMemo:@0] floatValue] / (CGFloat)chains.count;
    
    averageChainLengthLabel.text = [NSString stringWithFormat:@"%1.1f day%@", averageLength, averageLength == 1 ? @"" : @"s"];
    
    totalDaysCheckedLabel.text = [self labelInDays: [[[chains allObjects] reduce:^NSNumber*(NSNumber* memo, Chain* chain) {
        return @(memo.integerValue + chain.daysCountCache.integerValue);
    } withInitialMemo:@0] integerValue] ];
    
    currentChainLengthLabel.textColor = habit.color;
    chainCountLabel.textColor = habit.color;
    longestChainLabel.textColor = habit.color;
    averageChainLengthLabel.textColor = habit.color;
    totalDaysCheckedLabel.textColor = habit.color;
    
    sparklineView.color = habit.color;
    sparklineView.chains = [SparklineHelper dataForHabit:habit];
}
-(NSString*)labelInDays:(NSInteger)count{
    return [NSString stringWithFormat:@"%@ day%@",@(count), count == 1 ? @"" : @"s"];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
