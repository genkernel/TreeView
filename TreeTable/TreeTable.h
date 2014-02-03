//
// TreeTable.h
//
// Author: kernel@realm
//

#import <UIKit/UIKit.h>


@protocol TreeTableDataSource <UITableViewDataSource>
@required
- (BOOL)tableView:(UITableView *)tableView isCellExpanded:(NSIndexPath *)indexPath;
- (NSUInteger)tableView:(UITableView *)tableView numberOfSubCellsForCellAtIndexPath:(NSIndexPath *)indexPath;
@end


@class TreeTable;

@interface UITableView (TreeTable)
@property (weak, nonatomic, readonly) TreeTable *treeProxy;

- (void)expand:(NSIndexPath *)indexPath;
- (BOOL)isExpanded:(NSIndexPath *)indexPath;
- (void)collapse:(NSIndexPath *)indexPath;
- (NSArray *)siblings:(NSIndexPath *)indexPath;
- (NSIndexPath *)parent:(NSIndexPath *)indexPath;

- (UITableViewCell *)itemForTreeIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)treeIndexPathForItem:(UITableViewCell *)item;

/**
 Coverts multidimensional indexPath into 2d UITableView-like indexPath.
 
 This method is required to prepare indexPath parameter when calling original UITableView's methods.
 */
- (NSIndexPath *)tableIndexPathFromTreePath:(NSIndexPath *)indexPath;

/**
 Converts UITableTable 2d indexPath into multidimentional indexPath.
 
 @param indexPath 2d UITableView-like index path
 
 @return multidimantional TreeView-like indexPath.
 */
- (NSIndexPath *)treeIndexPathFromTablePath:(NSIndexPath *)indexPath;
@end


@interface TreeTable : NSObject <UITableViewDataSource>
@property (weak, nonatomic, readonly) UITableView *tableView;
@property (weak, nonatomic) IBOutlet id<TreeTableDataSource> dataSource;
@property (nonatomic) UITableViewRowAnimation expandingAnimation, closingAnimation;
@end
