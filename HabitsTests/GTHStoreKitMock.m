//
//  GTHStoreKitMock.m
//  MUBI
//
//  Created by Michael Forrest on 11/04/2014.
//  Copyright (c) 2014 MUBI. All rights reserved.
//

#import "GTHStoreKitMock.h"
#import <UIAlertView+BlocksKit.h>

#import <OCMock.h>
@implementation GTHStoreKitMock
-(id)initWithObserver:(id<SKPaymentTransactionObserver>)observer{
    if(self = [super init]){
        self.observer = observer;
        [self setup];
    }
    return self;
}
-(void)setup{
    [[[[OCMockObject mockForClass:[SKPayment class]] stub] andDo:^(NSInvocation *invocation) {
    }] paymentWithProduct:[OCMArg any]];
    id paymentQueue = [OCMockObject mockForClass:[SKPaymentQueue class]];
    [[[paymentQueue stub] andReturn:paymentQueue] defaultQueue];
    [[[paymentQueue stub] andDo:^(NSInvocation *invocation) {
        NSLog(@"Addded payment");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self notifyPaymentQueueUpdatedTransaction:SKPaymentTransactionStatePurchasing];
            [self showLogInAlert];
        });

    }]addPayment:[OCMArg any]];
    [[[paymentQueue stub] andDo:^(NSInvocation *invocation) {
        NSLog(@"Transaction finished");
    }] finishTransaction:[OCMArg any]];
}
-(void)showLogInAlert{
    [UIAlertView bk_showAlertViewWithTitle:@"Sign In to iTunes Store" message:@"Enter the Apple ID password for test3@mubi.com" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if(buttonIndex == 1){
            [self showConfirmationAlert];
        }else{
            [self notifyPaymentQueueFailedTransactionWithSKError:SKErrorPaymentCancelled];
        }
    }];
}
-(void)showConfirmationAlert{
    [UIAlertView bk_showAlertViewWithTitle:@"Confirm Your Subscription" message:@"Do you want to subscribe to MUBI for 1 month for £2.99? This subscription will automatically renew until canceled." cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Confirm"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if(buttonIndex == 1){
            [self confirmSubscription];
        }
        if(buttonIndex == 0){
            [self notifyPaymentQueueUpdatedTransaction:SKPaymentTransactionStateFailed];
        }
    }];
}
-(void)confirmSubscription{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIAlertView bk_showAlertViewWithTitle:@"Thank You" message:@"Your purchase was successful. To go to the App Store and review subscription settings and cancel auto-renewal, tap Manage." cancelButtonTitle:@"Manage" otherButtonTitles:@[@"OK"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self notifyPaymentQueueUpdatedTransaction: SKPaymentTransactionStatePurchased];
        }];
    });
}
-(void)notifyPaymentQueueUpdatedTransaction:(NSInteger)paymentTransactionState{
    NSData * fakeReceipt = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
    id transactionMock = [OCMockObject mockForClass:[SKPaymentTransaction class]];
    [[[transactionMock stub] andReturnValue:@(paymentTransactionState)] transactionState];
    [[[transactionMock stub] andReturn:nil] payment];
    [[[transactionMock stub] andReturn:fakeReceipt] transactionReceipt]; // TODO: change so that the iOS 7 method is always used

    [self.observer paymentQueue:nil updatedTransactions:@[transactionMock]];
}
-(void)notifyPaymentQueueFailedTransactionWithSKError:(NSInteger)errorCode{
    __unsafe_unretained id transactionMock = [OCMockObject mockForClass:[SKPaymentTransaction class]];
    NSInteger value = SKPaymentTransactionStateFailed;
    [[[transactionMock stub] andReturnValue:OCMOCK_VALUE(value)] transactionState];
    [[[transactionMock stub] andReturn:[NSError errorWithDomain:@"" code:errorCode userInfo:nil]] error];
    [self.observer paymentQueue:nil updatedTransactions:@[transactionMock]];
}
-(void)stopMocking{
    
}
@end
