//
//  GTHStoreKitMock.h
//  MUBI
//
//  Created by Michael Forrest on 11/04/2014.
//  Copyright (c) 2014 MUBI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <CWLSynthesizeSingleton.h>
@interface GTHStoreKitMock : NSObject
@property (nonatomic, strong) id<SKPaymentTransactionObserver>observer;
-(id)initWithObserver:(id<SKPaymentTransactionObserver>)observer;
-(void)stopMocking;
@end
