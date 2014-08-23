//
//  DataExport.m
//  Habits
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "DataExport.h"
#import "Habit.h"
#import <NSArray+F.h>
#import <Mantle.h>
#import "HabitsQueries.h"
#import <SHMessageUIBlocks.h>
#import "PlistStoreToCoreDataMigrator.h"
@import MessageUI;
@implementation DataExport


+(void)run:(UIViewController *)parentController{
    NSArray * habits = [MTLJSONAdapter JSONArrayFromModels:[HabitsQueries all]];
    NSLog(@"Habits json: %@", habits);
//    NSString * hash = habits
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:habits];
    NSString * linkString = [data base64EncodedStringWithOptions:0];
    NSString * messageBody = [NSString stringWithFormat:@"Attached is a JSON file of data exported from Habits by <a href='http://goodtohear.co.uk'>Good To Hear</a>.  To restore this data to the app, tap this <a href='goodhabits://import?json=%@'>RESTORE LINK</a>.", linkString];
    
    MFMailComposeViewController * controller = [MFMailComposeViewController new];
    [controller setSubject:@"Habits data"];
    [controller setMessageBody:messageBody isHTML:YES];
    [controller addAttachmentData:[NSJSONSerialization dataWithJSONObject:habits options:NSUTF8StringEncoding error:nil] mimeType:@"application/json" fileName:@"habits_data.json"];
    [controller SH_setComposerCompletionBlock:^(MFMailComposeViewController *theController, MFMailComposeResult result, NSError *error) {
        if(result == MFMailComposeResultSent || result == MFMailComposeResultCancelled){
            [parentController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [parentController presentViewController:controller animated:YES completion:nil];
}
+(void)importDataFromBase64EncodedString:(NSString *)string{
    NSData * data = [[NSData alloc] initWithBase64EncodedString:string options:0];
    NSArray * array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    [PlistStoreToCoreDataMigrator performMigrationWithArray:array progress:^(float progress) {
        NSLog(@"Import progress: %@", @(progress));
    }];
}
@end
