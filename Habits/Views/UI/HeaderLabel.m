//
//  HeaderLabel.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "HeaderLabel.h"

@implementation HeaderLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont fontWithName:@"HelveticeNeue-Bold" size:20];
        self.textColor = [UIColor whiteColor];
        
    }
    return self;
}


@end
