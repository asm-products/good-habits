//
//  AuditItemViewController.m
//  Habits
//
//  Created by Michael Forrest on 08/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "AuditItemViewController.h"
#import <YLMoment.h>
#import "TimeHelper.h"
#import "Audits.h"
#import "HabitAnalysis.h"
#import "DayKeys.h"
@interface AuditItemViewController()<UITextFieldDelegate>
@property (nonatomic, strong) HabitAnalysis * analysis;
@property (nonatomic, strong) HabitDay * chainBreak;
@end

@implementation AuditItemViewController{
    
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *chainCountLabel;
    __weak IBOutlet UILabel *dateLabel;
    __weak IBOutlet UIButton *completionButton;
    __weak IBOutlet UITextField *excuseTextField;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    NSAssert(self.habit, @"Needs a habit");
    self.analysis = [[HabitAnalysis alloc] initWithHabit:self.habit];
    [self showNextChainBreak];
    
}
-(BOOL)showNextChainBreak{
    if([self.analysis hasUnauditedChainBreaks]){
        self.chainBreak = [self.analysis nextUnauditedDay];
        if ([self.chainBreak.day isEqualToString:[DayKeys keyFromDate:[TimeHelper now]]] && [[TimeHelper now] isBefore:[TimeHelper dateForTimeToday:[Audits scheduledTime]]]) {
            return NO;
        }
    }else{
        return NO;
    }
    
    NSLog(@"showing chain break for habit %@ date %@ running total %@", self.habit.title, self.chainBreak.day, self.chainBreak.runningTotalWhenChainBroken);
    titleLabel.text = self.habit.title;
    NSInteger chainLength = self.chainBreak.runningTotalWhenChainBroken.integerValue;
    chainCountLabel.text = [NSString stringWithFormat: @"%@ %@", @(chainLength), chainLength == 1 ? @"day" : @"days"];
    chainCountLabel.textColor = self.habit.color;
    completionButton.backgroundColor = self.habit.color;
    
    
    dateLabel.text = [NSString stringWithFormat:@"%@ - %@", [TimeHelper timeAgoString:self.chainBreak.date], [[self dateFormatter] stringFromDate:self.chainBreak.date]];
    return YES;
}
-(NSDateFormatter*)dateFormatter{
    static NSDateFormatter * formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"EEEE d MMM";
    });
    return formatter;
}
- (IBAction)didPressCompletionButton:(id)sender {
    [excuseTextField resignFirstResponder];
    
    [self.habit checkDays:@[ self.chainBreak.day]];
   
    if(![self showNextChainBreak]){
        [self.delegate auditItemViewControllerDidCompleteAudit:self];
    }
}
- (IBAction)didPressFailureButton:(id)sender {
    [self didSelectFailure];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self didSelectFailure];
    return YES;
}
-(void)didSelectFailure{
    [excuseTextField resignFirstResponder];
    self.chainBreak.notes = excuseTextField.text;
    [self.chainBreak confirmAndSave];
    if(![self showNextChainBreak]){
        [self.delegate auditItemViewControllerDidCompleteAudit:self];
    }
}
@end
