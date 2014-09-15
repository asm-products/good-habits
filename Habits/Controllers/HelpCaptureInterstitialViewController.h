//
//  HelpCaptureInterstitialViewController.h
//  Habits
//
//  Created by Michael Forrest on 14/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpCaptureInterstitialViewController : UIViewController
-(instancetype)initWithTitle:(NSString*)title detail:(NSString*)detail;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
