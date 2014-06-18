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
    CalendarViewController * calendar = [CalendarViewController new];
    calendar.habit = self.habit;
    calendar.dateToShow = [TimeHelper now];
    calendar.navigationDelegate = self;
    [self setViewControllers:@[calendar] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

}
-(void)refresh{
//    [self.calendar showChainsForHabit: self.habit];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    CalendarViewController * calendar = (CalendarViewController*) viewController;
    CalendarViewController * result = [CalendarViewController new];
    result.habit = self.habit;
    result.navigationDelegate = self;
    result.dateToShow = calendar.dayInPreviousMonth;
    return result;
}
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    CalendarViewController * calendar = (CalendarViewController*) viewController;
    CalendarViewController * result = [CalendarViewController new];
    result.habit = self.habit;
    result.navigationDelegate = self;
    result.dateToShow = calendar.dayInNextMonth;
    return result;
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
