//
//  ChainLengthDistributionTableViewCell.m
//  Habits
//
//  Created by Michael Forrest on 14/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "ChainLengthDistributionTableViewCell.h"
#import "ChainQueries.h"
#import <NSArray+F.h>
#import "TimeHelper.h"
#define GROUP_SPACING 10
#define ROW_SPACING 3
#define ROW_HEIGHT 15
#define LABELS_WIDTH 60
#define MAX_BAR_WIDTH 160
#define LABEL_MARGINS 10
#define PADDING 20
#define LABEL_TEXT_SIZE 11
@implementation ChainLengthDistributionTableViewCell{
    NSMutableArray * rowViews;
}
-(void)refresh{
    for (UIView * view in rowViews) {
        [view removeFromSuperview];
    }
    NSArray * values = [ChainQueries chainLengthsDistributionForHabit:self.habit];
    
    if(values.count == 0) return;
    
    NSArray * valuesSortedByCount = [values sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO]]];
    
    NSInteger maxCount = [[valuesSortedByCount.firstObject valueForKey:@"count"] integerValue];
    rowViews = [[NSMutableArray alloc] initWithCapacity:values.count];

    
    NSInteger previousDaysCount = 0;
    CGFloat y = PADDING;
    for (NSDictionary * value in values) {
        NSInteger count = [value[@"count"] integerValue];
        NSInteger daysCount = [value[@"daysCountCache"] integerValue];
        if(previousDaysCount - daysCount > 1){
            y += GROUP_SPACING;
        }
        UIView * view = [self addRowAtY:y daysCount:daysCount count:count maxCount:maxCount];
        [self addSubview:view];
        y = CGRectGetMaxY(view.frame) + ROW_SPACING;
        [rowViews addObject:view];
        previousDaysCount = daysCount;
    }
    self.height = y + PADDING;
}
-(UIView*)addRowAtY:(CGFloat)y daysCount:(NSInteger)daysCount count:(NSInteger)count maxCount:(NSInteger)maxCount{
    UIView * result = [[UIView alloc] initWithFrame:CGRectMake(PADDING, y, self.frame.size.width - 2 * PADDING, ROW_HEIGHT)];
    UILabel * daysCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -1, LABELS_WIDTH, ROW_HEIGHT)];
    daysCountLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:LABEL_TEXT_SIZE];
    daysCountLabel.textColor = [UIColor lightGrayColor];
    daysCountLabel.text = [TimeHelper formattedDayCount:@(daysCount)];
    daysCountLabel.textAlignment = NSTextAlignmentRight;
    [result addSubview:daysCountLabel];
    
    CGFloat barWidth = (count / (CGFloat)maxCount) * MAX_BAR_WIDTH;
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(LABELS_WIDTH + LABEL_MARGINS, 0, barWidth, ROW_HEIGHT)];
    line.backgroundColor = self.habit.color;
    [result addSubview:line];
    
    UILabel * countLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(line.frame) + LABEL_MARGINS , -1, LABELS_WIDTH, ROW_HEIGHT)];
    countLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:LABEL_TEXT_SIZE];
    countLabel.textColor = self.habit.color;
    countLabel.text = @(count).stringValue;
    countLabel.textAlignment = NSTextAlignmentLeft;
    [result addSubview:countLabel];
    
    return result;
}

@end
