//
//  LandingViewController.m
//  Habits
//
//  Created by Michael Forrest on 12/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "LandingViewController.h"
#import "Habit.h"
#import "HabitsList.h"
#import "HabitListViewController.h"
#import "HabitDetailViewController.h"
#import "InfoTask.h"
#import "AppFeatures.h"
#import "StatsPopup.h"
#import "HabitCell.h" // for the notification name
@interface LandingViewController (){
    __weak IBOutlet UILabel *infoCountBadge;
#pragma mark stats enabled only
    StatsPopup * statsPopup;
}
@property (nonatomic, strong) HabitListViewController * habitListViewController;
@end

@implementation LandingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    infoCountBadge.text = @([InfoTask unopenedCount]).stringValue;
    infoCountBadge.hidden = [InfoTask unopenedCount] == 0;
    if([AppFeatures statsEnabled]){
        [self addStatsPopup];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"HabitList"]){
        self.habitListViewController = segue.destinationViewController;
    }
    if([segue.identifier isEqualToString:@"New"]){
        Habit * habit = [Habit new];
        [HabitsList.all addObject:habit];
        [self.habitListViewController insertHabit:habit];        
        HabitDetailViewController * dest = segue.destinationViewController;
        dest.habit = habit;
    }
}

#pragma mark - Stats
-(void)addStatsPopup{
    statsPopup = [[StatsPopup alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 100)];
    [self.view addSubview:statsPopup];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDayToggledForHabit:) name:DAY_TOGGLED_FOR_HABIT object:nil];
}
-(void)onDayToggledForHabit:(NSNotification*)notification{
    Habit * habit = notification.object;
    statsPopup.habit = habit;
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        statsPopup.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height - statsPopup.frame.size.height * 0.5 );
    } completion:^(BOOL finished) {
        
    }];
}
@end
