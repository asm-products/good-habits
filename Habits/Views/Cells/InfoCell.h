//
//  InfoCell.h
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "CellWithCheckBox.h"
#import "InfoTask.h"
@interface InfoCell : CellWithCheckBox
@property (nonatomic, strong) InfoTask * task;
@property (nonatomic, strong) UIColor * color;
@property (nonatomic, weak) UIViewController * controller;
-(void)markRead;
@end
