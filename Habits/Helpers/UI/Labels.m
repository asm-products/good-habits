//
//  Labels.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "Labels.h"

@implementation Labels
+(UILabel *)subheadingLabelWithFrame:(CGRect)frame{
    UILabel * result = [[UILabel alloc] initWithFrame:frame];
    result.backgroundColor = [UIColor clearColor];
    result.textColor = [UIColor whiteColor];
    result.textAlignment = NSTextAlignmentLeft;
    result.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    return result;
}
@end
