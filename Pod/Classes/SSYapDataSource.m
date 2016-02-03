//
//  SSYapDataSource.m
//  SSDataSources-YapDB
//
//  Created by Steven Zhang on 3/2/16.
//  Copyright © 2016 Steven Zhang. All rights reserved.
//

#import "SSYapDataSource.h"
#import "YapDatabaseViewMappings.h"

@implementation SSYapDataSource


- (instancetype)initWithDatabaseConnection: (YapDatabaseConnection *)databaseConnection
                                  mappings: (YapDatabaseViewMappings *)mappings {
    self = [super init];
    
    _databaseReadConnection = databaseConnection;
    
    // Obtain a stable DB snapshot
    [databaseConnection beginLongLivedReadTransaction];
    
    
    // The view may have a whole bunch of groups.
    // In this example, our view sorts items in a bookstore by selling rank.
    // Each book is grouped by its genre within the bookstore.
    // We only want to display a subset of genres (not every single genre)
    
    _mappings = mappings;
    
    // We can do all kinds of cool stuff with the mappings object.
    // For example, we could say we only want to display the top 20 in each genre.
    // This will be covered later.
    //
    // Now initialize the mappings object.
    // It will fetch and cache the counts per group/section.
    [databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
        // One-time initialization
        [mappings updateWithTransaction:transaction];
    }];
    
    // And register for notifications when the database changes.
    // Our method will be invoked on the main-thread,
    // and will allow us to move our stable data-source from our existing state to an updated state.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(yapDatabaseModified:)
                                                 name:YapDatabaseModifiedNotification
                                               object:databaseConnection.database];
    
    
    _empty = (self.numberOfItems == 0);
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - DB notification

- (NSArray *)yapDatabaseModified:(NSNotification *)notification
{
    
    // UICollectionView bug: http://stackoverflow.com/questions/19199985/invalid-update-invalid-number-of-items-on-uicollectionview
    NSInteger originalCount = self.mappings.numberOfItemsInAllGroups;
    
    // Jump to the most recent commit.
    // End & Re-Begin the long-lived transaction atomically.
    // Also grab all the notifications for all the commits that I jump.
    // If the UI is a bit backed up, I may jump multiple commits.
    
    NSArray *notifications = [self.databaseReadConnection beginLongLivedReadTransaction];
    
    // Process the notification(s),
    // and get the change-set(s) as applies to my view and mappings configuration.
    
    NSArray *sectionChanges = nil;
    NSArray *rowChanges = nil;
    
    [[self.databaseReadConnection ext:self.mappings.view] getSectionChanges:&sectionChanges
                                                                 rowChanges:&rowChanges
                                                           forNotifications:notifications
                                                               withMappings:self.mappings];
    
    // No need to update mappings.
    // The above method did it automatically.
    
    if ([sectionChanges count] == 0 & [rowChanges count] == 0)
    {
        // Nothing has changed that affects our tableView
        return notifications;
    }
    
    
    if (self.tableView)
        [self updateTableViewWithSectionChanges:sectionChanges rowChanges:rowChanges];
    
    if (self.collectionView) {
        if (originalCount == 0) {
            [self.collectionView reloadData];
        } else {
            [self updateCollectionViewWithSectionChanges:sectionChanges rowChanges:rowChanges];
        }
    }
    
    BOOL empty = (self.numberOfItems == 0);
    if (empty != self.isEmpty) {
        self.empty = empty;
    }
    
    return notifications;
}

