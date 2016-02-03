//
//  SSYapDataSource.h
//  SSDataSources-YapDB
//
//  Created by Steven Zhang on 3/2/16.
//  Copyright © 2016 Steven Zhang. All rights reserved.
//

#import "SSBaseDataSource.h"
#import "YapDatabase.h"
#import "YapDatabaseView.h"

/**
 * Generic table/collectionview data source, useful when your data comes from an YapDatabaseView.
 * Automatically inserts/reloads/deletes rows in the table or collection view in response to YapDatabaseView events.
 */

@interface SSYapDataSource : SSBaseDataSource

- (instancetype)initWithDatabaseConnection: (YapDatabaseConnection *)databaseConnection
                                  mappings: (YapDatabaseViewMappings *)mappings;

@property (strong, nonatomic, readonly) YapDatabaseConnection *databaseReadConnection;
@property (strong, nonatomic, readonly) YapDatabaseViewMappings *mappings;

@property (assign, nonatomic, getter=isEmpty) BOOL empty;

/**
 *  Find a object by its database ID and return its index path
 *
 *  @param objectId managed object ID
 *
 *  @return an index path, or nil if the object is not found
 */
//- (NSIndexPath *) indexPathForItemWithYapCollectionKey:(YapCollectionKey *)collectionKey;

// Private, notification triggered

- (NSArray *)yapDatabaseModified:(NSNotification *)notification;

@end
