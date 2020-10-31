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
#import "SKProductsRequest+Blocks.h"

@implementation StatisticsFeaturePurchaseController{
    

}
CWL_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(StatisticsFeaturePurchaseController, sharedController);

#pragma mark - Transactions
-(void)listenForTransactions{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

-(void)trackPayment: (SKPaymentTransaction *)transaction{
    NSString * productIdentifier = transaction.payment.productIdentifier;
    NSSet * set = [NSSet setWithObject:productIdentifier];
    [SKProductsRequest requestWithProductIdentifiers:set withBlock:^(SKProductsResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            SKProduct * product = response.products.firstObject;
//             [Answers logPurchaseWithPrice: product.price currency:product.priceLocale.currencyCode success:@YES itemName:product.localizedTitle itemType: @"Unlock" itemId:product.productIdentifier customAttributes:@{}];
        });
        
    }];
}
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
   });
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    
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
               
                if (transaction.error.code == SKErrorPaymentCancelled) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                       [SVProgressHUD dismiss];
                     });
                }else{
                    // Optionally, display an error here.
                    NSLog(@"Transaction failed for some reason %@", transaction.error);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:[transaction.error.userInfo valueForKey:NSLocalizedDescriptionKey]];
                    });
                }
                break;
            case SKPaymentTransactionStatePurchased:
                [self trackPayment: transaction];
                // don't break, continue...

            case SKPaymentTransactionStateRestored:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self unlockStats];
                
                
            default:
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
                break;
        }
 
        
    }
}

-(void)unlockStats{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STATS_PURCHASED];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Statistics unlocked"];
        [[NSNotificationCenter defaultCenter] postNotificationName:PURCHASE_COMPLETED object:nil];
    });
}


#pragma mark - UI
-(void)showPromptInViewController:(UIViewController *)controller{
    StatisticsFeaturePurchaseViewController * alert = [[StatisticsFeaturePurchaseViewController alloc] initWithNibName:@"StatisticsFeaturePurchaseView" bundle:nil];
    [controller presentViewController:alert animated:YES completion:nil];
}

@end
