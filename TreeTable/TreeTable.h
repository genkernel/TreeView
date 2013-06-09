//
//  TreeTable.h
//
// Author: kernel@realm
//

#import <UIKit/UIKit.h>

@protocol TreeTableDataSource;

@interface TreeTable : NSObject <UITableViewDataSource>
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
// Converts UITableTable 2d row index into treeTable multidimentional indexPath.
- (NSIndexPath *)treeIndexOfRow:(NSUInteger)row;
@end


@protocol TreeTableDataSource <UITableViewDataSource>
@required
- (BOOL)tableView:(UITableView *)tableView isCellExpanded:(NSIndexPath *)indexPath;
- (NSUInteger)tableView:(UITableView *)tableView numberOfSubCellsForCellAtIndexPath:(NSIndexPath *)indexPath;
@end
