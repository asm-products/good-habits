//
//  StatsTableViewController.m
//  Habits
//
//  Created by Michael Forrest on 10/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "StatsTableViewController.h"
#import <Mantle.h>
#import "ChainBreak.h"
#import "ChainAnalysis.h"
#import "TimeHelper.h"
#import "Audits.h"
#import <NSArray+F.h>
#import "HabitSparklineTableViewCell.h"
typedef enum {
    StatsSectionSparkline,
    StatsSectionChainBreaks,
    StatsSectionCount
} StatsSection;

@interface StatsTableViewController ()
@property (nonatomic, strong) NSArray * chainBreaks;
@end

@implementation StatsTableViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.title = self.habit.title;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.chainBreaks = [self.habit.latestAnalysis allChainBreaks];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case StatsSectionSparkline: return 86;
        default: return 44;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return StatsSectionCount;
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case StatsSectionChainBreaks: return @"Broken chains";
        default: return @"";
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == StatsSectionSparkline) return 1;
    if(section == StatsSectionChainBreaks){
        return self.chainBreaks.count;
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
    if(indexPath.section == StatsSectionChainBreaks){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChainBreak" forIndexPath:indexPath];
        ChainBreak * chainBreak = self.chainBreaks[indexPath.row];
        cell.textLabel.text = [TimeHelper timeAgoString:chainBreak.date];//[NSString stringWithFormat:@"%@ - %@",, nil]; // chainBreak.date];
        cell.detailTextLabel.text = chainBreak.notes;
        return cell;
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return indexPath.section == StatsSectionChainBreaks;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ChainBreak * chainBreak = self.chainBreaks[indexPath.row];
        [chainBreak destroy];
        self.chainBreaks = [self.chainBreaks filter:^BOOL(id obj) {
            return obj != chainBreak;
        }];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else if(editingStyle == UITableViewCellEditingStyleInsert){
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
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
