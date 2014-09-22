//
//  CellWithCheckBox.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "CellWithCheckBox.h"
#import "Colors.h"
@implementation CellWithCheckBox{
    UIView * backgroundColorView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self build];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self build];
}

-(void)build{
    self.backgroundColor = [UIColor whiteColor];
    backgroundColorView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundColorView.backgroundColor = [Colors cellBackground];
    backgroundColorView.hidden = YES;
    [self insertSubview:backgroundColorView atIndex:0];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
-(void)setColor:(UIColor *)color{
    _color = color;
    self.checkbox.color = color;
    backgroundColorView.backgroundColor = color;
}
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    backgroundColorView.hidden = !highlighted;
    self.label.textColor = highlighted ? [UIColor whiteColor] : [self labelTextColor];
}
-(UIColor *)labelTextColor{
    return [UIColor blackColor];
}
@end
