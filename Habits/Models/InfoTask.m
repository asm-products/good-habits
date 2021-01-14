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
#import "StatisticsFeaturePurchaseController.h"
#import "AppFeatures.h"
#define INSTALLED_DATE_KEY @"goodtohear.habits_installed_date"

@import AVKit;
@import StoreKit;

@implementation InfoTask
+(NSArray *)due{
    return [[self all] filter:^BOOL(InfoTask * task) {
        return task.isDue;
    }];
}
+(NSArray *)all{
    static NSArray * result = nil;
    BOOL english = [[[NSLocale preferredLanguages] filter:^BOOL(NSString* language) {
           return [language containsString:@"en"];
       }] count] > 0;
#if DEBUG
    NSInteger daysToBook = 0;
#else
    NSInteger daysToBook = 5;
#endif
        result = @[
            [InfoTask create:@"stats-unlock-purchase" due:0 text:NSLocalizedString(@"Unlock Stats & Trends", @"menu button") color:[Colors pink] getState:^BOOL{
                return [AppFeatures statsEnabled];
            } action:^(UIViewController *controller) {
                [[StatisticsFeaturePurchaseController sharedController] showPromptInViewController:controller];
            }],
            [InfoTask create:@"guide-2" due:0 text: NSLocalizedString(@"Look at the guide", @"menu button") color:[Colors green] action:^(UIViewController *controller) {
                //                       [Answers logCustomEventWithName:@"Viewed Guide" customAttributes:nil];
                NSString * path  = [[NSBundle mainBundle] pathForResource:@"Habits Tutorial" ofType:@"mov"];
                AVPlayer * player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:path]];
                AVPlayerViewController * playerViewController = [[AVPlayerViewController alloc] init];
                playerViewController.player = player;
                
                [controller presentViewController:playerViewController animated:YES completion:^{
                    [player play];
                }];
            }],
            [InfoTask create:@"share" due:0 text:NSLocalizedString(@"Share this app", @"") color:[Colors orange] action:^(UIViewController *controller) {
                //                       [Answers logShareWithMethod:@"Info Screen" contentName:@"App" contentType:nil contentId:nil customAttributes:nil];
                
                NSArray * items = @[[AppSharing new], [NSURL URLWithString:@"https://itunes.apple.com/gb/app/good-habits/id573844300?mt=8"]];
                UIActivityViewController * sheet = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
                [controller presentViewController:sheet animated:YES completion:nil];
            }],
            [InfoTask create:@"mailing_list" due: (english ? daysToBook : 1000000) text:@"Get Your Free Book" color:[Colors green] action:^(UIViewController *controller) {
                NSURL * url = [NSURL URLWithString:@"https://goodtohear.co.uk/free"];
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }],
            [InfoTask create:@"changes" due:14 text:NSLocalizedString(@"Try 'Changes'", @"Checklist item that links to download Changes app") color:[Colors yellow] action:^(UIViewController *controller) {
                //                       [Answers logCustomEventWithName:@"Looked at changes" customAttributes:nil];
                SKStoreProductViewController * storeController = [[SKStoreProductViewController alloc] init];
                //https://apps.apple.com/us/app/changes-mood-insights/id1483226932
                [storeController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: @"1483226932"} completionBlock:^(BOOL result, NSError * _Nullable error) {
                    
                }];
                [controller presentViewController:storeController animated:true completion:nil];
            }],
            [InfoTask create:@"rate" due:3 text:NSLocalizedString(@"Rate this app", @"") color:[Colors purple] action:^(UIViewController *controller) {
                //                       [Answers logCustomEventWithName:@"Tapped Rate App" customAttributes:nil];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://userpub.itunes.apple.com/WebObjects/MZUserPublishing.woa/wa/addUserReview?id=573844300&type=Purple+Software"]];
            }],
            [InfoTask create:@"like" due:0 text:NSLocalizedString(@"Like us on Facebook", @"") color:[Colors blue] action:^(UIViewController *controller) {
                //                       [Answers logCustomEventWithName:@"Went to Facebook" customAttributes:nil];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/298561953497621"]];
            }]
        ];
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
+(instancetype)create:(NSString *)identifier due:(NSInteger)due text:(NSString *)text color:(UIColor *)color getState:(InfoTaskState)getState action:(InfoTaskAction)action{
    InfoTask * task = [self create:identifier due:due text:text color:color action:action];
    task.getState = getState;
    if(getState != nil){
        task.done = getState();
    }
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
    if(self.getState != nil){
        self.done = self.getState();
    }else{
        [self save];
    }
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

+(NSDate*)installationDate{
    NSDate * installedDate = [[NSUserDefaults standardUserDefaults] objectForKey:INSTALLED_DATE_KEY];
    return installedDate;
}
-(BOOL)isDue{
    NSDate * installedDate = [InfoTask installationDate];
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
