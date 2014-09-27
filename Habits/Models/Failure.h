//
//  Failure.h
//  Habits
//
//  Created by Michael Forrest on 26/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <CoreData/CoreData.h>
@class Habit;

/**
 *  A failure is created when either 
    1. a note is entered for an overdue chain, or 
    2. when a check box is set to the 'missed' state.
 */

@interface Failure : NSManagedObject
/**
 *  Habit to which the failure belongs
 */
@property (nonatomic, strong) Habit * habit;
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSString * notes;
/**
 *  Because failures have notes attached to them we don't necessarily delete them when 
 *  the user cycles through checked / broken / unchecked in the check box. We keep them
 *  around so we don't lose the user's typing.
 */
@property (nonatomic, strong) NSNumber * active;
@end
