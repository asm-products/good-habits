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
@interface HabitDetailViewController ()<DayPickerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIButton *remindersButton;
@property (nonatomic, strong) CalendarViewController * calendar;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@end

@implementation HabitDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scroller.contentInset = UIEdgeInsetsZero;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"Calendar"]){
        self.calendar = segue.destinationViewController;
        [self.calendar showChainsForHabit: self.habit];
    }
}
-(void)dayPickerDidChange:(DayPicker *)sender{
    
}

@end
