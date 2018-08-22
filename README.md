
**TreeView is iOS single-class component written in ObjC that enables cell + subcells support for UITableView-s.**

- Project status
- Examples
- Documentation


Current status
---
TreeView was initially written in 2012 and has been used in multiple projects since then.
Development is finalized, component and its public API is considered stable.

The most convenient way to use it is via CocoaPods:
```ruby
pod 'TreeView'
```
Aletrnativelly you may simply drop **TreeView/TreeTable.h,m** into your project.

Examples
---
Preview on Youtube: http://youtu.be/zS3gQ4pnmBs

You may find demo iOS app with 3 working modules in _'Examples'_ directory:
  - inSwift-4.2
  - fileSystem-asTree
  - plist-allExpanded-byDefault


Documentation
---

In basic MVC scenario ViewController is set as DataSource of UITableView.

TreeView package introduces single new class: TreeTable.
It is designed to sit in between ViewController and UITableView as a DataSource object that knows how to work with subcells via deeper "nested" indexPaths.

TreeTable implements UITableViewDataSource protocol and represents inner subcells with indexPaths of deeper levels. For instance cell at 0-0 indexPath may contain 3 subcells: 0-0-0, 0-0-1, 0-0-2.

In plan MVC example: TreeTable is a "proxy" object that sits between tableView and a viewController, proxies all calls to data source and converts 2d-like indexPaths (0-0, 0-1, ...)  into N-depth indexPaths (0-0, 0-0-1, 0-0-2, 0-1-0-1, ...) to represent subcells.

You usually decide to use TreeTable component when your <b>UITableViewCell</b> wants to contain its own subcells that can be easily expanded or collapsed.<br />

Implementation details
---

TreeTable adds 2 logical states to every cell: <b>expanded</b> and <b>collapsed</b>.

You should expand a cell to reveal its subcells.<br/>

Keeping this in mind helper methods(as UITableView category) were implemented: <br/>
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

On the other hand all <b>optional</b> methods are transparently forwarded to your implementations (if you provide any) and indexPath parameter is not changed - it is 2d indexPath.
You can convert it into N-depth treeIndexPath with:
```swift
func treeIndexPathFromTablePath(indexPath: NSIndexPath) -> NSIndexPath
```
method.


Concept image
---

![Concept](https://github.com/genkernel/TreeView/raw/master/concept.jpg)
