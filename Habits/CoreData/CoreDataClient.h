//
//  CoreDataClient.h
//  Habits
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CWLSynthesizeSingleton.h>
@import CoreData;
@interface CoreDataClient : NSObject
CWL_DECLARE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(CoreDataClient, defaultClient);
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, strong) NSPersistentStore * persistentStore;

-(instancetype)initWithStoreUrl:(NSURL*)storeUrl;

-(NSManagedObjectContext*)createPrivateContext;
-(void)nukeStore;
/**
 *  Save the default managed object context
 */
-(void)save;
@end
