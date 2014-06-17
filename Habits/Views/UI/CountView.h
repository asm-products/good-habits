//
//  CountView.h
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountView : UIView
@property (nonatomic) BOOL highlighted;
@property (nonatomic) BOOL isHappy;
@property (nonatomic, strong) UIColor * color;
@property (nonatomic, strong) UIColor * totalColor;
@property (nonatomic, strong) NSArray * text;
@end
