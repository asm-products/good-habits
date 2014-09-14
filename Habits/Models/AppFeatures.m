//
//  AppFeature.m
//  Habits
//
//  Created by Michael Forrest on 11/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "AppFeatures.h"
#import <DHAppStoreReceipt.h>

@implementation AppFeatures
+(BOOL)statsEnabled{
    DHAppStoreReceipt * mainBundleReceipt = [DHAppStoreReceipt mainBundleReceipt];
    DHInAppReceipt * receipt = [mainBundleReceipt receiptForProductId:@"statistics"];
    return receipt.receiptData != nil;
}

+(BOOL)shouldShowReasonInput{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"prompt_for_in_app_purchases"] != NO;
}
@end
