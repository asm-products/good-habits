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
}
-(void)build{
    [super build];
    self.habitStatusButton.backgroundColor = [UIColor clearColor];
    [self buildReasonEntryField];
    //  y = 8 because the check box starts at 10. yes. not ideal.
    countView.text = @[@0, @0];
    self.defaultColor = [Colors cobalt];
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
        if(!self.failure.active.boolValue){
            self.failure = [self.habit createFailureForDate:self.habit.currentChain.nextRequiredDate];
//            [self setState:DayCheckedStateBroken];
        }
        return YES;
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    self.failure.notes = textField.text;
    [[CoreDataClient defaultClient] save];
    [textField resignFirstResponder];
    return YES;
}
-(void)onCheckboxTapped{
    
    Failure * failure = [self.habit existingFailureForDate:self.day];
    Chain * chain = self.habit.currentChain; // should never be nil; lazily created if habit has no chains
    HabitDay * habitDay = [chain habitDayForDate:self.day];
    DayCheckedState state;
    if(failure && failure.active.boolValue){ // we had a failure so uncheck it
        failure.active = @NO;
        state = DayCheckedStateNull;
    }else if(habitDay){ // we had a day so turn it into a failure
        [chain removeDaysObject:habitDay];
        chain.lastDateCache = [chain.sortedDays.lastObject valueForKey:@"date"];
        if(chain.days.count == 0) [self.habit removeChainsObject:chain];
        if(!failure){
            failure = [self.habit createFailureForDate:self.day];
        }else{
            failure.active = @YES;
        }
        state = DayCheckedStateBroken;
    }else if(habitDay == nil){ // we need to add a check for today
        BOOL dateIsTooLateForExistingChain = chain.days.count > 0 && (self.day.timeIntervalSinceReferenceDate > chain.nextRequiredDate.timeIntervalSinceReferenceDate);
        if(dateIsTooLateForExistingChain){
            chain = [self.habit addNewChainForToday];
        }
        state = [chain tickLastDayInChainOnDate:self.day];
    }
    [[CoreDataClient defaultClient] save];
    self.failure = failure;
    [self setState:state];
    if (state != DayCheckedStateBroken) [reasonEntryField resignFirstResponder];
    if(state == DayCheckedStateComplete) [[NSNotificationCenter defaultCenter] postNotificationName:TODAY_CHECKED_FOR_CHAIN object:chain];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHAIN_MODIFIED object:chain userInfo:nil];
}

-(UIColor*)labelTextColor{
    return [UIColor blackColor];
    // TODO: make the due habits red again
//    return (([self.habit due:self.now] && ![self.habit done:(self.now)]) || (!self.inactive && self.habit.currentChainLength == 0)) ? [Colors red] : [UIColor blackColor];
}
-(void)setHabit:(Habit *)habit{
    _habit = habit;
    reasonEntryField.text = @"";
    // The following is intended to be monitored by HabitsListViewController to update the height of the cell
    // that was changed, thus hiding or revealing the reason text field
    if([AppFeatures statsEnabled] == NO){
        reasonEntryField.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"locked"]];
    }else{
        reasonEntryField.rightView = nil;
    }
    __weak HabitCell* welf = self;
    [self setSwipeGestureWithView:[self viewWithImageNamed:self.habit.isActive.boolValue ? @"pause" : @"play"] color:self.habit.color mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        welf.habit.isActive = @(!welf.habit.isActive.boolValue);
        [[CoreDataClient defaultClient].managedObjectContext save:nil];
        [HabitsQueries refresh];
        [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:nil];
    }];

    [self setSwipeGestureWithView:[self viewWithImageNamed:@"Cross"] color:[Colors red] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState2  completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        // delete this habit?
        [[[UIAlertView alloc] initWithTitle:@"Delete this habit?" message:[NSString stringWithFormat:@"Are you sure you want to delete \"%@\"", welf.habit.title] cancelButtonItem:[RIButtonItem itemWithLabel:@"Keep this habit"] otherButtonItems:[RIButtonItem itemWithLabel:@"Delete" action:^{
            [[CoreDataClient defaultClient].managedObjectContext deleteObject:welf.habit];
            [[CoreDataClient defaultClient].managedObjectContext save:nil];
            [HabitsQueries refresh];
            [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:nil];
        }], nil] show];
    }];
}
-(void)setFailure:(Failure *)failure{
    _failure = failure;
    reasonEntryField.text = failure.notes;
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
    [self.habit.currentChain checkNextRequiredDate];
    [[CoreDataClient defaultClient] save];
    [self update];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHAIN_MODIFIED object:nil];
    self.habit = self.habit;
}
- (IBAction)didPressHabitStatusButton:(id)sender {
    Chain * chain = self.habit.currentChain;
    NSInteger daysOverdue = chain.countOfDaysOverdue;
    if(self.failure != nil || daysOverdue > 0){
        [[[UIAlertView alloc] initWithTitle:self.habit.title message:[NSString stringWithFormat:@"Check %@? (You can also swipe left to check this date off)",[[TimeHelper fullDateFormatter]  stringFromDate:chain.nextRequiredDate]] cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] otherButtonItems:[RIButtonItem itemWithLabel:[NSString stringWithFormat:@"✓ %@",[self timeAgoString:chain.countOfDaysOverdue]] action:^{
            [self checkNextRequiredDate];
        }], nil] show];
    }else{
        NSInteger currentLength = chain.currentChainLengthForDisplay;
        NSInteger longest = chain.habit.longestChain.length;
        NSString * status = [NSString stringWithFormat:@"Current length: %@ day%@\nLongest chain: %@ day%@", @(currentLength), currentLength == 1 ? @"" : @"s", @(longest), longest == 1 ? @"" : @"s"];
        [SVProgressHUD showImage:chain.isRecord ? [AwardImage starColored:self.habit.color] : [AwardImage circleColored:self.habit.color] status:status];
    }

}

