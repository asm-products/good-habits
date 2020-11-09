//
//  AdminTableViewController.m
//  Habits
//
//  Created by Michael Forrest on 29/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "AdminTableViewController.h"
#import "PlistStoreToCoreDataMigrator.h"
#import "HabitsQueries.h"
#import "AppFeatures.h"
@interface AdminTableViewController ()

@end

@implementation AdminTableViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
}
-(void)restoreDataFromPrefsFileNamed:(NSString*)name{
    NSString * path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
    
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray * array = [dict valueForKeyPath:@"goodtohear.habits_habits"];
    [PlistStoreToCoreDataMigrator performMigrationWithArray:array progress:^(float progress) {
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName: HABITS_UPDATED object:nil];
    
}
- (IBAction)didPressRestoreMFData:(id)sender {
    [self restoreDataFromPrefsFileNamed:@"mf.goodtohear.habits"];
}
- (IBAction)didPressRestoreAWData:(id)sender {
    [self restoreDataFromPrefsFileNamed:@"aw.goodtohear.habits"];
}
- (IBAction)clearInAppPurchases:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:STATS_PURCHASED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (IBAction)didPressEnableInAppPurchases:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATS_PURCHASED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(IBAction)crashNow:(id)sender{
    @[][1];
}
@end
