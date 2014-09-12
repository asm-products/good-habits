//
//  StatisticsFeaturePurchaseController.m
//  Habits
//
//  Created by Michael Forrest on 04/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "StatisticsFeaturePurchaseController.h"
#import <UIAlertView+Blocks.h>
#import "AppFeatures.h"
#import "SKProductsRequest+Blocks.h"
#import <SVProgressHUD.h>
@implementation StatisticsFeaturePurchaseController
CWL_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(StatisticsFeaturePurchaseController, sharedController);

#pragma mark - Prices
-(void)listenForTransactions{
}

#pragma mark - UI
-(void)showPrompt{
    RIButtonItem * buyNowItem = [RIButtonItem itemWithLabel:@"Buy now ([$0.99])" action:^{
        [self startPurchase];
    }];
    NSSet * set = [NSSet setWithObject:@"statistics"];
    [SKProductsRequest requestWithProductIdentifiers:set withBlock:^(SKProductsResponse *response, NSError *error) {
        if(error){
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }else{
            buyNowItem.label = @"Different label";
        }
        buyNowItem.label = @"Different label";
    }];
    
    [[[UIAlertView alloc] initWithTitle:@"Beggar Bot" message:@"Beggarbot wants you to buy this as a feature." cancelButtonItem:[RIButtonItem itemWithLabel:@"Not now, thanks"] otherButtonItems:
      buyNowItem,
      [RIButtonItem itemWithLabel:@"Unlock existing purchase" action:^{
        [self unlockPurchase];
    }],
      [RIButtonItem itemWithLabel:@"Never ask again" action:^{
        [self disableNagging];
    }] , nil] show];
}
-(void)disableNagging{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"prompt_for_in_app_purchases"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[[UIAlertView alloc] initWithTitle:@":-(" message:@"Ok, we won't ask again. You can re-enable this prompt from the Settings app under Habits" cancelButtonItem:[RIButtonItem itemWithLabel:@"Got it"] otherButtonItems: nil] show];
    [[NSNotificationCenter defaultCenter] postNotificationName:NAGGING_DISABLED object:nil userInfo:nil];
}
#pragma mark - Purchase process
-(void)startPurchase{
    
}
-(void)unlockPurchase{
    
}


@end
