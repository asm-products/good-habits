//
//  ColorPickerCell.m
//  Habits
//
//  Created by Michael Forrest on 07/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "ColorPickerCell.h"
#import "Colors.h"
#import <ALActionBlocks.h>
#import "ColorPickerButton.h"
#import "CoreDataClient.h"
@implementation ColorPickerCell{
    NSMutableArray * buttons;
}
-(void)awakeFromNib{
    NSArray * colors = [Colors colorsFromMotion];
    buttons = [[NSMutableArray alloc] initWithCapacity:colors.count];
    CGFloat x = 0;
    CGFloat itemWidth = self.frame.size.width / colors.count;
    for (UIColor * color in colors) {
        [buttons addObject:[self createButtonAtX: x color: color width: itemWidth]];
        x += itemWidth;
    }
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    if (buttons) {
        [self layoutButtons];
    }
}
-(void)layoutButtons{
    CGFloat x = 0;
    CGFloat itemWidth = self.frame.size.width / buttons.count;
    for (UIButton * button in buttons) {
        button.frame = CGRectMake(x, 0, itemWidth, self.frame.size.height);
        x += itemWidth;
    }
}
-(void)setHabit:(Habit *)habit{
    _habit = habit;
    [self refreshButtonSelectionState];
}
-(void)refreshButtonSelectionState{
    for(ColorPickerButton * button in buttons){
        button.isSelected = [button.color isEqual:self.habit.color];
    }
}
-(UIButton*)createButtonAtX:(CGFloat)x color:(UIColor*)color width:(CGFloat)width{
    UIButton * button = [[ColorPickerButton alloc] initWithFrame:CGRectMake(x, 0, width, self.frame.size.height) color: color];
    [self configureButton: button color: color];
    [self.contentView addSubview:button];
    return button;
}
-(void)configureButton:(UIButton*)button color:(UIColor*)color{
    [button handleControlEvents:UIControlEventTouchUpInside withBlock:^(id weakSender) {
        self.habit.color = color;
        [[CoreDataClient defaultClient] save];
        [self refreshButtonSelectionState];
        [[NSNotificationCenter defaultCenter] postNotificationName:HABIT_COLOR_CHANGED object:nil];
    }];
}
@end
