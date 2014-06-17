//
//  InactiveHabitsHeader.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "InactiveHabitsHeader.h"
#import "Colors.h"
#import "Labels.h"
@implementation InactiveHabitsHeader{
    UILabel * textLabel;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self build];
    }
    return self;
}
-(instancetype)initWithTitle:(NSString *)title{
    if(self = [super init]){
        [self build];
        textLabel.text = title;
    }
    return self;
}
-(void)build{
    self.backgroundColor = [Colors headerBackground];
    textLabel = [Labels subheadingLabelWithFrame: CGRectMake(10, 0, 300, 20)];
    [self addSubview:textLabel];
    textLabel.text = @"Paused habits";
}

@end
