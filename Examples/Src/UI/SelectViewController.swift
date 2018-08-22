//
//  SelectViewController.swift
//  TreeViewExample
//
//  Created by Anthony on 8/21/18.
//  Copyright © 2018 ReImpl. All rights reserved.
//

import UIKit

final class SelectViewController: UITableViewController {
	
	let modules: [TreeModule] = [
		SwiftExample(),
		PListExample(),
		FileFinderExample()
	]
	
	// Names correspond to constants in Storyboard.
	enum Segue: String {
		case showModuleScreen = "ShowModuleScreen"
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let id = segue.identifier,
			let s = Segue(rawValue: id) else {
				super.prepare(for: segue, sender: sender)
				
				return
		}
		
		switch s {
		case .showModuleScreen:
			let ctrl = segue.destination as! TableViewController
			
			ctrl.treeModule = sender as? TreeModule
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Examples"
	}
	
	// MARK: - UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return modules.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath)
		
		cell.textLabel?.text = modules[indexPath.row].name
		
		return cell
	}
	
	// MARK: - UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let module = modules[indexPath.row]
		let id = Segue.showModuleScreen.rawValue
		
		performSegue(withIdentifier: id, sender: module)
	}
	
}
