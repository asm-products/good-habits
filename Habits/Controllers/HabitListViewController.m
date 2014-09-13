//
//  HabitListViewController.m
//  Habits
//
//  Created by Michael Forrest on 27/04/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "HabitListViewController.h"
#import "Habit.h"
#import "TimeHelper.h"
#import "HabitCell.h"
#import "Colors.h"
#import "InactiveHabitsHeader.h"
#import "DayNavigation.h"
#import "Calendar.h"
#import "HabitDetailViewController.h"
#import "Constants.h"
#import "HabitsQueries.h"
#import "InfoTask.h"
#import <NSArray+F.h>
#import <GTHRectHelpers.h>
#import "AppFeatures.h"
typedef enum {
    HabitListSectionActive,
    HabitListSectionCarriedOver,
    HabitListSectionNotToday,
    HabitListSectionInactive
} HabitListSection;
@implementation HabitListViewController{
    dispatch_queue_t reloadQueue;
    NSArray * groups;
    NSDate * now;
    NSDate * today;
    DayNavigation * dayNavigation;
    InactiveHabitsHeader * carriedOver;
    InactiveHabitsHeader * notRequiredTodayTitle;
    InactiveHabitsHeader * inactiveTitle;
    
    
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self build];
    reloadQueue = dispatch_queue_create("reload", DISPATCH_QUEUE_CONCURRENT);
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 40, 0, 0);
    [self loadGroups];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:HABITS_UPDATED object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSLog(@"RELOADING LIST COS HABITS CHANGED");
        [self refresh];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:REFRESH object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self refresh];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:CHAIN_MODIFIED object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self recalculateRowHeights];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:NAGGING_DISABLED object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self recalculateRowHeights];
    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refresh];   
}
-(void)recalculateRowHeights{
    // trigger animated recalculation of row heights
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}
-(void)loadGroups{
    [HabitsQueries refresh];
    groups = @[
               [HabitsQueries activeToday].mutableCopy,
               [HabitsQueries carriedOver].mutableCopy,
               [HabitsQueries activeButNotToday].mutableCopy,
               [HabitsQueries inactive].mutableCopy
               ];
}
-(void)build{
    self.tableView.accessibilityLabel = @"Habits List";
    now = [TimeHelper now];
    today = [TimeHelper today];
    reloadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}
-(void)refresh{
    now = [TimeHelper now];
    today = [TimeHelper today];
    dayNavigation.date = now;
    notRequiredTodayTitle = nil;
    [self loadGroups];
    [self.tableView reloadData];
}
#pragma mark - Table View Controller
-(Habit*)habitForIndexPath:(NSIndexPath*)indexPath{
    return groups[indexPath.section][indexPath.row];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return groups.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [groups[section] count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HabitCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Habit" forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}
-(HabitCell*)configureCell:(HabitCell*)cell forIndexPath:(NSIndexPath*)indexPath{
    cell.day = today;
    cell.delegate = self;
    Habit * habit = [self habitForIndexPath:indexPath];
    cell.inactive = NO;
    cell.chain = [habit chainForDate:now];
    if (habit){
        BOOL habitIsRequiredToday = habit.isActive.boolValue && [habit isRequiredOnWeekday:now];
        if(habitIsRequiredToday){
            cell.color = habit.color;
        }else{
            cell.color = [Colors cobalt];
            cell.inactive = YES;
        }
        if(indexPath.section == HabitListSectionCarriedOver){
            cell.inactive = NO;
            cell.color = habit.color;
        }
        cell.state = habit.currentChain.dayState;
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Habit * habit = [self habitForIndexPath:indexPath];
    CGFloat result = [habit chainForDate:today].isBroken && [AppFeatures shouldShowReasonInput]  ? 81 : 44;
    return result;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(HabitListSectionActive == section){
        return 44;
    }
    return [groups[section] count] > 0 ? 20 : 0;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(HabitListSectionCarriedOver == section){
        if(!carriedOver) carriedOver = [[InactiveHabitsHeader alloc] initWithTitle: @"Carried over from yesterday"];
        return carriedOver;
    }
    if(HabitListSectionActive == section){
        if(!dayNavigation) dayNavigation = [DayNavigation new];
        dayNavigation.date = now;
        return dayNavigation;
    }
    if(HabitListSectionNotToday == section){
        NSString * title = [NSString stringWithFormat:@"Not on %@", [Calendar dayNamesPlural][[TimeHelper weekday:now]] ];
        if(!notRequiredTodayTitle) notRequiredTodayTitle = [[InactiveHabitsHeader alloc] initWithTitle:title];
        return notRequiredTodayTitle;
    }
    if(HabitListSectionInactive){
        if(!inactiveTitle) inactiveTitle = [InactiveHabitsHeader new];
        return inactiveTitle;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    Habit * moved = [self habitForIndexPath:sourceIndexPath];
    if(!moved){
        return;
    }
    if(HabitListSectionInactive != destinationIndexPath.section){
        NSMutableArray * daysRequired = moved.daysRequired.mutableCopy;
        daysRequired[ [TimeHelper weekday:now] ] = @(destinationIndexPath.section == HabitListSectionActive);
        moved.daysRequired = daysRequired;
    }
    [groups[sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.row];
    [groups[destinationIndexPath.section] insertObject:moved atIndex:destinationIndexPath.row];
    
    if(destinationIndexPath.section == HabitListSectionNotToday) return; // because we don't want to mess up the order in this case.
    for(NSArray * group in groups) {
        [group enumerateObjectsUsingBlock:^(Habit * habit, NSUInteger idx, BOOL *stop) {
            habit.order = @(idx);
        }];
    }
    [[CoreDataClient defaultClient] save];
}
-(void)insertHabit:(Habit *)habit{
//    [self loadGroups];
//    NSInteger section = habit.isActive.boolValue ? HabitListSectionActive : HabitListSectionInactive;
//    [self.tableView beginUpdates];
//    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[groups[section] count ] - 1 inSection:section];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic ];
//    [self.tableView endUpdates];
//    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}
#pragma mark - Reordering
-(UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController{
    HabitCell * cell = [[HabitCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.layer.shadowOpacity = 0.5;
    cell.layer.shadowRadius = 5;
    cell.layer.shadowOffset = CGSizeMake(0, 1);
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"Detail"]){
        HabitDetailViewController * dest = segue.destinationViewController;
        dest.habit = [self habitForIndexPath:self.tableView.indexPathForSelectedRow];
    }
}

-(IBAction)unwindHome:(UIStoryboardSegue*)segue{
}


@end
