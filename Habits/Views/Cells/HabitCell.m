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
#import "HabitsQueries.h"
#import "CountView.h"
#import "Habit.h"
#import "AppFeatures.h"
#import "StatisticsFeaturePurchaseController.h"
#import <YLMoment.h>
#import "TimeHelper.h"
#import <GTHRectHelpers.h>

@interface HabitCell()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *cancelSkippedDayButton;

@end

@implementation HabitCell{
    __weak IBOutlet CountView *countView;
    __weak IBOutlet UITextField *reasonEntryField;
    Habit * habit; // cache to directly access habit in case checking the box makes the chain disappear!
}
-(void)build{
    [super build];
    
    [self buildReasonEntryField];
    
    //  y = 8 because the check box starts at 10. yes. not ideal.
    countView.text = @[@0, @0];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCheckboxTapped)];
    [self.checkbox addGestureRecognizer:tap];
}
-(void)buildReasonEntryField{
    reasonEntryField.rightViewMode = UITextFieldViewModeAlways;
    reasonEntryField.delegate = self;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if([AppFeatures statsEnabled] == NO){
        StatisticsFeaturePurchaseController * controller = [StatisticsFeaturePurchaseController sharedController];
        [controller showPromptInViewController:self.delegate];
        
        return NO;
    }else{
        return YES;
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    self.chain.notes = textField.text;
    [self.chain save];
    
    [textField resignFirstResponder];
    return YES;
}
-(void)onCheckboxTapped{
    DayCheckedState state = [self.chain stepToNextStateForDate: self.day];
    self.chain = [habit chainForDate:self.day];
    [self setState:state];
    if (state != DayCheckedStateBroken) [reasonEntryField resignFirstResponder];
    if(state == DayCheckedStateComplete) [[NSNotificationCenter defaultCenter] postNotificationName:TODAY_CHECKED_FOR_CHAIN object:self.chain];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHAIN_MODIFIED object:self.chain userInfo:nil];
}

-(UIColor*)labelTextColor{
    return [UIColor blackColor];
    // TODO: make the due habits red again
//    return (([self.habit due:self.now] && ![self.habit done:(self.now)]) || (!self.inactive && self.habit.currentChainLength == 0)) ? [Colors red] : [UIColor blackColor];
}
-(void)setChain:(Chain *)chain{
    _chain = chain;
    habit = chain.habit;
    reasonEntryField.text = chain.notes;
    // The following is intended to be monitored by HabitsListViewController to update the height of the cell
    // that was changed, thus hiding or revealing the reason text field
    if(chain == nil) @throw [NSException exceptionWithName:@"NoChainProvided" reason:nil userInfo:nil];
    if([AppFeatures statsEnabled] == NO){
        reasonEntryField.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"locked"]];
    }else{
        reasonEntryField.rightView = nil;
    }
}
-(NSString*)timeAgoString:(NSInteger)daysOverdue{
    switch (daysOverdue) {
        case 0: return @"today";
        case 1: return @"yesterday";
        default: return [NSString stringWithFormat:@"%@ days ago", @(daysOverdue)];
    }
}
- (IBAction)didPressCancelSkippedDayButton:(id)sender {
    [self.chain checkNextRequiredDate];
    [self update];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHAIN_MODIFIED object:nil];
    self.chain = self.chain;
}

-(void)setState:(DayCheckedState)state{
    _state = state;
    self.label.alpha = self.inactive ? 0.5 : 1.0;
    self.checkbox.state = state;
    self.checkbox.label = self.chain.habit.title;
    self.label.text =// [NSString stringWithFormat:@"%@ %@",habit.identifier,habit.title];//
        self.chain.habit.title;
    self.label.textColor = [self labelTextColor];
    
    NSInteger countOfDaysOverdue = self.chain.countOfDaysOverdue;
    NSLog(@"Count of days overdue for %@ = %@ (next due date %@)", self.chain.habit.title, @(countOfDaysOverdue), self.chain.nextRequiredDate);
    NSInteger currentChainLength = countOfDaysOverdue > 0 ? -(countOfDaysOverdue - 1) : self.chain.length;
    NSInteger longestChain = self.chain.habit.longestChain.length;
    countView.color = self.chain.habit.color;
    countView.text = @[ @(currentChainLength), @(longestChain) ];
    countView.isHappy = currentChainLength > 0 && currentChainLength == longestChain;
    countView.highlighted = false;
    
    
//    self.cancelSkippedDayButton.titleLabel.textColor = self.chain.habit.color;
    if([self.chain.nextRequiredDate isEqualToDate:[TimeHelper today]]){
        self.cancelSkippedDayButton.hidden = YES;
        
    }else{
        self.cancelSkippedDayButton.hidden = NO;
    }
    if(self.chain.isBroken){
        NSInteger daysOverdue = self.chain.countOfDaysOverdue;
        NSString * timeMissedString = [self timeAgoString:daysOverdue];
        reasonEntryField.placeholder = [NSString stringWithFormat:@"Missed %@. What happened?", timeMissedString];
        self.cancelSkippedDayButton.accessibilityLabel = [NSString stringWithFormat:@"Check %@", [self timeAgoString:daysOverdue]];
    }

}
-(void)update{
    [self setState:self.state];
}
@end
