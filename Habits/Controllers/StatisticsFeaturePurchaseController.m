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
#import <SVProgressHUD.h>
#import "StatisticsFeaturePurchaseViewController.h"
#import <SVProgressHUD.h>
#import "HabitsQueries.h"
@implementation StatisticsFeaturePurchaseController{
    

}
CWL_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(StatisticsFeaturePurchaseController, sharedController);

#pragma mark - Transactions
-(void)listenForTransactions{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for (SKPaymentTransaction * transaction in transactions) {
        NSLog(@"TRansaction state %@", @(transaction.transactionState));
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
                });
                break;
            case SKPaymentTransactionStateFailed:
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
                if (transaction.error.code == SKErrorPaymentCancelled) {
                    // user cancelled payment
                }else{
                    // Optionally, display an error here.
                    NSLog(@"Transaction failed for some reason %@", transaction.error);
//                    [SVProgressHUD showErrorWithStatus:[transaction.error.userInfo valueForKey:NSLocalizedDescriptionKey]];
                    break;
                }
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
               [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATS_PURCHASED];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [SVProgressHUD dismiss];
                    [SVProgressHUD showSuccessWithStatus:@"Statistics unlocked"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:PURCHASE_COMPLETED object:nil];
                });
            default:
                [SVProgressHUD dismiss];
                break;
        }
    }
}


#pragma mark - UI
-(void)showPromptInViewController:(UIViewController *)controller{
    StatisticsFeaturePurchaseViewController * alert = [[StatisticsFeaturePurchaseViewController alloc] initWithNibName:@"StatisticsFeaturePurchaseView" bundle:nil];
    [controller presentViewController:alert animated:YES completion:nil];
}

@end
