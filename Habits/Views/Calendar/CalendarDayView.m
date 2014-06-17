//
//  CalendarDayView.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "CalendarDayView.h"
#define CIRCLE_INSET 7
#import "Colors.h"

BOOL stateIsOneOf(CalendarDayState state, NSArray * options){
    for(NSNumber * option in options){
        if (option.intValue == state) return YES;
    }
    return NO;
}

@implementation CalendarDayView{
    UIView * block;
    UIView * circle;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        block = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:block];
        block.userInteractionEnabled = YES;
        
        circle = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, CIRCLE_INSET, CIRCLE_INSET)];
        [self addSubview:circle];
        circle.backgroundColor = [UIColor whiteColor];
        circle.layer.cornerRadius = circle.frame.size.height * 0.5;
        circle.userInteractionEnabled = NO;
        
        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];
        [self setSelectionState: CalendarDayStateFuture color: nil];
    }
    return self;
}
-(BOOL)isAccessibilityElement{
    return YES;
}
-(void)setSelectionState:(CalendarDayState)state color:(UIColor*)color{
    if(stateIsOneOf(state, // do we need a dark background and white text?
                    @[@(CalendarDayStateFirstInChain),
                    @(CalendarDayStateLastInChain),
                    @(CalendarDayStateMidChain),
                    @(CalendarDayStateAlone)])){
        self.label.textColor = [Colors onColor]; // white
        self.backgroundColor = color;
    }
    block.backgroundColor = color;
    self.layer.cornerRadius = state == CalendarDayStateMidChain ? 0 : 22;
    
    // the block is used to fill half the cell when we're at the start or end of a chain - it's also the background of the text-in-a-circle for a day that isn't required

    block.hidden =!stateIsOneOf(state, @[@(CalendarDayStateLastInChain), @(CalendarDayStateFirstInChain), @(CalendarDayStateBetweenSubchains)]);
    if(state == CalendarDayStateLastInChain){ // put block to the left [])
        block.frame = CGRectMake(0, 0, self.frame.size.width * 0.5, self.frame.size.height);
    }else if (state == CalendarDayStateFirstInChain){ // put block to the right ([]
        block.frame = CGRectMake(self.frame.size.width * 0.5, 0, self.frame.size.width * 0.5, self.frame.size.height);
    }else{
        block.frame = self.bounds; // it's part of [o]
    }
    
    circle.hidden = state != CalendarDayStateBetweenSubchains;
    
    if(stateIsOneOf(state, @[@(CalendarDayStateMissed), @(CalendarDayStateFuture), @(CalendarDayStateBeforeStart)])){
        self.backgroundColor = [UIColor whiteColor];
        self.label.textColor = [Colors futureColor];
    }
    if(stateIsOneOf(state, @[@(CalendarDayStateBeforeStart), @(CalendarDayStateNotRequired)])){
        self.label.textColor = [Colors beforeStartColor];
    }
    if(stateIsOneOf(state, @[ @(CalendarDayStateBetweenSubchains), @(CalendarDayStateNotRequired)])){
        self.label.textColor = [Colors notRequiredColor];
    }
    if(state == CalendarDayStateMissed){
        self.label.textColor = [Colors missedColor];
    }
}


@end
