//
//  InfoTask.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "InfoTask.h"
#import <NSArray+F.h>
#import "Colors.h"
#import "AppSharing.h"
#import "TimeHelper.h"
#import "UserGuideViewController.h"
#define INSTALLED_DATE_KEY @"goodtohear.habits_installed_date"
@import MediaPlayer;

@implementation InfoTask
+(NSArray *)due{
    return [[self all] filter:^BOOL(InfoTask * task) {
        return task.isDue;
    }];
}
+(NSArray *)all{
    static NSArray * result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = @[
                   [InfoTask create:@"guide-2" due:0 text:@"Look at the guide" color:[Colors green] action:^(UIViewController *controller) {
                       NSString * path  = [[NSBundle mainBundle] pathForResource:@"Habits Tutorial" ofType:@"mov"];
                       MPMoviePlayerViewController * player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
                       [controller presentViewController:player animated:YES completion:^{
                           for (UIView * view  in player.view.subviews) {
                               for (UIView * subview in view.subviews) {
                                   for (UIView * subsubview in subview.subviews) {
                                       if([NSStringFromClass([subsubview class]) isEqualToString:@"MPVideoView"]){
                                           subsubview.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1);
                                       }
                                   }

                               }

                           }
                       }];
                   }],
                   [InfoTask create:@"share" due:0 text:@"Share this app" color:[Colors orange] action:^(UIViewController *controller) {
                       NSArray * items = @[[AppSharing new], [NSURL URLWithString:@"https://itunes.apple.com/gb/app/good-habits/id573844300?mt=8"]];
                       UIActivityViewController * sheet = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
                       [controller presentViewController:sheet animated:YES completion:nil];
                   }],
                   [InfoTask create:@"happiness" due:3 text:@"Get Happiness" color:[Colors yellow] action:^(UIViewController *controller) {
                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://goodtohear.co.uk/happiness?from=habits"]];
                   }],
                   [InfoTask create:@"rate" due:3 text:@"Rate this app" color:[Colors purple] action:^(UIViewController *controller) {
                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://userpub.itunes.apple.com/WebObjects/MZUserPublishing.woa/wa/addUserReview?id=573844300&type=Purple+Software"]];
                   }],
                   [InfoTask create:@"like" due:0 text:@"Like us on Facebook" color:[Colors blue] action:^(UIViewController *controller) {
                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/298561953497621"]];
                   }]
                   ];
    });
    return result;
}
+(instancetype)create:(NSString *)identifier due:(NSInteger)due text:(NSString *)text color:(UIColor *)color action:(InfoTaskAction)action{
    InfoTask * task = [InfoTask new];
    task.due = due;
    task.identifier = identifier;
    task.text = text;
    task.color = color;
    task.action = action;
    [task load];
    return task;
}
-(void)open:(UIViewController *)controller{
    [self markOpened];
    self.action(controller);
}
-(void)markOpened{
    self.opened = YES;
    [self save];
}
-(void)toggle:(BOOL)done{
    self.done = done;
    [self save];
}
-(BOOL)isUnopened{
    return !self.opened;
}
-(NSString*)persistenceKey{
    return [NSString stringWithFormat:@"goodtohear.habits_info_task_%@", self.identifier];
}
-(void)load{
    NSDictionary * info = [[NSUserDefaults standardUserDefaults] dictionaryForKey:self.persistenceKey];
    if(!info) info = @{};
    self.opened = [info[@"opened"] boolValue];
    self.done = [info[@"done"] boolValue];
}
-(void)save{
    [[NSUserDefaults standardUserDefaults] setObject:@{
                                                       @"opened": @(self.opened),
                                                       @"done": @(self.done)
                                                       } forKey:self.persistenceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSInteger)unopenedCount{
    return [[self due] filter:^BOOL(InfoTask * task) {
        return task.isUnopened;
    }].count;
}
-(BOOL)isDue{
    NSDate * installedDate = [[NSUserDefaults standardUserDefaults] objectForKey:INSTALLED_DATE_KEY];
    if(!installedDate) return YES;
    return [[TimeHelper addDays:self.due toDate:installedDate] timeIntervalSinceDate:[NSDate date]] < 0;
}
+(void)trackInstallationDate{
    NSDate * installedDate = [[NSUserDefaults standardUserDefaults] objectForKey:INSTALLED_DATE_KEY];
    if (!installedDate) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:INSTALLED_DATE_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
-(void)reset{
    self.opened = NO;
    self.done = NO;
}
+(void)resetAll{
    for(InfoTask * task in [self all]){
        [task reset];
        [task save];
    }
}
@end