- (void)updateTableViewWithSectionChanges:(NSArray *)sectionChanges rowChanges:(NSArray *)rowChanges {
    // Familiar with NSFetchedResultsController?
    // Then this should look pretty familiar
    
    [self.tableView beginUpdates];
    
    
    // Sections
    for (YapDatabaseViewSectionChange *sectionChange in sectionChanges)
    {
        switch (sectionChange.type)
        {
            case YapDatabaseViewChangeDelete :
            {
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                              withRowAnimation:self.rowAnimation];
                break;
            }
            case YapDatabaseViewChangeInsert :
            {
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                              withRowAnimation:self.rowAnimation];
                break;
            }
            case YapDatabaseViewChangeMove:
            case YapDatabaseViewChangeUpdate:
                // Sections are not expected to be moved or updated
                break;
        }
    }
    
    for (YapDatabaseViewRowChange *rowChange in rowChanges)
    {
        
        switch (rowChange.type)
        {
            case YapDatabaseViewChangeDelete :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:self.rowAnimation];
                break;
            }
            case YapDatabaseViewChangeInsert :
            {
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:self.rowAnimation];
                break;
            }
            case YapDatabaseViewChangeMove :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:self.rowAnimation];
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:self.rowAnimation];
                break;
            }
            case YapDatabaseViewChangeUpdate :
            {
                [self.tableView reloadRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:self.rowAnimation];
                break;
            }
        }
    }
    
    [self.tableView endUpdates];
}

- (void)updateCollectionViewWithSectionChanges:(NSArray *)sectionChanges rowChanges:(NSArray *)rowChanges {
    // Familiar with NSFetchedResultsController?
    // Then this should look pretty familiar
    
    [self.collectionView performBatchUpdates:^{
        // Sections
        for (YapDatabaseViewSectionChange *sectionChange in sectionChanges)
        {
            switch (sectionChange.type)
            {
                case YapDatabaseViewChangeDelete :
                {
                    [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionChange.index]];
                    break;
                }
                case YapDatabaseViewChangeInsert :
                {
                    [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionChange.index]];
                    break;
                }
                case YapDatabaseViewChangeMove:
                case YapDatabaseViewChangeUpdate:
                    // Sections are not expected to be moved or updated
                    break;
            }
        }
        
        for (YapDatabaseViewRowChange *rowChange in rowChanges)
        {
            
            switch (rowChange.type)
            {
                case YapDatabaseViewChangeDelete :
                {
                    [self.collectionView deleteItemsAtIndexPaths:@[ rowChange.indexPath ]];
                    break;
                }
                case YapDatabaseViewChangeInsert :
                {
                    [self.collectionView insertItemsAtIndexPaths:@[ rowChange.newIndexPath ]];
                    break;
                }
                case YapDatabaseViewChangeMove :
                {
                    [self.collectionView deleteItemsAtIndexPaths:@[ rowChange.indexPath ]];
                    [self.collectionView insertItemsAtIndexPaths:@[ rowChange.newIndexPath ]];
                    break;
                }
                case YapDatabaseViewChangeUpdate :
                {
                    [self.collectionView reloadItemsAtIndexPaths:@[ rowChange.indexPath ]];
                    break;
                }
            }
        }
        
    } completion:^(BOOL finished) {
        
    }];
    
    
    
}

#pragma mark - SSBaseDataSource

- (NSUInteger)numberOfSections {
    NSInteger numberOfSections = [self.mappings numberOfSections];
    return numberOfSections;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    return [self.mappings numberOfItemsInSection:section];
    
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    __block id object = nil;
    [self.databaseReadConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        object = [[transaction extension:self.mappings.view]
                  objectAtIndexPath:indexPath
                  withMappings:self.mappings];
    }];
    
    return object;
}

#pragma mark - UITableViewDataSource

/*
 - (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title
 atIndex:(NSInteger)index {
 for (NSInteger i = 0; i < self.mappings.visibleGroups.count; i++) {
 if ([title isEqualToString:self.mappings.visibleGroups[i]]) {
 return i;
 break;
 }
 }
 return NSNotFound;
 }
 - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
 return self.mappings.visibleGroups;
 }
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 return [self.mappings groupForSection:section];
 }
 - (void)tableView:(UITableView *)tableView
 moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
 toIndexPath:(NSIndexPath *)destinationIndexPath {
 NSAssert(NO, @"TSYapDataSource: moving rows is not supported");
 }
 */

@end
