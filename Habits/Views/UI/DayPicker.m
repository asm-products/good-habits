//
//  DayPicker.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "DayPicker.h"
#import "Calendar.h"
#import "DayToggle.h"
#import <ALActionBlocks.h>
#import "Notifications.h"
#import "CoreDataClient.h"

#define ITEM_WIDTH 34
#define VERTICAL_PADDING 4
#define SPACE 10

@implementation DayPicker{
    NSMutableArray * dayButtons;
}
-(void)awakeFromNib{
    self.habit = [self.delegate habit];
    [self build];
    [self refresh];
}
-(void)build{
    self.backgroundColor = [UIColor clearColor];
    dayButtons = [[NSMutableArray alloc] initWithCapacity:7];
    CGFloat x = 8;
    
    for (int i = 0; i < 7; i++) {
        CGRect frame = CGRectMake(x, VERTICAL_PADDING, ITEM_WIDTH, self.frame.size.height - VERTICAL_PADDING * 2);
        NSInteger weekdayIndex = [Calendar weekdayIndexForColumn:i];
        
        NSString * day = [[Calendar days][weekdayIndex] uppercaseString];
        NSString * dayInEnglish = [@[@"Sun", @"Mon", @"Tue", @"Wed",@"Thu",@"Fri",@"Sat"] objectAtIndex:weekdayIndex];
        BOOL isOn = [self.habit.daysRequired[weekdayIndex] boolValue];
        UIColor * color = self.habit.color;
        DayToggle * button = [[DayToggle alloc] initWithFrame:frame day:day dayInEnglish:dayInEnglish color:color isOn:isOn];
        [self addSubview:button];
        
        [button handleControlEvents:UIControlEventTouchUpInside withBlock:^(id weakSender) {
            [button toggleOn:!button.isOn];
            NSMutableArray * daysRequired = self.habit.daysRequired.mutableCopy;
            daysRequired[weekdayIndex] = @(button.isOn);
            self.habit.daysRequired = daysRequired;
            [[CoreDataClient defaultClient] save];
            [Notifications reschedule];
            [self.delegate dayPickerDidChange:self];
        }];
        [dayButtons addObject:button];
        x += ITEM_WIDTH + SPACE;
    }
}
-(void)refresh{
    for (DayToggle * button in dayButtons) {
        button.color = self.habit.color;
        [button setNeedsDisplay];
    }
}

@end
