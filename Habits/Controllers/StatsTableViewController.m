//
//  StatsTableViewController.m
//  Habits
//
//  Created by Michael Forrest on 10/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "StatsTableViewController.h"
#import "HabitDay.h"
#import "TimeHelper.h"
#import <NSArray+F.h>
#import "HabitSparklineTableViewCell.h"
#import "Chain.h"
#import "ChainStatsCell.h"
#import "ReasonCellTableViewCell.h"
#import "CoreDataClient.h"
#import "ChainLengthDistributionTableViewCell.h"
#import "Failure.h"
typedef enum {
    StatsSectionSparkline,
    StatsSectionChainLengthDistribution,
    StatsSectionReasons,
    StatsSectionCount,
    StatsSectionChainBreaks,
} StatsSection;

@interface StatsTableViewController ()
@property (nonatomic, strong) NSArray * chains;
@property (nonatomic, strong) NSArray * failures;
@property (nonatomic, strong) ChainLengthDistributionTableViewCell * chainLengthDistributionCell;
@end

@implementation StatsTableViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.title = self.habit.title;
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self loadChains];
    
    [self createChainLengthDistributionCell];
    
    [self.tableView reloadData];
}

-(void)loadChains{
    
    self.chains = self.habit.sortedChains.reverse;
    self.failures = [self.habit.failures sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
}
#pragma mark - Pre-made cells
-(void)createChainLengthDistributionCell{
    ChainLengthDistributionTableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"ChainLengthDistribution"];
    cell.habit = self.habit;
    [cell refresh];
    self.chainLengthDistributionCell = cell;
}

#pragma mark - Table view data source
-(Failure*)failureWithReasonAtIndexPath:(NSIndexPath*)indexPath{
    return self.failures[indexPath.row];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case StatsSectionSparkline: return 230;
        case StatsSectionChainLengthDistribution: return self.chainLengthDistributionCell.height;
        case StatsSectionReasons: return [ReasonCellTableViewCell heightWithReasonText:[self failureWithReasonAtIndexPath:indexPath].notes];
        default: return 44;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return StatsSectionCount;
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case StatsSectionSparkline: return @"STATS";
        case StatsSectionChainLengthDistribution: return self.chains.count > 0 ? @"Length distribution" : nil;
        case StatsSectionReasons: return self.failures.count > 0 ? @"Notes" : nil;
        case StatsSectionChainBreaks: return self.chains.count > 0 ? @"Chains" : @"";
        default: return @"";
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == StatsSectionSparkline) return 1;
    if(section == StatsSectionChainLengthDistribution) return 1;
    if(section == StatsSectionReasons) return self.failures.count;
    if(section == StatsSectionChainBreaks){
        return self.chains.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == StatsSectionSparkline){
        
        HabitSparklineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Sparkline" forIndexPath:indexPath];
        cell.habit = self.habit;
        return cell;
    }
    if(indexPath.section == StatsSectionChainLengthDistribution){
        return self.chainLengthDistributionCell;
    }
    if(indexPath.section == StatsSectionReasons){
        ReasonCellTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ReasonCell" forIndexPath:indexPath];
        cell.failure = [self failureWithReasonAtIndexPath:indexPath];
        return cell;
    }
    if(indexPath.section == StatsSectionChainBreaks){
        ChainStatsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Chain" forIndexPath:indexPath];
        Chain * chain = self.chains[indexPath.row];
        cell.chain = chain;
        return cell;
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return indexPath.section == StatsSectionChainBreaks || indexPath.section == StatsSectionReasons;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Do nothing because I'm not sure how editing works with the chain-based model.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Chain * chain = self.chains[indexPath.row];
        [self.habit removeChainsObject:chain];
        [[CoreDataClient defaultClient].managedObjectContext save:nil];
        [self loadChains];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
//    }else if(editingStyle == UITableViewCellEditingStyleInsert){
//        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
