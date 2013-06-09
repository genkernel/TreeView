//
//  TreeTable.h
//
// Author: kernel@realm
//

#import <UIKit/UIKit.h>

@protocol TreeTableDelegate;
@protocol TreeTableDataSource;

@interface TreeTable : NSObject <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet id<TreeTableDelegate> delegate;
@property (weak, nonatomic) IBOutlet id<TreeTableDataSource> dataSource;

@property (weak, nonatomic, readonly) UITableView *tableView;

// Expands the row revealing its sibling items.
- (void)expand:(NSIndexPath *)indexPath;
- (BOOL)isExpanded:(NSIndexPath *)indexPath;
// Closes expanded row.
- (void)close:(NSIndexPath *)indexPath;
- (NSArray *)siblings:(NSIndexPath *)indexPath;
- (NSIndexPath *)parent:(NSIndexPath *)indexPath;

- (UITableViewCell *)itemForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForItem:(UITableViewCell *)item;
// Coverts multidimensional indexPath into 2d UITableView-like indexPath.
// This helper method is required to prepare indexPath parameter when calling UITableView methods.
- (NSIndexPath *)tableIndexPathFromTreePath:(NSIndexPath *)indexPath;
@end


@protocol TreeTableDelegate <NSObject>
@optional
- (void)treeView:(UITableView *)treeView clicked:(NSIndexPath *)indexPath;
- (CGFloat)treeView:(UITableView *)treeView heightForItemAtIndexPath:(NSIndexPath *)indexPath;
@end


@protocol TreeTableDataSource <NSObject>
@required
- (BOOL)treeView:(UITableView *)treeView expanded:(NSIndexPath *)indexPath;
- (NSUInteger)treeView:(UITableView *)treeView numberOfSubitems:(NSIndexPath *)indexPath;
- (UITableViewCell *)treeView:(UITableView *)treeView itemForIndexPath:(NSIndexPath *)indexPath;
@end
