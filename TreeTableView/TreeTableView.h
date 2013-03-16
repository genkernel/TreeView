//
//  TreeView.h
//

#import <UIKit/UIKit.h>

@protocol TreeTableViewDelegate;
@protocol TreeTableViewDataSource;

@interface TreeTableView : UIView <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet id<TreeTableViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet id<TreeTableViewDataSource> dataSource;

@property (strong, nonatomic, readonly) UITableView *tableView;

// Expands the row revealing its sibling items.
- (void)expand:(NSIndexPath *)indexPath;
- (BOOL)isExpanded:(NSIndexPath *)indexPath;
// Closes expanded row.
- (void)close:(NSIndexPath *)indexPath;
- (NSArray *)siblings:(NSIndexPath *)indexPath;
- (NSIndexPath *)parent:(NSIndexPath *)indexPath;

- (UITableViewCell *)itemForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForItem:(UITableViewCell *)item;
// Coverts TreeTableView multidimensional indexPath into 2d UITableView indexPath.
// This helper method is usually required every time when accessing tree.tableView UITableView directly.
- (NSIndexPath *)tableIndexPathFromTreePath:(NSIndexPath *)indexPath;
@end


@protocol TreeTableViewDelegate <NSObject>
@optional
- (void)treeView:(TreeTableView *)treeView clicked:(NSIndexPath *)indexPath;
- (CGFloat)treeView:(TreeTableView *)treeView heightForItemAtIndexPath:(NSIndexPath *)indexPath;
@end


@protocol TreeTableViewDataSource <NSObject>
@required
- (BOOL)treeView:(TreeTableView *)treeView expanded:(NSIndexPath *)indexPath;
- (NSUInteger)treeView:(TreeTableView *)treeView numberOfSubitems:(NSIndexPath *)indexPath;
- (UITableViewCell *)treeView:(TreeTableView *)treeView itemForIndexPath:(NSIndexPath *)indexPath;
@end
