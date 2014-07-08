//
//  ColorPickerButton.h
//  Habits
//
//  Created by Michael Forrest on 08/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorPickerButton : UIButton
-(instancetype)initWithFrame:(CGRect)frame color:(UIColor*)color;
@property (nonatomic, strong) UIColor * color;
@property (nonatomic) BOOL isSelected;
@end
