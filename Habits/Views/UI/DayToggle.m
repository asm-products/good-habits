//
//  DayToggle.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "DayToggle.h"

@implementation DayToggle{
    UILabel * title;
    UIImageView * checkmark;
    
}

- (id)initWithFrame:(CGRect)frame day:(NSString *)day color:(UIColor *)color isOn:(BOOL)isOn
{
    self = [super initWithFrame:frame];
    if (self) {
        self.day = day;
        self.color = color;
        [self build];
        [self toggleOn: isOn];
    }
    return self;
}
-(void)build{
    [self addLabel];
    [self addCheckmark];
    [self toggleOn:YES];
}

-(void)addLabel{
    title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 18)];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    title.backgroundColor = [UIColor clearColor];
    [self addSubview:title];
    title.text = self.day;
}
-(void)addCheckmark{
    checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_mark"]];
    checkmark.frame = (CGRect){ CGPointMake(8, 19), checkmark.frame.size};
    [self addSubview:checkmark];
}
-(void)toggleOn:(BOOL)isOn{
    self.isOn = isOn;
    checkmark.hidden = !isOn;
}

@end
