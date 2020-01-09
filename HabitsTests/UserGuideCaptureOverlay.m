//
//  UserGuideCaptureOverlay.m
//  HabitsTests
//
//  Created by Michael Forrest on 09/01/2020.
//  Copyright © 2020 Good To Hear. All rights reserved.
//

#import "UserGuideCaptureOverlay.h"

@implementation UserGuideCaptureOverlay

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self build];
    }
    return self;
}

-(void)build{
    self.backgroundColor = UIColor.greenColor;
}
@end