-(void)setState:(DayCheckedState)state{
    _state = state;
    self.label.alpha = self.inactive ? 0.5 : 1.0;
    self.checkbox.state = state;
    self.checkbox.label = self.habit.title;
    self.label.text =// [NSString stringWithFormat:@"%@ %@",habit.identifier,habit.title];//
        self.habit.title;
    self.label.textColor = [self labelTextColor];
    
    
    __weak id welf = self;
    if(self.habit.isActive.boolValue){
        Chain * chain = self.habit.currentChain;
        [self.habitStatusButton setTitle:@(chain.currentChainLengthForDisplay).stringValue forState:UIControlStateNormal];
        NSInteger daysOverdue = chain.countOfDaysOverdue;
        if(!self.failure) self.failure = [self.habit existingFailureForDate:self.day];
        if(self.failure || daysOverdue > 0){
            NSString * timeMissedString = self.failure.active.boolValue && [self.failure.date isEqualToDate:self.day] ? @"today" : [self timeAgoString:daysOverdue];
            reasonEntryField.placeholder = [NSString stringWithFormat:@"Missed %@. What happened?", timeMissedString];
            if(self.failure.active.boolValue) reasonEntryField.text = self.failure.notes;
            self.cancelSkippedDayButton.accessibilityLabel = [NSString stringWithFormat:@"Check %@", [self timeAgoString:daysOverdue]];

            [self.habitStatusButton setBackgroundImage:[AwardImage circleColored:[Colors cobalt]] forState:UIControlStateNormal];

            [self setSwipeGestureWithView:[PastDayCheckView viewWithText:[self timeAgoString:chain.countOfDaysOverdue] frame:CGRectMake(0, 0, 100, self.frame.size.height)] color:chain.habit.color mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                [welf checkNextRequiredDate];
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Checked %@", [welf timeAgoString:daysOverdue]]];
            }];
        }else{
            UIImage * backgroundImage = chain.isRecord ? [AwardImage starColored:chain.habit.color] : [AwardImage circleColored:chain.habit.color];
            [self.habitStatusButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
            self.modeForState3 = MCSwipeTableViewCellModeNone;
        }
    }else{ // paused
        self.modeForState3 = MCSwipeTableViewCellModeNone;
        [self.habitStatusButton setBackgroundImage:[AwardImage circleColored:[Colors cobalt]] forState:UIControlStateNormal];
        [self.habitStatusButton setTitle:@(self.habit.currentChainLength).stringValue forState:UIControlStateNormal];
    }
}
-(void)update{
    [self setState:self.state];
}
@end
