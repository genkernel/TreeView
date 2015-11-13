//
//  ViewController.swift
//  TreeViewExample
//
//  Created by Altukhov Anton on 07.11.15.
//  Copyright © 2015 ReImpl. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	var expandedItems: Dictionary<NSIndexPath, Bool>!
	
	var fm: NSFileManager!
	var rootPath: String!
	var rootItems: NSArray!
	
	@IBOutlet weak var treeView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		expandedItems = [:]
		
		fm = NSFileManager.defaultManager()
		
		rootPath = NSBundle.mainBundle().bundlePath;
		rootItems = try! fm.contentsOfDirectoryAtPath(rootPath)
		
		let identifier = NSStringFromClass(UITableViewCell.self)
		treeView.registerClass(UITableViewCell.self, forCellReuseIdentifier: identifier)
	}
	
	func filePathForIndexPath(ip: NSIndexPath) -> String {
		var path = rootPath;
	
		for i in 1 ..< ip.length {
			let index = ip.indexAtPosition(i)
			
			let items = try! fm.contentsOfDirectoryAtPath(path)
			
			path = (path as NSString).stringByAppendingPathComponent(items[index])
		}
	
		return path;
	}
	
	// MARK: - UITableViewDataSource
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rootItems.count
	}
	
	func tableView(tableView: UITableView, isCellExpanded indexPath: NSIndexPath) -> Bool {
		if let expanded = expandedItems[indexPath] {
			return expanded
		} else {
			return false
		}
	}
	
	func tableView(tableView: UITableView, numberOfSubCellsForCellAtIndexPath indexPath: NSIndexPath) -> Int {
		let filePath = filePathForIndexPath(indexPath)
		
		let paths = try! fm.contentsOfDirectoryAtPath(filePath)
		
		return paths.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let filePath = filePathForIndexPath(indexPath)
		
		let identifier = NSStringFromClass(UITableViewCell.self)
		let cell = tableView.dequeueReusableCellWithIdentifier(identifier)!
		
		cell.indentationLevel = indexPath.length - 1
		
		var isDirectory = ObjCBool(false)
		fm.fileExistsAtPath(filePath, isDirectory: &isDirectory)
		
		cell.accessoryType = isDirectory ? .DisclosureIndicator : .None
		cell.textLabel?.text = (filePath as NSString).lastPathComponent
		
		return cell;
	}
	
	// MARK: - UITableViewDelegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath tableIndexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(tableIndexPath, animated: true)
		
		let treeIndexPath = tableView.treeIndexPathFromTablePath(tableIndexPath)
		
		if tableView.isExpanded(treeIndexPath) {
			expandedItems.removeValueForKey(treeIndexPath)
			
			tableView.collapse(treeIndexPath)
		} else {
			let filePath = filePathForIndexPath(treeIndexPath)
			
			var isDirectory = ObjCBool(false)
			fm.fileExistsAtPath(filePath, isDirectory: &isDirectory)
			
			if isDirectory {
				expandedItems[treeIndexPath] = true
				
				tableView.expand(treeIndexPath)
			}
		}
	}
}

