//
//  PastDayCheckView.m
//  Habits
//
//  Created by Michael Forrest on 21/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "PastDayCheckView.h"

@implementation PastDayCheckView{
}

+(instancetype)viewWithText:(NSString *)text frame:(CGRect)frame{
    frame = CGRectInset(frame, 0, 0);
    PastDayCheckView * result = [[self alloc] initWithFrame:frame];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height * 0.5, frame.size.width,frame.size.height * 0.5)];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    label.textColor = [UIColor whiteColor];
    label.text = text;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    [result addSubview:label];
    
    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_mark"]];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.frame = CGRectMake(0, 3, frame.size.width, frame.size.height * 0.5);
    [result addSubview:imageView];
    return result;
}
@end
