//
//  HabitCell.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "HabitCell.h"
#import "CheckBox.h"
#import "Colors.h"
#import "HabitsList.h"
#import "CountView.h"
@implementation HabitCell{
    __weak IBOutlet CountView *countView;
}
-(void)build{
    [super build];
    //  y = 8 because the check box starts at 10. yes. not ideal.
    countView.text = @[@0, @0];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCheckboxTapped)];
    [self.checkbox addGestureRecognizer:tap];
}
-(void)onCheckboxTapped{
    self.checkbox.checked = !self.checkbox.checked;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.habit toggle: self.now];
        [self.habit save];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.habit = self.habit;
        });
    });

}

-(UIColor*)labelTextColor{
    return (([self.habit due:self.now] && ![self.habit done:(self.now)]) || (!self.inactive && self.habit.currentChainLength == 0)) ? [Colors red] : [UIColor blackColor];
}
-(void)setHabit:(Habit *)habit{
    _habit = habit;
    self.label.alpha = self.inactive ? 0.5 : 1.0;
    self.checkbox.checked = [habit done: self.now];
    self.checkbox.label = habit.title;
    self.label.text = habit.title;
    self.label.textColor = [self labelTextColor];
    
    NSInteger currentChainLength = habit.currentChainLength;
    NSInteger longestChain = habit.longestChain.intValue;
    countView.text = @[ @(currentChainLength), @(longestChain) ];
    countView.isHappy = currentChainLength > 0 && currentChainLength == longestChain;
    countView.highlighted = false;
}

@end
