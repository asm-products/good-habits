//
//  SKProductsRequest+Blocks.h
//  MUBI
//
//  Created by Michael Forrest on 30/01/2014.
//  Copyright (c) 2014 MUBI. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface SKProductsRequest (Blocks)
+ (id)requestWithProductIdentifiers:(NSSet *)productIdentifiers withBlock:(void (^)(SKProductsResponse *response, NSError *error))block;
@end
