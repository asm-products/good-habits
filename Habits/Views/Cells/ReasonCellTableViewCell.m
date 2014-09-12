//
//  ReasonCellTableViewCell.m
//  Habits
//
//  Created by Michael Forrest on 12/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "ReasonCellTableViewCell.h"
#import "TimeHelper.h"
@implementation ReasonCellTableViewCell{
    
    __weak IBOutlet UILabel *dateLabel;
    __weak IBOutlet UILabel *reasonLabel;
    __weak IBOutlet UILabel *chainLengthLabel;
}
-(void)setChain:(Chain *)chain{
    dateLabel.text = [NSString stringWithFormat:@"%@ - %@", [[TimeHelper accessibilityDateFormatter] stringFromDate:chain.firstDateCache], [[TimeHelper accessibilityDateFormatter] stringFromDate:chain.lastDateCache]];
    reasonLabel.text = chain.notes;
    chainLengthLabel.text = @(chain.length).stringValue;
}

+(CGFloat)heightWithReasonText:(NSString *)text{
    CGSize result = [text boundingRectWithSize:CGSizeMake(290, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{
                                                                                                                       NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16]
                                                                                                                       } context:nil].size;
    return result.height + 40;
}
@end
