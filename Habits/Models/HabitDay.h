//
//  HabitDay.h
//  Habits
//
//  Created by Michael Forrest on 15/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Mantle.h>
@interface HabitDay : MTLModel<MTLJSONSerializing,MTLManagedObjectSerializing>
@property (nonatomic, strong) NSString * habitIdentifier;
@property (nonatomic, strong) NSString * day;
@property (nonatomic, strong) NSNumber * isChecked;
//@property (nonatomic, strong) NSNumber * isChainBreak;
@property (nonatomic, strong) NSNumber * runningTotal;
@property (nonatomic, strong) NSNumber * runningTotalWhenChainBroken;
@property (nonatomic, strong) NSString * notes;
@property (nonatomic, strong) NSNumber * required;
@property (nonatomic, strong) NSString * renderState;
@property (nonatomic, strong) NSString * chainBreakStatus;
@property (nonatomic, strong) NSNumber * userInterventionStatus;
-(NSDate*)date;
-(void)confirmAndSave;
@end
