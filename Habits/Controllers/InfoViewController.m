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
@interface InfoViewController ()
@property (nonatomic, strong) NSArray * tasks;
@property (nonatomic, strong) NSArray * links;
@property (nonatomic, strong) NSArray * credits;
@property (nonatomic, strong) UIView * navBar;
@end

@implementation InfoViewController
-(void)viewDidLoad{
    [super viewDidLoad];
}
-(NSArray *)tasks{
    if(!_tasks) _tasks = [InfoTask due];
    return _tasks;
}
-(NSArray *)links{
    if(!_links) _links = @[
                           @{@"text": @"Export your data", @"action": ^{
                               [DataExport run: self];
                           }},
                           @{@"text": @"Log an issue", @"url": @"https://github.com/goodtohear/habits/issues" },
                           @{@"text": @"Contact us", @"url": @"http://goodtohear.co.uk/contact"}
                           ];
    return _links;
}
-(NSArray *)credits{
    if(!_credits) _credits = @[
                               @{@"text": @"Michael Forrest (Design/Build)", @"url": @"http://facebook.com/forrestmichael"},
                               @{@"text": @"Ulrich Atz (Design)", @"url": @"http://ulrichatz.com?from=goodhabitsapp"}
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
    if(section == 1) return [[InactiveHabitsHeader alloc] initWithTitle:@"You can also"];
    if(section == 2) return [[InactiveHabitsHeader alloc] initWithTitle:@"Credits"];
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
        cell.color = [self.tasks[indexPath.row] color];
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
        subheading.text = @"Hello! We hope you'd like to:";
        [_navBar addSubview:subheading];
    }
    return _navBar;
}
@end
