//
//  ReasonCellTableViewCell.m
//  Habits
//
//  Created by Michael Forrest on 12/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "ReasonCellTableViewCell.h"
#import "TimeHelper.h"
#import "Habit.h"
@implementation ReasonCellTableViewCell{
    
    __weak IBOutlet UILabel *dateLabel;
    __weak IBOutlet UILabel *reasonLabel;

}
-(void)setChain:(Chain *)chain{
    _chain = chain;
    dateLabel.text = [[[TimeHelper fullDateFormatter] stringFromDate:chain.lastDateCache] stringByAppendingFormat:@" - chain length %@ day%@", chain.daysCountCache, chain.daysCountCache.integerValue == 1 ? @"" : @"s" ];
    reasonLabel.text = chain.notes;

}

+(CGFloat)heightWithReasonText:(NSString *)text{
    CGSize result = [text boundingRectWithSize:CGSizeMake(280, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{
                                                                                                                       NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16]
                                                                                                                       } context:nil].size;
    return result.height + 50;
}
@end
