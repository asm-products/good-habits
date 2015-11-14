//
//  CoreDataClient.h
//  Habits
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#ifdef __OBJC__
    #import <UIKit/UIKit.h>
    #import <Foundation/Foundation.h>
    #define TEST_ENVIRONMENT ([[[NSProcessInfo processInfo] arguments] indexOfObject:@"Testing=1"] != NSNotFound)

#endif

#import <Foundation/Foundation.h>
@import CoreData;
@interface CoreDataClient : NSObject
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, strong) NSPersistentStore * persistentStore;

+(instancetype)defaultClient;
+(NSURL*)groupStoreURL;
-(void)migrateToAppGroupStore:(void (^)())completion;
-(instancetype)initWithReadOnlyStoreUrl:(NSURL*)readOnlyStoreUrl;

-(NSManagedObjectContext*)createPrivateContext;
-(void)nukeStore;
/**
 *  Save the default managed object context
 */
-(void)save;

-(NSArray*)allHabits;
-(NSDate*)lastUsedDate;
@end
