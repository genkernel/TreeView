Swift notes
---

TreeView is written in Objective-C and fully compatibile with Swift.
Check out [swift-example](https://github.com/genkernel/TreeView/tree/swift-example) branch to see how well it plays with Swift.


TreeView
========

Component that introduces cells + subcells support for any UITableView living there in a controller's view.

Example on Youtube: http://youtu.be/zS3gQ4pnmBs

TreeView is a "proxy" object that sits between table view and a view controller, proxies all calls to data source and converts 2d-like indexPaths (0-0, 0-1, ...)  into N-depth indexPaths (0-0, 0-0-1, 0-0-2, 0-1-0-1, ...).


You usually use TreeView component when your <b>UITableViewCell</b> wants to contain its own subcells that can be easily shown / hidden.<br />


Examples
---
Take a look at 3 branches: [fsTree-example](https://github.com/genkernel/TreeView/tree/fsTree-example), [allExpanded-example](https://github.com/genkernel/TreeView/tree/allExpanded-example) and [plistDatasource-example](https://github.com/genkernel/TreeView/tree/plistDatasource-example) to get inside view on how to implement subcells support for a table view.


Implementation details
---

TreeView adds 2 logical states to every cell: <b>expanded</b> and <b>collapsed</b>.

You should expand cell to reveal its subcells.<br/>

Keeping this in mind helper methods(via UITableView category) were implemented: <br/>
```swift
func expand(treeIndexPath: IndexPath)
func isExpanded(treeIndexPath: IndexPath) -> Bool
func collapse(treeIndexPath: IndexPath)
```

Instead of implementing <b>UITableViewDataSource</b> in your controller - implement <b>TreeTableDataSource</b>. TreeTableDataSource protocol extends UITableViewDataSource by introducing 2 new required methods:<br/>
```swift
func tableView(_ tableView: UITableView, isCellExpandedAt treeIndexPath: IndexPath) -> Bool
func tableView(_ tableView: UITableView, numberOfSubCellsForCellAt treeIndexPath: IndexPath) -> Int
```

Notice all <b>required</b> dataSource methods are invoked with indexPath of N-depth that uniquely identify cell or subcell.<br/>
Hence you should change behaviour of the following methods:
```swift
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
func tableView(tableView: UITableView, cellForRowAt treeIndexPath: IndexPath) -> UITableViewCell
```

and use 
```swift
func tableIndexPathFromTreePath(treeIndexPath: IndexPath) -> IndexPath
```
if you need to convert N-depth index path into 2d index path.

On the other hand all <b>optional</b> methods are transparently forwarded to your implementations (if such exists) and indexPath parameter is not changed - it is 2d indexPath.
You can convert it into N-depth treeIndexPath with:
```swift
func treeIndexPathFromTablePath(indexPath: NSIndexPath) -> NSIndexPath
```
method.


## Installation

TreeView is available through [CocoaPods](http://cocoapods.org/pods/treeview). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TreeView'
```

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

![Concept](https://github.com/genkernel/TreeView/raw/master/DemoArt/demo.gif)

TODO
---

<i>
* Test cells moving between sections.
</i>
