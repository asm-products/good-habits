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
#import "HabitsList.h"
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
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refresh];
}
-(void)loadGroups{
    groups = @[
               [HabitsList activeToday].mutableCopy,
               [HabitsList carriedOver].mutableCopy,
               [HabitsList activeButNotToday].mutableCopy,
               [HabitsList inactive].mutableCopy
               ];
}
-(void)build{
    now = [TimeHelper now];
    reloadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}
-(void)refresh{
    dispatch_async(reloadQueue, ^{
        now = [TimeHelper now];
        dayNavigation.date = now;
        notRequiredTodayTitle = nil;
        [self loadGroups];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
        });
    });
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
    cell.now = now;
    Habit * habit = [self habitForIndexPath:indexPath];
    cell.inactive = NO;
    cell.habit = habit;
    if (habit){
        BOOL habitIsRequiredToday = habit.isActive.boolValue && [habit isRequiredOnWeekday:now];
        if(habitIsRequiredToday){
            cell.color = habit.color;
        }else{
            cell.color = [Colors cobalt];
            cell.inactive = YES;
            cell.habit = habit;
        }
        if(indexPath.section == HabitListSectionCarriedOver){
            cell.inactive = NO;
            cell.color = habit.color;
            cell.habit = habit;
        }
    }
    return cell;
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
        moved.daysRequired[ [TimeHelper weekday:now] ] = @(destinationIndexPath.section == HabitListSectionActive);
    }
    [groups[sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.row];
    [groups[destinationIndexPath.section] insertObject:moved atIndex:destinationIndexPath.row];
    
    if(destinationIndexPath.section == HabitListSectionNotToday) return; // because we don't want to mess up the order in this case.
    for(NSArray * group in groups) {
        [group enumerateObjectsUsingBlock:^(Habit * habit, NSUInteger idx, BOOL *stop) {
            habit.order = @(idx);
        }];
    }
    [HabitsList saveAll];
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
    if([segue.identifier isEqualToString:@"New"]){
        Habit * habit = [Habit new];
        [habit loadDefaultValues];
        [HabitsList.all addObject:habit];
        [self loadGroups];
        NSInteger section = habit.isActive.boolValue ? HabitListSectionActive : HabitListSectionInactive;
        [self.tableView beginUpdates];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[groups[section] count ] - 1 inSection:section];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic ];
        [self.tableView endUpdates];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        
        HabitDetailViewController * dest = segue.destinationViewController;
        dest.habit = habit;
    }
    if([segue.identifier isEqualToString:@"Detail"]){
        HabitDetailViewController * dest = segue.destinationViewController;
        dest.habit = [self habitForIndexPath:self.tableView.indexPathForSelectedRow];
    }
}

-(IBAction)unwindHome:(UIStoryboardSegue*)segue{
}


@end
