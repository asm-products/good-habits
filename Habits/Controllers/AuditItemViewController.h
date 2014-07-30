//
//  AuditItemViewController.h
//  Habits
//
//  Created by Michael Forrest on 08/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Habit.h"
#import "HabitDay.h"

@class AuditItemViewController;

@protocol AuditItemViewControllerDelegate <NSObject>

-(void)auditItemViewControllerDidCompleteAudit:(AuditItemViewController*)sender;

@end

@interface AuditItemViewController : UIViewController
@property (nonatomic, strong) HabitDay * habitDay;
@property (nonatomic, strong) Habit * habit;
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, weak) id<AuditItemViewControllerDelegate>delegate;
@end
