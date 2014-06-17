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
}
-(void)setColor:(UIColor *)color{
    _color = color;
    backing.backgroundColor = color;
}
-(void)setChecked:(BOOL)checked{
    _checked = checked;
    checkmark.hidden = !checked;
}
-(NSString *)accessibilityLabel{
    return [NSString stringWithFormat:@"Checkbox for %@ %@", self.label, self.checked ? @"Checked" : @"Not checked" ];
}
-(BOOL)isAccessibilityElement{
    return YES;
}
@end
