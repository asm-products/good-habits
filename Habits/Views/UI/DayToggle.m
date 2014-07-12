//
//  DayToggle.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "DayToggle.h"
#import "CheckMarkView.h"
@implementation DayToggle{
    UILabel * title;
    CheckMarkView * checkmark;
    
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
    title.textColor = self.color;
    title.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:8];
    title.backgroundColor = [UIColor clearColor];
    [self addSubview:title];
    title.text = self.day;
}
-(void)addCheckmark{
    checkmark = [[CheckMarkView alloc] initWithFrame:CGRectMake(8, 19, 24, 24)];
    checkmark.color = self.color;
    checkmark.userInteractionEnabled = NO;
    [self addSubview:checkmark];
}
-(void)toggleOn:(BOOL)isOn{
    self.isOn = isOn;
    checkmark.hidden = !isOn;
}
-(void)setColor:(UIColor *)color{
    _color = color;
    checkmark.color = self.color;
    [checkmark setNeedsDisplay];
    title.textColor = self.color;
}
@end
