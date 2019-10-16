//
//  SytanxTableViewController.swift
//  Textor
//
//  Created by Matteo Bart on 7/7/19.
//  Copyright © 2019 Silver Fox. All rights reserved.
//

import UIKit
import Highlightr

class SytanxTableViewController: UITableViewController {
	
	var completeFilename: String?
	
	let searchController: UISearchController = {
		let searchController = UISearchController(searchResultsController: nil)
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search Languages"
		return searchController
	}()
	
	lazy var languages: [String] = {
		var ret = Highlightr.init()!.supportedLanguages()
		ret.append("c") //for some reason C is missing
		ret = ret.sorted()
		
		ret.insert("No Highlighting", at: 0) //if this changes! UPDATE IT AS WELL BELOW
		if completeFilename != nil {
			if let add = getSyntaxPreferences(completeFilename: completeFilename!){
				ret = ret.filter {$0 != add}
				ret.insert(add, at: 0)
			}
		}
		return ret
	}()
	
	var filteredLangs = [String]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Languages"
		self.navigationItem.hidesBackButton = false
		self.searchController.searchResultsUpdater = self
		self.navigationItem.hidesSearchBarWhenScrolling = false
		self.navigationItem.searchController = searchController
		self.definesPresentationContext = true
	}

	func searchLanguages(searchText: String) {
		
		filteredLangs = languages.filter({ $0.lowercased().contains(searchText.lowercased()) })
		
		tableView.reloadData()
	}
	
	func isSearching() -> Bool {
		let isSearchBarEmpty = searchController.searchBar.text?.isEmpty ?? true
		return searchController.isActive && !isSearchBarEmpty
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		var currentSyntax = ""
		if completeFilename != nil {
			currentSyntax = getSyntaxPreferences(completeFilename: completeFilename!) ?? ""
		}
		if cell.textLabel?.text == currentSyntax {
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
		tableView.reloadRows(at: [indexPath], with: .automatic)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isSearching() {
			return filteredLangs.count
		}
		
		return languages.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		var syntaxLanguage: String
		if isSearching() {
			syntaxLanguage = filteredLangs[indexPath.row]
		} else {
			syntaxLanguage = languages[indexPath.row]
		}
		
		cell.textLabel?.text = syntaxLanguage
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let cell = tableView.cellForRow(at: indexPath)
		if let syntaxLanguage = cell?.textLabel?.text {
			if completeFilename != nil {
				setSyntaxPreference(completeFilename: completeFilename!, pref: syntaxLanguage)
			}
			
		}
		
		self.navigationController?.popViewController(animated: true)
	}
}

extension SytanxTableViewController: UISearchResultsUpdating {
	
	func updateSearchResults(for searchController: UISearchController) {
		if let searchText = searchController.searchBar.text {
			searchLanguages(searchText: searchText)
		}
	}
}
