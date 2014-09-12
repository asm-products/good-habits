//
//  SKProductsRequest+Blocks.m
//  MUBI
//
//  Created by Michael Forrest on 30/01/2014.
//  Copyright (c) 2014 MUBI. All rights reserved.
//

#import "SKProductsRequest+Blocks.h"
#import <objc/runtime.h>

@interface SKProductsRequestBlocksDelegate : NSObject<SKProductsRequestDelegate>
@property (strong, nonatomic) void (^block)(SKProductsResponse *response, NSError *error);
@end

@implementation SKProductsRequestBlocksDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    if(self.block){
        self.block(response, nil);
    }
}
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    if(self.block){
        self.block(nil, error);
    }
}
@end

static char SKProductsRequestBlocksDelegateKey;

@implementation SKProductsRequest (Blocks)

+ (id)requestWithProductIdentifiers:(NSSet *)productIdentifiers withBlock:(void (^)(SKProductsResponse *response, NSError *error))block {
    return [[[self class] alloc] initWithProductIdentifiers:productIdentifiers withBlock:block];
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers withBlock:(void (^)(SKProductsResponse *response, NSError *error))block {
    NSParameterAssert(block != nil);
    
    if((self = [self initWithProductIdentifiers:productIdentifiers])){
        SKProductsRequestBlocksDelegate *productsRequestDelegate = [[SKProductsRequestBlocksDelegate alloc] init];
        
        objc_setAssociatedObject(self, &SKProductsRequestBlocksDelegateKey, productsRequestDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.delegate = productsRequestDelegate;
        productsRequestDelegate.block = block;
        
        [self start];
    }
    
    return self;
}
@end
