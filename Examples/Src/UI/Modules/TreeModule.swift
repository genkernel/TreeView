//
//  TreeModule.swift
//  TreeViewExample
//
//  Created by Anthony on 8/21/18.
//  Copyright © 2018 ReImpl. All rights reserved.
//

import Foundation
import TreeView

@objc
protocol TreeModule: TreeTableDataSource, UITableViewDelegate {
	var name: String { get }
	
	func registerCustomCells(with tableView: UITableView)
}
