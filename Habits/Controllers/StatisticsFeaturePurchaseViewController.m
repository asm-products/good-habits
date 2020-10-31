//
//  StatisticsFeaturePurchaseViewController.m
//  Habits
//
//  Created by Michael Forrest on 13/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "StatisticsFeaturePurchaseViewController.h"
#import <UIAlertView+Blocks.h>
#import "AppFeatures.h"
#import <MVPopupTransition.h>
#import "SKProductsRequest+Blocks.h"
#import <SVProgressHUD.h>


@interface StatisticsFeaturePurchaseViewController ()<UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UIButton *unlockNowButton;
@property (weak, nonatomic) IBOutlet UIButton *restorePurchaseButton;
@property (nonatomic, strong) MVModalTransition * animator;
@property (nonatomic, strong) SKProduct * product;
@end

@implementation StatisticsFeaturePurchaseViewController
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
        self.animator = [MVPopupTransition createWithSize:CGSizeMake(280, 330) dimBackground:YES shouldDismissOnBackgroundViewTap:YES delegate:nil];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.cornerRadius = 10;
    [self fetchPriceFromAppStore];
}
-(void)fetchPriceFromAppStore{
    NSSet * set = [NSSet setWithObject:@"statistics"];
    [SKProductsRequest requestWithProductIdentifiers:set withBlock:^(SKProductsResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error){
                self.unlockNowButton.enabled = YES;
                if(error.code == 0){
                    [self.unlockNowButton setTitle:@"Couldn't connect" forState:UIControlStateNormal];
                    self.restorePurchaseButton.enabled = NO;
                }else{
                    [self.unlockNowButton setTitle:error.localizedDescription forState:UIControlStateNormal];
                }
                self.unlockNowButton.enabled = NO;
            }else{
                SKProduct * product = [response.products firstObject];
                if(!product){
                    [self.unlockNowButton setTitle:@"No product found" forState:UIControlStateNormal];
                }else{
                    [self enableBuyNowWithProduct:product];
                }
            }
            
        });
    }];
}
-(void)enableBuyNowWithProduct:(SKProduct*)product{
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    formatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.locale = product.priceLocale;
    NSString * title = [NSString stringWithFormat:@"Unlock now (%@)", [formatter stringFromNumber:product.price]];
    [self.unlockNowButton setTitle:title forState:UIControlStateNormal];
    self.unlockNowButton.enabled = YES;
    self.product = product;
    self.restorePurchaseButton.enabled = YES;
}
- (IBAction)didPressUnlockNow:(id)sender {
    // start purchase
    if(!self.product){
        NSLog(@"Error, no product id");
        return;
    }
//    [Answers logStartCheckoutWithPrice:self.product.price currency:self.product.priceLocale.currencyCode itemCount: @1 customAttributes:@{}];
    
    SKMutablePayment * payment = [SKMutablePayment paymentWithProduct:self.product];
    payment.quantity = 1;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    [self dismissViewControllerAnimated:YES completion:^{
//        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    }];
}
- (IBAction)didPressRestorePurchase:(id)sender {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
- (IBAction)didPressDoNotAskAgain:(id)sender {
    [self disableNagging];
}
- (IBAction)didPressNotNow:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Implementations
-(void)disableNagging{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"prompt_for_in_app_purchases"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[[UIAlertView alloc] initWithTitle:@":-(" message:@"Ok, we won't ask again. You can re-enable this prompt from the Settings app under Habits" cancelButtonItem:[RIButtonItem itemWithLabel:@"Got it" action:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }] otherButtonItems: nil] show];

    [[NSNotificationCenter defaultCenter] postNotificationName:NAGGING_DISABLED object:nil userInfo:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id )animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self.animator;
}

- (id )animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.animator;
}
@end
