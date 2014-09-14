//
//  StatisticsFeaturePurchaseController.h
//  Habits
//
//  Created by Michael Forrest on 04/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CWLSynthesizeSingleton.h>

@import StoreKit;

@interface StatisticsFeaturePurchaseController : NSObject<SKPaymentTransactionObserver,SKRequestDelegate>
CWL_DECLARE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(StatisticsFeaturePurchaseController, sharedController);
-(void)listenForTransactions;
-(void)showPromptInViewController:(UIViewController*)controller;
@end
