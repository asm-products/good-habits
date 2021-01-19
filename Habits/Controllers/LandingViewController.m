//
//  LandingViewController.m
//  Habits
//
//  Created by Michael Forrest on 12/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "LandingViewController.h"
#import "Habit.h"
#import "HabitsQueries.h"
#import "HabitListViewController.h"
#import "HabitDetailViewController.h"
#import "InfoTask.h"
#import "AppFeatures.h"
#import "StatsPopup.h"
#import "HabitCell.h" // for the notification name
#import "StatsTableViewController.h"
#import "HabitToggler.h"
#import "TimeHelper.h"

@interface LandingViewController (){
    __weak IBOutlet UILabel *infoCountBadge;
    __weak IBOutlet UILabel *startHereLabel;
#pragma mark stats enabled only
    __weak IBOutlet StatsPopup *statsPopup;
}
@property (nonatomic, strong) HabitListViewController * habitListViewController;
@end

@implementation LandingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateInfoCountBadge];
    UIBarButtonItem * fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = -26;
    self.navigationItem.leftBarButtonItems = @[fixedSpace, self.navigationItem.leftBarButtonItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTodayCheckedForChain:) name:TODAY_CHECKED_FOR_CHAIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBookPromoStatusUpdate) name:@"BOOK_PROMO_STATUS_UPDATED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshOnboarding) name:HABITS_UPDATED object:nil];
    [self refreshOnboarding];
    [self.view setNeedsLayout];
}
-(void)updateInfoCountBadge{
    infoCountBadge.text = @([InfoTask unopenedCount]).stringValue;
    infoCountBadge.hidden = [InfoTask unopenedCount] == 0;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.habitListViewController refresh];
    [self updateInfoCountBadge];
    [self updateBookPromoAnimated: false];
    if([AppFeatures statsEnabled]){
//        [self enableStatsPopup];
    }
}
-(void)refreshOnboarding{
    startHereLabel.text = NSLocalizedString(@"Start Here", @"");
    self.startHereOverlay.hidden = [HabitsQueries all].count > 0;
}
-(void)viewDidLayoutSubviews{
    [statsPopup hide];
    [self refreshOnboarding];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)handleBookPromoStatusUpdate{
    [self updateBookPromoAnimated:true];
}
-(void)updateBookPromoAnimated:(BOOL)animated{
//    BOOL userSpeaksEnglish = [[NSLocale preferredLanguages] filter:^BOOL(NSString* language) {
//        return [language containsString:@"en"];
//    }].count > 0;
    BOOL userSpeaksEnglish = true;
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDate * installedDate = [InfoTask installationDate];
    if(!installedDate){
        installedDate = [NSDate date];
    }
    NSDate * dueDate = [TimeHelper addDays:5 toDate:installedDate];
#if DEBUG
    BOOL hasTappedSignUpOnBookPitch = false;
#else
    BOOL hasTappedSignUpOnBookPitch = [userDefaults boolForKey:@"has-tapped-sign-up-on-book-pitch"];
#endif
    NSTimeInterval snoozedUntilTimeInterval = [userDefaults doubleForKey:@"book-pitch-snoozed-until"];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:snoozedUntilTimeInterval];
    // date will be distant past if it was never snoozed which suits our purposes
    BOOL shouldShowPromo = userSpeaksEnglish
        && !hasTappedSignUpOnBookPitch
        && [dueDate timeIntervalSinceNow] < 0
        && [date timeIntervalSinceNow] < 0;
    self.bookPromoHeight.constant = shouldShowPromo ? 128 : 0;
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    }else{
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [statsPopup animateOut];
    if([segue.identifier isEqualToString:@"HabitList"]){
        self.habitListViewController = segue.destinationViewController;
    }
    if([segue.identifier isEqualToString:@"New"]){
//        [Answers logCustomEventWithName:@"Added Habit" customAttributes:@{
//                                                                          @"Current Count": [NSNumber numberWithUnsignedInteger:[[HabitsQueries all] count]]
//                                                                          }];
        Habit * habit = [Habit createNew];
        habit.identifier = [[NSUUID UUID] UUIDString];
//        [HabitsList.all addObject:habit];
        [self.habitListViewController insertHabit:habit];
        HabitDetailViewController * dest = segue.destinationViewController;
        dest.habit = habit;
        self.startHereOverlay.hidden = true;
    }
    if([segue.identifier isEqualToString:@"Stats"]){
        StatsTableViewController * controller = (StatsTableViewController*)segue.destinationViewController;
        controller.habit = statsPopup.habit;
    }
}

#pragma mark - Stats
-(void)enableStatsPopup{
    statsPopup.translatesAutoresizingMaskIntoConstraints = NO;
    statsPopup.springDamping = 0.5;
    statsPopup.initialSpringVelocity = 0.5;
    statsPopup.viewablePixels = 120;
    [statsPopup animateOut];
    statsPopup.animateInOutTime = 0.6;

}

-(void)onTodayCheckedForChain:(NSNotification*)notification{
    Chain * chain = notification.object;
//    [Answers logCustomEventWithName:@"Checklist Checked" customAttributes:@{@"HabitName": chain.habit.title}];
    if([AppFeatures statsEnabled] == NO) return;
    if(self.statsVisible) {
        [UIView animateWithDuration:0.1 animations:^{
            statsPopup.frame = (CGRect){CGPointMake(0, statsPopup.frame.origin.y + 20), statsPopup.frame.size};
        } completion:^(BOOL finished) {
            statsPopup.habit = chain.habit;
            [statsPopup animateIn];
        }];
        
    }else{
        statsPopup.habit = chain.habit;
        [statsPopup animateIn];
    }
}
-(BOOL)statsVisible{
    return statsPopup.frame.origin.y < self.view.frame.size.height;
}
@end
