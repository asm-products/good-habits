//
//  AuditItemViewController.m
//  Habits
//
//  Created by Michael Forrest on 08/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "AuditItemViewController.h"
#import "ChainAnalysis.h"
#import <YLMoment.h>
#import "TimeHelper.h"
@interface AuditItemViewController()<UITextFieldDelegate>
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
    NSAssert(self.habit.latestAnalysis, @"should have something in habit.latestAnalysis");
    
    self.chainBreak = self.habit.latestAnalysis.freshChainBreaks.firstObject;
    
    titleLabel.text = self.habit.title;
    NSInteger chainLength = self.chainBreak.chainLength.integerValue;
    chainCountLabel.text = [NSString stringWithFormat: @"%@ %@", @(chainLength), chainLength == 1 ? @"day" : @"days"];
    chainCountLabel.textColor = self.habit.color;
    completionButton.backgroundColor = self.habit.color;

    
    dateLabel.text = [NSString stringWithFormat:@"%@ - %@", [TimeHelper timeAgoString:self.chainBreak.date], [[self dateFormatter] stringFromDate:self.chainBreak.date]];
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
    [self.habit checkDays:@[ self.chainBreak.date ]];
    [excuseTextField resignFirstResponder];
    [self.delegate auditItemViewControllerDidCompleteAudit:self];
}
- (IBAction)didPressFailureButton:(id)sender {
    [self.delegate auditItemViewControllerDidCompleteAudit:self];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.delegate auditItemViewControllerDidCompleteAudit:self];
    [textField resignFirstResponder];
    return YES;
}
@end
