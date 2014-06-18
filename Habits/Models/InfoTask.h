//
//  InfoTask.h
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^InfoTaskAction)(UIViewController*controller);
@interface InfoTask : NSObject
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) InfoTaskAction action;
@property (nonatomic, strong) NSString * identifier;
@property (nonatomic) NSInteger due;
@property (nonatomic, strong) UIColor * color;

@property (nonatomic) BOOL done;
@property (nonatomic) BOOL opened;

+(NSArray*)due;
+(NSArray*)all;
+(NSInteger)unopenedCount;


+(instancetype)create:(NSString*)identifier due:(NSInteger)due text:(NSString*)text color:(UIColor*)color action:(InfoTaskAction)action;

-(BOOL)isDue;

-(void)open:(UIViewController*)controller;
-(void)markOpened;
-(void)toggle:(BOOL)done;
-(BOOL)isUnopened;
-(void)save;
-(void)reset;
+(void)resetAll;

+(void)trackInstallationDate;
@end
