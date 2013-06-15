TreeView
========

Component that introduces cells + subcells support for any UITableView living there in controller's view.

ExampleApp demo on Youtube: http://youtu.be/zS3gQ4pnmBs

TreeView is a "proxy" object that converts 2d-like indexPaths (0-0, 0-1, ...)  into N-depth indexPaths (0-0, 0-0-1, 0-0-2, 0-1-0-1, ...).

You usually use TreeView component when your <b>UITableViewCell</b> wants to contain its own subcells that can be easily shown / hidden.<br />


Implementation details
---

TreeView adds 2 logical states to every cell: <b>expanded</b> and <b>collapsed</b>.

You should expand cell to reveal its subcells.<br/>
Keeping this in mind helper methods were implemented: <br/>
<i>
- (void)expand:(NSIndexPath *)indexPath;<br/>
- (BOOL)isExpanded:(NSIndexPath *)indexPath;<br/>
- (void)close:(NSIndexPath *)indexPath;<br/>
</i>

Instead of implementing <b>UITableViewDataSource</b> in your controller - change it to <b>TreeTableDataSource</b>. TreeTableDataSource protocol inherits UITableViewDataSource and introduces 2 new methods:<br/>
<i>
@required <br/>
- (BOOL)tableView:(UITableView *)tableView isCellExpanded:(NSIndexPath *)indexPath;<br/>
- (NSUInteger)tableView:(UITableView *)tableView numberOfSubCellsForCellAtIndexPath:(NSIndexPath *)indexPath;
</i>

Notice all @required dataSource methods are invoked with indexPath of N-depth that uniquely identify cell or subcell.<br/>
Hence you should change behaviour of following method:
<i>
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
</i>
and ensure that it fills every cell with appropriate data.

On the other hand all @optional methods are transparently forwarded to your implementations (if such exist) and indexPath parameter is unchanged - it is 2d indexPath.
You can convert it into N-depth indexPath with:
<i>
- (NSIndexPath *)treeIndexPathFromTablePath:(NSIndexPath *)indexPath;
</i> 
method.


Conclusion
---

With TreeView you can have any cells-subcells levels number. For example:<br />
Cells levels and its indexPaths representation:
  - section 0
      - [0, 0]
      - [0, 1]
      - [0, ...]
  - section 1
      - [1, 0]
      - [1, 1]
          - [1, 1, 0]
          - [1, 1, 1]
          - [1, 1, ...]
      - [1, 2]
          - [1, 2, 0]
  - section 2
      - [2, 0]
      - [2, 1]
      - [2, 2]
      - [2, 3]
      - [2, ...]
  - [...]
<br />
<br />
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

See demo app example that represents this concept in action.

TODO
---

<i>
* Test cells moving between sections.
</i>
