//
//  BaseDAO.h
//  DripHttpDNSSDK
//
//  Created by frog78 on 2017/11/15.
//  Copyright © 2017年 frog78. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BaseDAO : NSObject

@property (strong,nonatomic)NSManagedObjectContext *context;
@property (strong,nonatomic)NSManagedObjectModel *model;
@property (strong,nonatomic)NSPersistentStoreCoordinator *coordinator;

-(NSURL *)applicationDocumentsDirectory;

-(NSManagedObjectModel *)managedObjectModel;

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

-(NSManagedObjectContext *)managedObjectContext;

-(void)saveContext;

@end
