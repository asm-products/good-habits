//
//  CountView.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "CountView.h"
#import "Colors.h"
#define RADIUS 14
#define TEXT_PADDING 2

@implementation CountView{
    UILabel * currentChainLabel;
    UILabel * longestChainLabel;
    UIView * background;
    CALayer * square;
    CALayer * circle;
    CALayer * gap;
}

-(void)awakeFromNib{
    [self build];
}
-(UILabel*)label:(CGFloat)x{
    UILabel * result = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, self.frame.size.width*0.5 - TEXT_PADDING * 2, self.frame.size.height)];
    result.textAlignment = NSTextAlignmentCenter;
    result.backgroundColor = [UIColor clearColor];
    result.textColor = [UIColor whiteColor];
    result.font = [UIFont boldSystemFontOfSize:14];
    result.adjustsFontSizeToFitWidth = YES;
    [self addSubview:result];
    return result;
}

-(void)build{
    self.backgroundColor = [UIColor clearColor];
    background = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, self.frame.size}];
    [self addSubview:background];
    
    currentChainLabel = [self label:TEXT_PADDING];
    longestChainLabel = [self label:self.frame.size.width * 0.5 + TEXT_PADDING];
    
    background.backgroundColor = [Colors cobalt];
    background.layer.cornerRadius = RADIUS;
    
    CGFloat halfway = self.frame.size.width * 0.5;
    square = [CALayer layer];
    square.frame = CGRectMake(RADIUS, 0, halfway - RADIUS, self.frame.size.height);
    circle = [CALayer layer];
    circle.frame = CGRectMake(0, 0, halfway, self.frame.size.height);
    circle.cornerRadius = RADIUS;
    
    gap = [CALayer layer];
    gap.backgroundColor = [UIColor whiteColor].CGColor;
    gap.frame = CGRectMake(halfway - 1, 0, 2, self.frame.size.height);

    for(CALayer * layer in @[square, circle, gap]){
        [background.layer addSublayer:layer];
    }
}

-(void)setHighlighted:(BOOL)highlighted{
    _highlighted = highlighted;
    if(!self.color) return;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    UIColor * color = highlighted ? [UIColor whiteColor] : self.color;
    for (CALayer * layer in @[square, circle]) {
        layer.backgroundColor = color.CGColor;
    }
    background.backgroundColor = highlighted ? [UIColor whiteColor] : self.isHappy ? self.color : [Colors cobalt]; // dup

    for(UILabel * label in @[currentChainLabel, longestChainLabel]){
        label.textColor = highlighted ? self.color : [UIColor whiteColor]; // dup
    }
    [CATransaction commit];
}
-(void)setTotalColor:(UIColor *)totalColor{
    _totalColor = totalColor;
    for(CALayer * layer in @[square, circle]){
        layer.backgroundColor = totalColor.CGColor;
    }
}
-(void)setText:(NSArray *)text{
    _text = text;
    currentChainLabel.text = [text[0] stringValue];
    longestChainLabel.text = [text[1] stringValue];
}

-(BOOL)isAccessibilityElement{
    return YES;
}
-(NSString *)accessibilityLabel{
    return [NSString stringWithFormat:@"Current chain length %@, longest chain %@", currentChainLabel.text, longestChainLabel.text];
}

@end
