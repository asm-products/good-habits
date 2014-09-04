//
//  ChainStatsCell.m
//  Habits
//
//  Created by Michael Forrest on 23/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "ChainStatsCell.h"
#import "TimeHelper.h"

@implementation ChainStatsCell{
    __weak IBOutlet UILabel *dateLabel;
    __weak IBOutlet UILabel *lengthLabel;
    __weak IBOutlet UILabel *dateRangeLabel;
}
-(void)setChain:(Chain *)chain{
    _chain = chain;
    dateLabel.text = [TimeHelper timeAgoString:chain.startDate];//[NSString stringWithFormat:@"%@ - %@",, nil]; // chainBreak.date];
//    cell.detailTextLabel.text = chain.notes;
    lengthLabel.text = [NSString stringWithFormat:@"Length: %@", @(chain.length)];
    dateRangeLabel.text = [NSString stringWithFormat:@"%@ - %@", [[TimeHelper accessibilityDateFormatter] stringFromDate:chain.firstDateCache], [[TimeHelper accessibilityDateFormatter] stringFromDate:chain.lastDateCache]];
}
@end
