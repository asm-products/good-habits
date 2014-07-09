//
//  RoundedButton.m
//  Habits
//
//  Created by Michael Forrest on 08/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "RoundedButton.h"

@implementation RoundedButton
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.layer.cornerRadius = self.frame.size.height / 2;
}
@end
