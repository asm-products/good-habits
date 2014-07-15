//
//  HabitDay.h
//  Habits
//
//  Created by Michael Forrest on 15/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "MTLModel.h"

@interface HabitDay : MTLModel
@property (nonatomic, strong) NSString * habitIdentifier;
@property (nonatomic, strong) NSString * day;
@property (nonatomic, strong) NSNumber * isChainBreak;
@property (nonatomic, strong) NSNumber * runningTotal;
@property (nonatomic, strong) NSString * notes;
@end
