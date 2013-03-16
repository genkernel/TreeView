TreeView
========

UITableView with multiple levels support.
TreeView is not a standalone component. It uses UITableView internally and thus benefits from all its features like 'cells reusing' automatically.
You usually use TreeView component when your cell(UITableViewCell) wants to contain its own subcells.

ExampleApp Demo Video: http://youtu.be/zS3gQ4pnmBs

UITableView represents cells by 2d indexPaths when every cell is in its section.
TreeView promotes an environment when every cell can have it own subcells thus breaking 'cell in a section' logic.
It is implemented via indexPaths remaping strategy. Internal UITableView which renders cells still operates with 2d-like indexPaths. And all those 2d indexPaths are remaped to n-level before being transmited out from TreeView.

Start using TreeView by implementing TreeTableViewDelegate, -DataSource protocols while TreeView implements UITableViewDelegate, -DataSource by itself.

In cases when you need to access underlying UITableView directly you do that via treeView.tableView property.
Remember to remap any n-like indexPath into 2d indexPath with tableIndexPathFromTreePath: method before pushing that index to any UITableView native method.

TreeTableViewDelegate, -DataSource protocols mimics UITableViewDelegate, -DataSource declarations but additionaly ask dataSource if a cell is expanded/closed and if it is expanded - the number of subcells it contains.
TreeView obtains all needed information about cells by asking its DataSource in the following way:
  1) Cells on a root level. TreeView invokes DataSource.treeView:numberOfSubitems: method with indexPath equals to nil that means it is interested in root items that have no parent node. You return N count number.
  2) For every 0..N TreeView asks DataSource.treeView:expanded: whether the cell is expanded and have its subcells visible or not. (cell can have subcells but they are collapsed if root cell is closed - not expanded)
  3) For every 0..N cell TreeView asks its DataSource.treeView:heightForItemAtIndexPath: for a height that cell occupies.
  4) For every 0..N TreeView asks DataSource.treeView:itemForIndexPath: for an UITableViewCell instance. You should exploit TreeView.tableView.dequeueReusableCellWithIdentifier: strategy here as you normally do with every UITableView.
The very root items(with parent==nil) have indexPaths containing 1 index: [0], [1], [2], ... [N].
If you promote, for example, that cell at indexPath [1] is expanded and contains K subitems - then you will be additionaly asked for all its subcells with indexPaths: [1, 0], [1, 1], [1, 2], ... [1, K].
Thus every cell can have its subcells and those subcells have indexPaths with indecies count that equals to rootCell.indexPath.length + 1.
NSIndexPath format note: There is no limitation on indexPath indecies size. Thus all indexPaths possible variants: [0], [1], ... [1, 1], [1, 1, 1, 4, 0], [2, 1, 0, 2, ...] are valid.
indexPath indecies count number is limited by cells-subcells levels of your application only.


With TreeView you can have any cells-subcells levels number. For example:
Cells levels and its indexPaths representation:
- nil(root)
  - [0]
    - [0, 0]
    - [0, 1]
    - [0, ...]
  - [1]
    - [1, 0]
    - [1, 1]
      - [1, 1, 0]
      - [1, 1, 1]
      - [1, 1, ...]
    - [1, 2]
      - [1, 2, 0]
  - [2]
    - [2, 0]
    - [2, 1]
    - [2, 2]
    - [2, 3]
    - [2, ...]
  - [...]

With UITableView data srtucture exposed via 2d indexPaths only. For example:
- section 0
  - [0, 1]
  - [0, 2]
  - [0, 3]
  - [0, ...]
- section 1
  - [1, 0]
  - [1, 1]
  - [1, 2]
  - [1, ...]
- section ...

See demo app example that represents Planets on its 1st level, Countries on the 2nd level, optionally States on the 3rd then Cities on 4th and concrete city info fields on the last one.
