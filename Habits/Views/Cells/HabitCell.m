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
#import "AwardImage.h"
#import <UIAlertView+Blocks.h>
#import "PastDayCheckView.h"
#import <SVProgressHUD.h>

@interface HabitCell()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *cancelSkippedDayButton;
@property (weak, nonatomic) IBOutlet UIButton *habitStatusButton;

@end

@implementation HabitCell{
    __weak IBOutlet CountView *countView;
    __weak IBOutlet UITextField *reasonEntryField;
    Habit * habit; // cache to directly access habit in case checking the box makes the chain disappear!
}
-(void)build{
    [super build];
    self.habitStatusButton.backgroundColor = [UIColor clearColor];
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
    __weak HabitCell* welf = self;
    [self setSwipeGestureWithView:[self viewWithImageNamed:self.chain.habit.isActive.boolValue ? @"pause" : @"play"] color:self.chain.habit.color mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        welf.chain.habit.isActive = @(!welf.chain.habit.isActive.boolValue);
        [[CoreDataClient defaultClient].managedObjectContext save:nil];
        [HabitsQueries refresh];
        [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:nil];
    }];

    [self setSwipeGestureWithView:[self viewWithImageNamed:@"Cross"] color:[Colors red] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState2  completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        // delete this habit?
        [[[UIAlertView alloc] initWithTitle:@"Delete this habit?" message:[NSString stringWithFormat:@"Are you sure you want to delete \"%@\"", welf.chain.habit.title] cancelButtonItem:[RIButtonItem itemWithLabel:@"Keep this habit"] otherButtonItems:[RIButtonItem itemWithLabel:@"Delete" action:^{
            [[CoreDataClient defaultClient].managedObjectContext deleteObject:welf.chain.habit];
            [[CoreDataClient defaultClient].managedObjectContext save:nil];
            [HabitsQueries refresh];
            [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:nil];
        }], nil] show];
    }];
}
-(UIView*)viewWithImageNamed:(NSString*)name{
    UIImage * image = [UIImage imageNamed:name];
    return [[UIImageView alloc] initWithImage:image];
}
-(NSString*)timeAgoString:(NSInteger)daysOverdue{
    switch (daysOverdue) {
        case 0: return @"today";
        case 1: return @"yesterday";
        default: return [NSString stringWithFormat:@"%@ days ago", @(daysOverdue)];
    }
}
- (IBAction)didPressCancelSkippedDayButton:(id)sender {
    [self checkNextRequiredDate];
}
-(void)checkNextRequiredDate{
    [self.chain checkNextRequiredDate];
    [[CoreDataClient defaultClient].managedObjectContext save:nil];
    [self update];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHAIN_MODIFIED object:nil];
    self.chain = self.chain;
    
}
- (IBAction)didPressHabitStatusButton:(id)sender {
    if(self.chain.isBroken &!self.chain.explicitlyBroken.boolValue){
        [[[UIAlertView alloc] initWithTitle:self.chain.habit.title message:[NSString stringWithFormat:@"Check %@? (You can also swipe left to check this date off)",[[TimeHelper fullDateFormatter]  stringFromDate:self.chain.nextRequiredDate]] cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] otherButtonItems:[RIButtonItem itemWithLabel:[NSString stringWithFormat:@"✓ %@",[self timeAgoString:self.chain.countOfDaysOverdue]] action:^{
            [self checkNextRequiredDate];
        }], nil] show];
    }else{
        NSInteger currentLength = self.chain.currentChainLengthForDisplay;
        NSInteger longest = self.chain.habit.longestChain.length;
        NSString * status = [NSString stringWithFormat:@"Current length: %@ day%@\nLongest chain: %@ day%@", @(currentLength), currentLength == 1 ? @"" : @"s", @(longest), longest == 1 ? @"" : @"s"];
        [SVProgressHUD showImage:self.chain.isRecord ? [AwardImage starColored:self.chain.habit.color] : [AwardImage circleColored:self.chain.habit.color] status:status];
    }

}

-(void)setState:(DayCheckedState)state{
    _state = state;
    self.label.alpha = self.inactive ? 0.5 : 1.0;
    self.checkbox.state = state;
    self.checkbox.label = self.chain.habit.title;
    self.label.text =// [NSString stringWithFormat:@"%@ %@",habit.identifier,habit.title];//
        self.chain.habit.title;
    self.label.textColor = [self labelTextColor];
    
    
    __weak id welf = self;
    if(self.chain.habit.isActive.boolValue){
        
        [self.habitStatusButton setTitle:@(self.chain.currentChainLengthForDisplay).stringValue forState:UIControlStateNormal];
        if(self.chain.isBroken){
            NSInteger daysOverdue = self.chain.countOfDaysOverdue;
            NSString * timeMissedString = [self timeAgoString:daysOverdue];
            reasonEntryField.placeholder = [NSString stringWithFormat:@"Missed %@. What happened?", timeMissedString];
            self.cancelSkippedDayButton.accessibilityLabel = [NSString stringWithFormat:@"Check %@", [self timeAgoString:daysOverdue]];

            [self.habitStatusButton setBackgroundImage:[AwardImage circleColored:[Colors cobalt]] forState:UIControlStateNormal];

            [self setSwipeGestureWithView:[PastDayCheckView viewWithText:[self timeAgoString:self.chain.countOfDaysOverdue] frame:CGRectMake(0, 0, 100, self.frame.size.height)] color:self.chain.habit.color mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                [welf checkNextRequiredDate];
            }];
        }else{
            UIImage * backgroundImage = self.chain.isRecord ? [AwardImage starColored:self.chain.habit.color] : [AwardImage circleColored:self.chain.habit.color];
            [self.habitStatusButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
            self.modeForState3 = MCSwipeTableViewCellModeNone;
        }
    }else{ // paused
        self.modeForState3 = MCSwipeTableViewCellModeNone;
        [self.habitStatusButton setBackgroundImage:[AwardImage circleColored:[Colors cobalt]] forState:UIControlStateNormal];
        [self.habitStatusButton setTitle:@(self.chain.habit.currentChainLength).stringValue forState:UIControlStateNormal];
    }
}
-(void)update{
    [self setState:self.state];
}
@end
