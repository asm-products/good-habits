//
//  CalendarTopView.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "CalendarTopView.h"
#import "Colors.h"
#import "HeaderLabel.h"
#import "Calendar.h"
@implementation CalendarTopView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self build];
    }
    return self;
}
-(void)build{
    UIColor * color = [Colors calendarTop];
    self.backgroundColor = [UIColor clearColor];
    self.label = [[HeaderLabel alloc] initWithFrame: CGRectMake(0, 12, 320, 24)];
    [self addSubview:self.label];
    
    self.label.textColor = color;
    
    self.prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.prevButton.frame = CGRectMake(0, 0, 44, 45);
    [self.prevButton setImage:[UIImage imageNamed:@"arrow_back"] forState:UIControlStateNormal];
    [self addSubview:self.prevButton];
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextButton.frame = CGRectMake(320-44, 0, 44, 45);
    [self.nextButton setImage:[UIImage imageNamed:@"arrow_next"] forState:UIControlStateNormal];
    [self addSubview:self.nextButton];
    for(NSInteger i = 0; i < 7; i++){
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15 + i * 45, 40, 45, 11)];
        label.allowsDefaultTighteningForTruncation = YES;
        label.isAccessibilityElement = NO;
        NSInteger weekdayIndex = [Calendar weekdayIndexForColumn: i];
        label.text = [Calendar.days[weekdayIndex] uppercaseString];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:8];
        label.textColor = color;
        [self addSubview:label];
    }
    
}
@end
