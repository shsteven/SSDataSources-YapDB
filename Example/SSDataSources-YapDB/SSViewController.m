//
//  SSViewController.m
//  SSDataSources-YapDB
//
//  Created by Steven Zhang on 02/03/2016.
//  Copyright (c) 2016 Steven Zhang. All rights reserved.
//

#import "SSViewController.h"
#import "YapDatabase.h"
#import "YapDatabaseView.h"
#import "SSYapDataSource.h"


@interface SSViewController ()

@property (strong) YapDatabase *database;
@property (strong) SSYapDataSource *dataSource;


@end

@implementation SSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self createDatabase];
    [self seedDatabase];
    
    [self createViewPlugin];
    
    YapDatabaseConnection *databaseConnection = [[self database] newConnection];
    
    // The view may have a whole bunch of groups.
    // In this example, our view sorts items in a bookstore by selling rank.
    // Each book is grouped by its genre within the bookstore.
    // We only want to display a subset of genres (not every single genre)
    
    NSArray *groups = @[@"collection"];
    YapDatabaseViewMappings *mappings = [[YapDatabaseViewMappings alloc] initWithGroups:groups
                                                                                   view:@"view"];
    
    
    SSYapDataSource *dataSource = [[SSYapDataSource alloc] initWithDatabaseConnection:databaseConnection mappings:mappings];
    self.dataSource = dataSource;
    
    
    dataSource.cellCreationBlock = ^id(NSString *wizard,
                                       UITableView *tableView,
                                       NSIndexPath *indexPath) {
        return [tableView dequeueReusableCellWithIdentifier:@"cell"];
    };
    
    dataSource.cellConfigureBlock = ^(UITableViewCell *cell,
                                      NSString *object,
                                      UITableView *tableView,
                                      NSIndexPath *indexPath) {
        cell.textLabel.text = object;
    };
    
    
    
    dataSource.tableView = self.tableView;
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)createDatabase {
    self.database = [[YapDatabase alloc] initWithPath:[self path]];
}

- (void)seedDatabase {
    YapDatabaseConnection *dbConnnection = [self.database newConnection];
    [dbConnnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeAllObjectsInAllCollections];
        
        for (NSInteger i = 0; i < 100; i++) {
            NSString *string = [@"Title " stringByAppendingString:@(i).stringValue];
            NSString *key = [@(i) stringValue];
            [transaction setObject:string forKey:key
                      inCollection:@"collection"];
        }
        
    }];
}

- (NSString *)path {
    return [NSTemporaryDirectory() stringByAppendingString:@"DemoDB.sql"];
}

- (void)createViewPlugin {
    YapDatabaseViewGroupingWithObjectBlock groupingBlock;
    YapDatabaseViewSortingWithObjectBlock sortingBlock;
    
    groupingBlock = ^NSString *(YapDatabaseReadTransaction *transaction, NSString *collection, NSString *key, id metadata){
        return @"collection";
    };
    
    sortingBlock = ^(YapDatabaseReadTransaction *transaction, NSString *group, NSString *collection1, NSString *key1, id obj1,
                     NSString *collection2, NSString *key2, id obj2){
        return [key1 compare:key2];
    };
    
    YapDatabaseViewGrouping *grouping = [YapDatabaseViewGrouping withMetadataBlock:groupingBlock];
    YapDatabaseViewSorting *sorting = [YapDatabaseViewSorting withObjectBlock:sortingBlock];
    
    // Only group objects in TSArticle table
    YapDatabaseViewOptions *options = [[YapDatabaseViewOptions alloc] init];
    options.isPersistent = YES;
    
    YapDatabaseView *databaseView =
    [[YapDatabaseView alloc] initWithGrouping:grouping sorting:sorting
                                   versionTag:@"1.0"
                                      options:options];
    
    // Stop blocking UI thread
    [[self database] registerExtension:databaseView
                              withName:@"view"];
}


@end
