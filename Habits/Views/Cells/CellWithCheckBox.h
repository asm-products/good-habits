//
//  CellWithCheckBox.h
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckBox.h"
#import <MCSwipeTableViewCell.h>
@interface CellWithCheckBox : MCSwipeTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet CheckBox *checkbox;
@property (nonatomic, strong) UIColor * color;
-(void)build;
-(UIColor*)labelTextColor;
@end
