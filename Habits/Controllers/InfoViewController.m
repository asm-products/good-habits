//
//  InfoViewController.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "InfoViewController.h"
#import "InfoTask.h"
#import "InactiveHabitsHeader.h"
#import "InfoCell.h"
#import "LinkCell.h"
#import "Colors.h"
#import "Labels.h"
#import "DataExport.h"
#import "HabitsQueries.h"
#import "Habits-Swift.h"
@interface InfoViewController()<MigrateFrom_iCloudTableViewControllerDelegate>
@property (nonatomic, strong) NSArray * tasks;
@property (nonatomic, strong) NSArray * links;
@property (nonatomic, strong) NSArray * credits;
@property (nonatomic, strong) UIView * navBar;
@end

@implementation InfoViewController
-(void)viewDidLoad{
    [super viewDidLoad];
#if DEBUG
#else
    self.navigationItem.leftBarButtonItem = nil;
#endif
    
    [NSNotificationCenter.defaultCenter addObserverForName:PURCHASE_COMPLETED object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self reload];
    }];
    
}
- (IBAction)didPressDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(NSArray *)tasks{
    if(!_tasks) _tasks = [InfoTask due];
    return _tasks;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self reload];
}
-(void)reload{
    _tasks = [InfoTask due];
    [self.tableView reloadData];
}
-(NSArray *)links{
    if( _links != nil){
        return _links;
    }
    NSMutableArray * result = @[
        @{@"text": NSLocalizedString(@"Export your data", @""), @"action": ^{
                               [DataExport run:self client:[CoreDataClient defaultClient]];
                           }},
        @{@"text": NSLocalizedString(@"Log an issue", @""), @"url": @"https://github.com/goodtohear/habits/issues" },
//                           @{@"text": @"Video bug report", @"url":@"goodhabits://lookback"},
        @{@"text": NSLocalizedString(@"Contact us", @""), @"url": @"http://goodtohear.co.uk/contact"}
                           ].mutableCopy;
    DataRecovery * recovery = [DataRecovery new];
    if(recovery.clients.count > 0){
        [result insertObject:
         @{@"text": NSLocalizedString(@"Recover data", @""), @"action": ^{
                               [self performSegueWithIdentifier:@"RecoverData" sender:self];
        }} atIndex:0];
    }
    _links = result;
    return result;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"RecoverData"]){
        MigrateFrom_iCloudTableViewController * dest = segue.destinationViewController;
        dest.delegate = self;
        dest.navigationItem.rightBarButtonItem.title = @"Restore";
        dest.descriptionText = @"This is a screen to help recover missing habit data. Contact info@goodtohear.co.uk for support.";
        dest.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissDataMigration)];
    }
}
-(void)dismissDataMigration{
    [self.navigationController popViewControllerAnimated:true];
}
-(NSArray *)credits{
    if(!_credits) _credits = @[
        @{@"text": NSLocalizedString(@"Michael Forrest (Design/Build)", @""), @"url": @"http://facebook.com/forrestmichael"},
        @{@"text": NSLocalizedString(@"Ulrich Atz (Design)", @""), @"url": @"http://ulrichatz.com?from=goodhabitsapp"}
                               ];
    return _credits;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0: return self.tasks.count;
        case 1: return self.links.count;
        case 2: return self.credits.count;
    }
    return 0;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0) return self.navBar;
    if(section == 1) return [[InactiveHabitsHeader alloc] initWithTitle: LocalizedString(@"You can also", @"")];
    if(section == 2) return [[InactiveHabitsHeader alloc] initWithTitle: LocalizedString(@"Credits", @"")];
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0) return 30;
    return 20;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        InfoCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"Info" forIndexPath:indexPath];
        cell.task = self.tasks[indexPath.row];
        cell.color = (__bridge UIColor *)([self.tasks[indexPath.row] color]);
        cell.controller = self;
        return cell;
    }else{
        LinkCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"Link" forIndexPath:indexPath];
        NSDictionary * link = indexPath.section == 1 ? self.links[indexPath.row] : self.credits[indexPath.row];
        cell.link = link;
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        [self.tasks[indexPath.row] open:self];
        InfoCell * cell = (InfoCell*) [tableView cellForRowAtIndexPath:indexPath];
        [cell markRead];
    }else{
        NSArray * things = indexPath.section == 1 ? self.links : self.credits;
        NSDictionary  *thing = things[indexPath.row];
        NSString * uri = thing[@"url"];
        if(uri){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uri]];
        }else{
            void (^block)() = thing[@"action"];
            if(block) block();
        }
    }
}
-(UIView *)navBar{
    if(!_navBar) {
        _navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        _navBar.backgroundColor = [Colors infoYellow];
        _navBar.userInteractionEnabled = YES;
        
        UILabel * subheading = [Labels subheadingLabelWithFrame:CGRectMake(10, 0, 300, 30)];
        subheading.numberOfLines = 2;
        subheading.font = [subheading.font fontWithSize:15];
        subheading.textColor = [Colors dark];
        subheading.text = NSLocalizedString(@"Hello! We hope you'd like to:", @"Heading of info screen before checklist: Look at the guide, Share this app, Get Happiness app, Rate this app etc...");
        [_navBar addSubview:subheading];
    }
    return _navBar;
}
@end
