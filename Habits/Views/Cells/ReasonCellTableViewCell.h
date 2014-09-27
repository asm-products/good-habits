//
//  ReasonCellTableViewCell.h
//  Habits
//
//  Created by Michael Forrest on 12/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Failure.h"
@interface ReasonCellTableViewCell : UITableViewCell
+(CGFloat)heightWithReasonText:(NSString*)text;
@property (nonatomic, strong) Failure * failure;
@end
