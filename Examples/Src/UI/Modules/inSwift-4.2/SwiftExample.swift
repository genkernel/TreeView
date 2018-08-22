//
//  ViewController.swift
//  TreeViewExample
//
//  Created by Anthony on 07.11.15.
//  Copyright © 2015 ReImpl. All rights reserved.
//

import UIKit


final class SwiftExample: NSObject, TreeModule {
	let name: String = "inSwift-4.2"
	
	override init() {
		expandedItems = [:]
		rootItems = try! fm.contentsOfDirectory(atPath: rootPath)
		
		super.init()
	}
	
	func registerCustomCells(with tableView: UITableView) {
		let identifier = NSStringFromClass(UITableViewCell.self)
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
	}
	
	// MARK: - TreeTableDataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rootItems.count
	}
	
	func tableView(_ tableView: UITableView, isCellExpanded indexPath: IndexPath) -> Bool {
		if let expanded = expandedItems[indexPath] {
			return expanded
		} else {
			return false
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfSubCellsForCellAt treeIndexPath: IndexPath) -> UInt {
		let filePath = self.filePath(fromTreeIndexPath: treeIndexPath)
		
		return UInt((try! fm.contentsOfDirectory(atPath: filePath)).count)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt treeIndexPath: IndexPath) -> UITableViewCell {
		let tableIndexPath = tableView.tableIndexPath(fromTreePath: treeIndexPath)
		
		let identifier = NSStringFromClass(UITableViewCell.self)
		let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: tableIndexPath)
		
		cell.indentationLevel = treeIndexPath.count - 1
		
		let filePath = self.filePath(fromTreeIndexPath: treeIndexPath)
		
		var isDirectory = ObjCBool(false)
		fm.fileExists(atPath: filePath, isDirectory: &isDirectory)
		
		cell.accessoryType = isDirectory.boolValue ? .disclosureIndicator : .none
		cell.textLabel?.text = (filePath as NSString).lastPathComponent
		
		return cell;
	}
	
	// MARK: - UITableViewDelegate
	
	func tableView(_ tableView: UITableView, didSelectRowAt tableIndexPath: IndexPath) {
		tableView.deselectRow(at: tableIndexPath, animated: true)
		
		let treeIndexPath = tableView.treeIndexPath(fromTablePath: tableIndexPath)
		
		if tableView.isExpanded(treeIndexPath) {
			let index = expandedItems.index(forKey: treeIndexPath)!
			expandedItems.remove(at: index)
			
			tableView.collapse(treeIndexPath)
		} else {
			let filePath = self.filePath(fromTreeIndexPath: treeIndexPath)
			
			var isDirectory = ObjCBool(false)
			fm.fileExists(atPath: filePath, isDirectory: &isDirectory)
			
			if isDirectory.boolValue {
				expandedItems[treeIndexPath] = true
				
				tableView.expand(treeIndexPath)
			}
		}
	}
	
	// MARK: - Internal
	
	private let fm = FileManager.default
	private var rootPath = Bundle.main.bundlePath
	
	private var rootItems: [String]!
	private var expandedItems: [IndexPath: Bool] = [:]
	
	private func filePath(fromTreeIndexPath ip: IndexPath) -> String {
		var path = rootPath
		
		for i in 1 ..< ip.count {
			let items = try! fm.contentsOfDirectory(atPath: path)
			
			path = (path as NSString).appendingPathComponent(items[ip[i]])
		}
		
		return path
	}
}
