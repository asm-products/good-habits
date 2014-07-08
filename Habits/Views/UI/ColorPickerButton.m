//
//  ColorPickerButton.m
//  Habits
//
//  Created by Michael Forrest on 08/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "ColorPickerButton.h"

@implementation ColorPickerButton{
    CALayer * circle;
}
-(id)initWithFrame:(CGRect)frame color:(UIColor*)color{
    if(self = [super initWithFrame:frame]){
        self.color = color;
        [self build];
    }
    return self;
}
-(void)build{
    circle = [CALayer layer];
    circle.frame = CGRectInset(self.bounds, 14, 14);
    circle.backgroundColor = self.color.CGColor;
    circle.cornerRadius = circle.frame.size.width / 2;
    circle.borderWidth = 1;
    [self.layer addSublayer:circle];
}
-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    circle.borderColor = isSelected ? [UIColor blackColor].CGColor : [UIColor clearColor].CGColor;
}
@end
