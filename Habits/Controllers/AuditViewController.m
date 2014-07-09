//
//  AuditViewController.m
//  Habits
//
//  Created by Michael Forrest on 08/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "AuditViewController.h"
#import "AuditItemViewController.h"
#import "TimeHelper.h"
#import "Notifications.h"
#import "Audits.h"
typedef enum {
    AuditRowIndexContent,
    AuditRowIndexFooter,
    AuditRowIndexDatePicker
} AuditRowIndex;

@interface AuditViewController()<UIPageViewControllerDataSource, UIPageViewControllerDelegate,AuditItemViewControllerDelegate>

@end

@implementation AuditViewController{
    UIPageViewController * pageViewController;
    __weak IBOutlet UIPageControl *currentPageIndicator;
    __weak IBOutlet UIDatePicker *datePicker;
    __weak IBOutlet UIButton *scheduledTimeButton;
    BOOL isShowingDatePicker;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"PageController"]){
        pageViewController = (UIPageViewController*)segue.destinationViewController;
        [self setupPageViewController];
    }
}
-(void)viewDidLoad{
    [super viewDidLoad];
    self.habits = [Audits habitsToBeAudited];
    [self updateScheduledTime];
    currentPageIndicator.numberOfPages = self.habits.count;
    [pageViewController setViewControllers:@[[self auditItemViewController: self.habits.firstObject]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}
#pragma mark - page view controller
-(void)setupPageViewController{
    pageViewController.delegate = self;
    pageViewController.dataSource = self;
}
-(AuditItemViewController*)auditItemViewController:(Habit*)habit{
    AuditItemViewController * controller = [self.storyboard instantiateViewControllerWithIdentifier:@"AuditItem"];
    controller.habit = habit;
    controller.date = [TimeHelper now];
    controller.delegate = self;
    return controller;
}
// before
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    AuditItemViewController * controller = (AuditItemViewController*)viewController;
    NSInteger index = [self.habits indexOfObject:controller.habit];
    if(index <= 0 ){
        return nil;
    }else{
        return [self auditItemViewController:self.habits[index - 1]];
    }
}
// after
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    AuditItemViewController * controller = (AuditItemViewController*)viewController;
    NSInteger index = [self.habits indexOfObject:controller.habit];
    if(index >= self.habits.count - 1 ){
        return nil;
    }else{
        return [self auditItemViewController:self.habits[index + 1]];
    }
}
-(void)pageViewController:(UIPageViewController *)aPageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    AuditItemViewController * controller = (AuditItemViewController*)pageViewController.viewControllers.firstObject;
    currentPageIndicator.currentPage = [self.habits indexOfObject:controller.habit];
}
-(void)auditItemViewControllerDidCompleteAudit:(AuditItemViewController *)sender{
    AuditItemViewController * controller = (AuditItemViewController*)sender;
    UIViewController * next = [self pageViewController:pageViewController viewControllerAfterViewController:controller];
    if(next) {
        [pageViewController setViewControllers:@[next] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark date selection
-(void)updateScheduledTime{
    NSDateComponents * components = [Audits scheduledTime];
    [datePicker setDate:[[NSCalendar currentCalendar] dateFromComponents:components] animated:NO];
    [scheduledTimeButton setTitle:[NSString stringWithFormat:@"Show this screen at %@", [TimeHelper formattedTime:components]] forState:UIControlStateNormal];
}
- (IBAction)didPressScheduledTimeButton:(id)sender {
    [self toggleDatePickerVisible: !isShowingDatePicker];
}
- (IBAction)onDatePickerValueChanged:(id)sender {
    NSDateComponents * components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:datePicker.date];
    [Audits saveScheduledTime:components];
    [Notifications reschedule];
    [self updateScheduledTime];
}
-(void)toggleDatePickerVisible:(BOOL)visible{
    isShowingDatePicker = visible;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow: visible ? AuditRowIndexDatePicker : 0  inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == AuditRowIndexDatePicker) {
        return isShowingDatePicker ? 162 : 0;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
- (IBAction)didPressDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
