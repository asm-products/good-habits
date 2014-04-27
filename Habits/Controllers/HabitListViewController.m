//
//  HabitListViewController.m
//  Habits
//
//  Created by Michael Forrest on 27/04/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "HabitListViewController.h"
#import "Habit.h"

typedef enum {
    HabitListSectionActive,
    HabitListSectionCarriedOver,
    HabitListSectionNotToday,
    HabitListSectionInactive
} HabitListSection;
@implementation HabitListViewController{
    dispatch_queue_t reloadQueue;
    NSArray * groups;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self build];
    reloadQueue = dispatch_queue_create("reload", DISPATCH_QUEUE_CONCURRENT);
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 40, 0, 0);
    [self loadGroups];
}
-(void)loadGroups{
    groups = @[
#warning Need to sort these
               [Habit activeToday],
               [Habit carriedOver],
               [Habit activeButNotToday],
               [Habit inactive]
               ];
}
-(void)build{
    
}
-(IBAction)unwindHome:(UIStoryboardSegue*)segue{
}
@end
