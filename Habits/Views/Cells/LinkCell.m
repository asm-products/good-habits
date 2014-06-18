//
//  LinkCell.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "LinkCell.h"
#import "Colors.h"
@implementation LinkCell{
    UIView * backgroundColorView;
    __weak IBOutlet UILabel *label;
}

-(void)awakeFromNib{
    backgroundColorView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundColorView.backgroundColor = [Colors green];
    backgroundColorView.hidden = YES;
    [self addSubview:backgroundColorView];
}
-(void)setHighlighted:(BOOL)highlighted{
    [super setHighlighted:highlighted];
    backgroundColorView.hidden = !highlighted;
    label.textColor = highlighted ? [UIColor whiteColor] : [Colors dark];
}
-(void)setLink:(NSDictionary *)link{
    _link = link;
    label.text = link[@"text"];
}
@end
