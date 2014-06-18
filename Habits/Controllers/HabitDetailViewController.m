//
//  HabitDetailViewController.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "HabitDetailViewController.h"
#import "CalendarViewController.h"
#import "DayPicker.h"
#import "TimeHelper.h"
#import "Colors.h"
#import "HabitsList.h"
@interface HabitDetailViewController ()<DayPickerDelegate,UITextFieldDelegate>{
    
    __weak IBOutlet UIView *timePickerContainer;
    __weak IBOutlet UIView *bottomSection;
}
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIButton *remindersButton;
@property (nonatomic, strong) CalendarViewController * calendar;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UIButton *clearReminderButton;
@end

@implementation HabitDetailViewController
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"Calendar"]){
        self.calendar = segue.destinationViewController;
        [self.calendar showChainsForHabit: self.habit];
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
    self.timePicker.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4].CGColor;
    self.timePicker.layer.borderWidth = 1.0;
    [self updateRemindersButtonTitle];
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

-(void)dayPickerDidChange:(DayPicker *)sender{
    [self.calendar showChainsForHabit:self.habit];
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
    [UIView animateWithDuration:0.3 animations:^{
        [self updateLayoutPickerVisible: visible];
    }];
}
-(void)updateLayoutPickerVisible:(BOOL)visible{
    [self.remindersButton setTitleColor:visible ? [Colors globalTint]  : [UIColor blackColor] forState:UIControlStateNormal];
    timePickerContainer.frame = CGRectMake(0, timePickerContainer.frame.origin.y, 320, visible ? self.timePicker.frame.size.height : 0);
    timePickerContainer.alpha = visible ? 1.0 : 0;
    bottomSection.frame = CGRectMake(0, CGRectGetMaxY(timePickerContainer.frame), 320, bottomSection.frame.size.height);
    self.scroller.contentSize = CGSizeMake(320, CGRectGetMaxY(bottomSection.frame) + 64);
}
-(BOOL)isRemindersPickerVisible{
    return timePickerContainer.alpha > 0;
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
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    self.habit.title = textField.text;
    [self.habit save];
    return YES;
}
@end
