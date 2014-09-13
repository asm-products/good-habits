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
@interface StatisticsFeaturePurchaseViewController ()<UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) MVModalTransition * animator;
@end

@implementation StatisticsFeaturePurchaseViewController
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
        self.animator = [MVPopupTransition createWithSize:CGSizeMake(300, 310) dimBackground:YES shouldDismissOnBackgroundViewTap:YES delegate:nil];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.cornerRadius = 10;
}
- (IBAction)didPressUnlockNow:(id)sender {
}
- (IBAction)didPressRestorePurchase:(id)sender {
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
