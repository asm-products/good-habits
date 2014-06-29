//
//  HabitDetailViewController.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "HabitDetailViewController.h"
#import "CalendarPageViewController.h"
#import "DayPicker.h"
#import "TimeHelper.h"
#import "Colors.h"
#import "HabitsList.h"
#import <UIActionSheet+Blocks.h>

typedef enum{
    HabitDetailCellIndexReminderButton,
    HabitDetailCellIndexReminderPicker
} HabitDetailCellIndex;

@interface HabitDetailViewController ()<DayPickerDelegate,UITextFieldDelegate>{
    __weak IBOutlet UITableViewCell *datePickerCell;
    BOOL showingTimePicker;
}
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIButton *remindersButton;
@property (nonatomic, strong) CalendarPageViewController * calendar;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UIButton *clearReminderButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleActiveButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *pausedLabel;
@end

@implementation HabitDetailViewController
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"Calendar"]){
        self.calendar = segue.destinationViewController;
        self.calendar.habit = self.habit;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self build];
}
-(void)build{
    self.navigationItem.title = @"";
    self.titleTextField.text = self.habit.title;
    self.pausedLabel.transform = CGAffineTransformMakeRotation(- M_PI / 4);
    [self updateRemindersButtonTitle];
    [self updateActiveState];
    if(self.habit.reminderTime){
        [self.timePicker setDate:[[NSCalendar currentCalendar] dateFromComponents:self.habit.reminderTime]];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self updateLayoutPickerVisible:NO];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.habit.isNew ){
        [self.titleTextField becomeFirstResponder];
        [self.titleTextField selectAll:self];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.habit.title = self.titleTextField.text;
    [self.habit save];
}
#pragma mark - Reminders
-(void)dayPickerDidChange:(DayPicker *)sender{
    [self.calendar refresh];
}
-(NSString*)remindersButtonTitle{
    if(self.habit.hasReminders){
        return [NSString stringWithFormat:@"Remind at %@", [TimeHelper formattedTime: self.habit.reminderTime]];
    }else{
        return @"No reminder";
    }
}
-(void)updateRemindersButtonTitle{
    [self.remindersButton setTitle:self.remindersButtonTitle forState:UIControlStateNormal];
    [self.clearReminderButton setTitle:self.habit.reminderTime ? @"Clear" : @"Set" forState:UIControlStateNormal];
}
-(void)setRemindersPickerVisible:(BOOL)visible{
    showingTimePicker = visible;
    [UIView animateWithDuration:0.3 animations:^{
        [self updateLayoutPickerVisible: visible];
    }];
}
-(void)updateLayoutPickerVisible:(BOOL)visible{
    [self.remindersButton setTitleColor:visible ? [Colors globalTint]  : [UIColor blackColor] forState:UIControlStateNormal];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == HabitDetailCellIndexReminderPicker) {
        return showingTimePicker ? self.timePicker.frame.size.height : 0;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
-(BOOL)isRemindersPickerVisible{
    return showingTimePicker;
}
-(void)saveReminder{
    self.habit.reminderTime = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:self.timePicker.date];
    [self.habit save];
    [self updateRemindersButtonTitle];
}
- (IBAction)didPressRemindersButton:(id)sender {
    [self setRemindersPickerVisible:![self isRemindersPickerVisible]];
}
- (IBAction)didPressClearReminderButton:(id)sender {
    if(self.habit.reminderTime == nil){
        if(self.isRemindersPickerVisible){
            [self saveReminder];
            [self setRemindersPickerVisible:NO];
        }else{
            [self setRemindersPickerVisible:YES];
        }
    }else{
        self.habit.reminderTime = nil;
        [self updateRemindersButtonTitle];
        [self setRemindersPickerVisible:NO];
    }
}
- (IBAction)didChangeTime:(id)sender {
    [self saveReminder];
}
#pragma mark - title
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    self.habit.title = textField.text;
    [self.habit save];
    return YES;
}
#pragma mark - pause
- (IBAction)didPressToggleActive:(id)sender {
    self.habit.isActive = @(!self.habit.isActive.boolValue);
    [self updateActiveState];
    [self.habit save];
}
-(void)updateActiveState{
    NSString * title;
    CGFloat alpha;
    if(self.habit.isActive.boolValue){
        title = @"Pause this habit";
        alpha = 1.0;
    }else{
        title = @"Resume this habit";
        alpha = 0.5;
    }
    [self.toggleActiveButton setTitle:title forState:UIControlStateNormal];
    self.calendar.view.alpha = alpha;
    self.remindersButton.alpha = alpha;
    self.titleTextField.alpha = alpha;
    self.pausedLabel.hidden = self.habit.isActive.boolValue;
}
#pragma mark - delete
- (IBAction)didPressDeleteButton:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:@"Delete this habit? This cannot be undone." cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] destructiveButtonItem:[RIButtonItem itemWithLabel:@"Delete" action:^{
        [HabitsList deleteHabit:self.habit];
        [self.navigationController popViewControllerAnimated:YES];
        [HabitsList saveAll];
    }] otherButtonItems:nil] showInView:self.view];
}
@end
