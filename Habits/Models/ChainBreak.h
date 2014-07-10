//
//  ChainBreak.h
//  Habits
//
//  Created by Michael Forrest on 09/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Mantle.h>
@interface ChainBreak : MTLModel<MTLManagedObjectSerializing>
@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSString * habitIdentifier;
@property (nonatomic, strong) NSString * notes;
@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSNumber * chainLength;
-(void)confirmAndSave;
-(void)destroy;
@end
