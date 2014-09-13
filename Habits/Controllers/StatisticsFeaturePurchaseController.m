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
#import "StatisticsFeaturePurchaseViewController.h"
@implementation StatisticsFeaturePurchaseController{
    

}
CWL_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(StatisticsFeaturePurchaseController, sharedController);

#pragma mark - Prices
-(void)listenForTransactions{
}

#pragma mark - UI
-(void)showPromptInViewController:(UIViewController *)controller{
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
    StatisticsFeaturePurchaseViewController * alert = [[StatisticsFeaturePurchaseViewController alloc] initWithNibName:@"StatisticsFeaturePurchaseView" bundle:nil];
    
    [controller presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Purchase process
-(void)startPurchase{
    
}
-(void)unlockPurchase{
    
}


@end
