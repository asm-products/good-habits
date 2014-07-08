//
//  CalendarPageViewController.m
//  Habits
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "CalendarPageViewController.h"
#import "CalendarViewController.h"
#import "TimeHelper.h"
@interface CalendarPageViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,CalendarNavigation>

@end

@implementation CalendarPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.dataSource = self;
    CalendarViewController * calendar = [self calendarViewControllerForDate:[TimeHelper now]];
    [self setViewControllers:@[calendar] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

}
-(CalendarViewController*)calendarViewControllerForDate:(NSDate*)date{
    CalendarViewController * calendar = [CalendarViewController new];
    calendar.habit = self.habit;
    calendar.dateToShow = date;
    calendar.navigationDelegate = self;
    return calendar;
}
-(void)refresh{
    CalendarViewController * calendar = (CalendarViewController*) self.viewControllers.firstObject;
    [self setViewControllers:@[[self calendarViewControllerForDate:calendar.dateToShow]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    CalendarViewController * calendar = (CalendarViewController*) viewController;
    return [self calendarViewControllerForDate:calendar.dayInPreviousMonth];
}
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    CalendarViewController * calendar = (CalendarViewController*) viewController;
    return [self calendarViewControllerForDate:calendar.dayInNextMonth];
}
-(void)forward{
    [self setViewControllers:@[
                               [self pageViewController:self viewControllerAfterViewController:self.viewControllers.firstObject]
                               ] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}
-(void)backward{
    [self setViewControllers:@[
                               [self pageViewController:self viewControllerBeforeViewController:self.viewControllers.firstObject]
                               ] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}
@end
