//
//  HelpCaptureInterstitialViewController.m
//  Habits
//
//  Created by Michael Forrest on 14/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "HelpCaptureInterstitialViewController.h"

@interface HelpCaptureInterstitialViewController ()
@property (weak, nonatomic) IBOutlet UIView *overlay;
@property (nonatomic, strong) NSString * detail;
@end

@implementation HelpCaptureInterstitialViewController
-(instancetype)initWithTitle:(NSString *)title detail:(NSString *)detail{
    if(self = [super initWithNibName:@"HelpCaptureInterstitialViewController" bundle:nil]){
        self.title = title;
        self.detail = detail;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = self.title;
    self.detailLabel.text = self.detail;
    self.overlay.layer.cornerRadius = 20;
    self.view.layer.shadowOpacity = 0.3;
    self.view.layer.shadowRadius = 10;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
