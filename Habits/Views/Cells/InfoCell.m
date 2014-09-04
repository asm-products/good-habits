//
//  InfoCell.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "InfoCell.h"
#import "Colors.h"
#import "Chain.h"
@implementation InfoCell{
    
    __weak IBOutlet UILabel *newLabel;
}

-(void)awakeFromNib{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCheckbox:)];
    [self.checkbox addGestureRecognizer:tap];
}
-(void)didTapCheckbox:(UITapGestureRecognizer*)tap{
    [self.task toggle:!self.task.done];
    [self markRead];
    [self.checkbox setState:self.task.done ? DayCheckedStateComplete : DayCheckedStateNull];
    if(self.task.isUnopened){
        [self.task open:self.controller];
    }
}
-(void)setTask:(InfoTask *)task{
    _task = task;
    if(task.opened) [self markRead];
    self.label.text = task.text;
    [self.checkbox setState:task.done ? DayCheckedStateComplete : DayCheckedStateNull];
}
-(void)markRead{
    newLabel.hidden = YES;
}
-(UIColor *)labelTextColor{
    return [Colors dark];
}
@end
