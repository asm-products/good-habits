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
#import "HabitsQueries.h"
#import <SHMessageUIBlocks.h>
#import "PlistStoreToCoreDataMigrator.h"
#import <SVProgressHUD.h>
#import "JSONConversion.h"
#import "LegacyJSONImporter.h"
#import <UIAlertView+Blocks.h>
@import UIKit;
@import MessageUI;
@import HabitsCommon;
@implementation DataExport


+(void)run:(UIViewController *)parentController client:(CoreDataClient*)client{
    [SVProgressHUD showWithStatus:@"Exporting..." maskType:SVProgressHUDMaskTypeBlack];
//    [Answers logCustomEventWithName:@"Exported Data" customAttributes:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray * habits = [JSONConversion allHabitsAsJSONWithClient:client];
        NSLog(@"Habits json: %@", habits);
        //    NSString * hash = habits
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:habits];
        
        NSString * linkString = [data base64EncodedStringWithOptions:0];
        NSString * messageBody = [NSString stringWithFormat:@"Attached is a JSON file of data exported from Habits by <a href='http://goodtohear.co.uk'>Good To Hear</a>.  To restore this data to the app, tap this <a href='goodhabits://import?json=%@'>RESTORE LINK</a>.", linkString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:habits options:NSUTF8StringEncoding error:nil];
            NSString * jsonPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"habits.json"];
            [jsonData writeToFile:jsonPath atomically:YES];
            
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Data export" message:@"You can email your data to yourself if you use the default email app, or you can copy the JSON to the clipboard" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Send email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                MFMailComposeViewController * controller = [MFMailComposeViewController new];
                [controller setSubject:@"Habits data"];
                [controller setMessageBody:messageBody isHTML:YES];
                [controller addAttachmentData:jsonData mimeType:@"application/json" fileName:@"habits_data.json"];
                [controller SH_setComposerCompletionBlock:^(MFMailComposeViewController *theController, MFMailComposeResult result, NSError *error) {
                    if(error){
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    }
                    if(result == MFMailComposeResultSent || result == MFMailComposeResultCancelled){
                        [parentController dismissViewControllerAnimated:YES completion:nil];
                    }
                }];
                [parentController presentViewController:controller animated:YES completion:^{
                }];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Copy JSON" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString * jsonString = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
                [[UIPasteboard generalPasteboard] setString:jsonString];
                [SVProgressHUD showSuccessWithStatus:@"Copied"];
            }]];
            [alert addAction: [UIAlertAction actionWithTitle:@"Export CSV" style: UIAlertActionStyleDefault handler: ^(UIAlertAction *action){
                NSString * csv = [[[CSVExport alloc] init] execute];
                UIActivityViewController * controller = [[UIActivityViewController alloc] initWithActivityItems:@[csv] applicationActivities:nil];
                [parentController presentViewController:controller animated:true completion:nil];
            }]];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [parentController presentViewController:alert animated:true completion:^{
                [SVProgressHUD dismiss];                
            }];


        });
    });


}
+(BOOL)importDataFromBase64EncodedString:(NSString *)string{
    NSData * data = [[NSData alloc] initWithBase64EncodedString:string options:0];
    if(data == nil) return NO;
    NSArray * array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self importDataFromArray:array];
    return YES;
}
+(void)importDataFromArray:(NSArray*)array{
    BOOL isLegacyFormat = array.firstObject[@"days_checked"] != nil;
    if(isLegacyFormat){
        [LegacyJSONImporter performMigrationWithArray:array];
    }else{
        [JSONConversion performImportWithArray:array];
    }
    [HabitsQueries refresh];
    [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:nil];
}
+(void)scanForJSONFile:(void (^)(BOOL))callback{
    callback(YES);
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * files = [fileManager contentsOfDirectoryAtPath:[self applicationDocumentsDirectory] error:nil ];
    for (NSString * file in files) {
        if ([file hasSuffix:@"json"]) {
            [self promptImportOfJSONFile: [[self applicationDocumentsDirectory] stringByAppendingPathComponent:file]];
        }
    }
}
+(void)promptImportOfJSONFile:(NSString*)path{
    [[[UIAlertView alloc] initWithTitle:@"JSON file detected" message:@"Would you like to import the data from this backup? This cannot be undone." cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] otherButtonItems:[RIButtonItem itemWithLabel:@"Delete File" action:^{
        [self deleteJSONFile:path];
    }], [RIButtonItem itemWithLabel:@"Import Data" action:^{
        [self importAndDeleteJSONFile:path];
    }], nil] show];
}
+(void)importAndDeleteJSONFile:(NSString*)path{
    NSData * data = [NSData dataWithContentsOfFile:path];
    NSError * error;
    NSArray * array = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    [self importDataFromArray:array];
    [self deleteJSONFile:path];
}
+(void)deleteJSONFile:(NSString*)path{
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}
+ (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}
@end
