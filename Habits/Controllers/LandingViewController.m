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
#import "StatsTableViewController.h"
@interface LandingViewController (){
    __weak IBOutlet UILabel *infoCountBadge;
#pragma mark stats enabled only
    __weak IBOutlet StatsPopup *statsPopup;
}
@property (nonatomic, strong) HabitListViewController * habitListViewController;
@end

@implementation LandingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    infoCountBadge.text = @([InfoTask unopenedCount]).stringValue;
    infoCountBadge.hidden = [InfoTask unopenedCount] == 0;
    UIBarButtonItem * fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = -26;
    self.navigationItem.leftBarButtonItems = @[fixedSpace, self.navigationItem.leftBarButtonItem];
    if([AppFeatures statsEnabled]){
        [self enableStatsPopup];
    }
}
-(void)viewDidLayoutSubviews{
    [statsPopup animateOut];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"HabitList"]){
        self.habitListViewController = segue.destinationViewController;
    }
    if([segue.identifier isEqualToString:@"New"]){
        Habit * habit = [Habit new];
        habit.identifier = [[NSUUID UUID] UUIDString];
        [HabitsList.all addObject:habit];
        [self.habitListViewController insertHabit:habit];        
        HabitDetailViewController * dest = segue.destinationViewController;
        dest.habit = habit;
        [statsPopup animateOut];
    }
    if([segue.identifier isEqualToString:@"Stats"]){
        StatsTableViewController * controller = (StatsTableViewController*)segue.destinationViewController;
        controller.habit = statsPopup.habit;
        [statsPopup animateOut];
    }
}

#pragma mark - Stats
-(void)enableStatsPopup{
    statsPopup.springDamping = 0.5;
    statsPopup.initialSpringVelocity = 0.5;
    statsPopup.viewablePixels = 120;
    [statsPopup animateOut];
    statsPopup.animateInOutTime = 0.6;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDayToggledForHabit:) name:DAY_TOGGLED_FOR_HABIT object:nil];
}

-(void)onDayToggledForHabit:(NSNotification*)notification{
    Habit * habit = notification.object;
    if(statsPopup.frame.origin.y < self.view.frame.size.height) {
        [UIView animateWithDuration:0.1 animations:^{
            statsPopup.frame = (CGRect){CGPointMake(0, statsPopup.frame.origin.y + 20), statsPopup.frame.size};
        } completion:^(BOOL finished) {
            statsPopup.habit = habit;
            [statsPopup animateIn];
        }];
        
    }else{
        statsPopup.habit = habit;
        [statsPopup animateIn];
    }
    
    
    
    
}
@end
