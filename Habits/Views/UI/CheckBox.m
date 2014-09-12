//
//  CheckBox.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "CheckBox.h"

@implementation CheckBox{
    UIView * backing;
    UIImageView * checkmark;
    UIImageView * cross;
}

-(void)awakeFromNib{
    [self build];
}

-(void)build{
    self.backgroundColor = [UIColor clearColor];
    backing = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 24, 24)];
    [self addSubview:backing];
    
    checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_mark"]];
    checkmark.frame = (CGRect){ CGPointMake(12, 12), checkmark.frame.size };
    [self addSubview:checkmark];
    
    cross = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Cross"]];
    cross.contentMode = UIViewContentModeCenter;
    cross.frame = self.bounds;
    [self addSubview:cross];
    
    [self setState:DayCheckedStateNull];
}
-(void)setColor:(UIColor *)color{
    _color = color;
    backing.backgroundColor = color;
}
-(void)setState:(DayCheckedState)state{
    _state = state;
    checkmark.hidden = state != DayCheckedStateComplete;
    cross.hidden = state != DayCheckedStateBroken;
}
-(NSString *)accessibilityLabel{
    return [NSString stringWithFormat:@"Checkbox for %@ %@", self.label, [self labelForState: self.state] ];
}
-(NSString*)labelForState:(DayCheckedState)state{
    switch (state) {
        case DayCheckedStateNull: return @"Not checked";
        case DayCheckedStateComplete: return @"Checked";
        case DayCheckedStateBroken: return @"Broken";
        default: return @"";
    }
}
-(BOOL)isAccessibilityElement{
    return YES;
}
@end
