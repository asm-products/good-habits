//
//  MultilineAutoshrinkingLabel.m
//  Habits
//
//  Created by Michael Forrest on 19/11/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "MultilineAutoshrinkingLabel.h"

@implementation MultilineAutoshrinkingLabel
-(void)setText:(NSString *)text{
    [super setText:text];
    int maxDesiredFontSize = 20; //self.font.pointSize;
    int minFontSize = self.minimumScaleFactor * self.font.pointSize;
    CGFloat labelWidth = self.frame.size.width;
    CGFloat labelRequiredHeight = self.frame.size.height;
    UIFont *font = self.font;
    
    int i;
    for(i = maxDesiredFontSize; i > minFontSize; i=i-2)
    {
        font = [font fontWithSize:i];
        NSAttributedString *attributedText =
        [[NSAttributedString alloc]
         initWithString:text
         attributes:@
         {
         NSFontAttributeName: font
         }];
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){labelWidth, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        CGSize labelSize = rect.size;
        if(labelSize.height <= labelRequiredHeight)
            break;
    }
    self.font = font;
}

@end
