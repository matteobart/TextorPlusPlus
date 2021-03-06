//
//  FontPickerViewController.swift
//  Textor
//
//  Created by Simon Andersson on 25/03/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

class FontPickerViewController: UITableViewController {

	let searchController: UISearchController = {
		let searchController = UISearchController(searchResultsController: nil)
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search Fonts"
		return searchController
	}()
	
	let fonts: [String] = {
		var allFonts = [String]()
		let fontFamilys = UIFont.familyNames
		for fontFamily in fontFamilys {
			allFonts += UIFont.fontNames(forFamilyName: fontFamily)
		}
		var ret = allFonts.sorted()
		//have all the fonts sorted
		
		//add their currently selected font first
		let add = UserDefaultsController.shared.font
		ret = ret.filter {$0 != add && $0 != "Menlo-Regular"}
		ret.insert(add, at: 0)
		
		//as well as the default font
		if add != "Menlo-Regular" {
			ret.insert("Menlo-Regular", at: 1)
		}
		
		return ret
	}()
	var filteredFonts = [String]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Fonts"
		
		self.searchController.searchResultsUpdater = self
		self.navigationItem.searchController = searchController
		self.navigationItem.hidesSearchBarWhenScrolling = false
		self.definesPresentationContext = true
    }
	
	func searchFonts(searchText: String) {
		
		filteredFonts = fonts.filter({ $0.lowercased().contains(searchText.lowercased()) })
		
		tableView.reloadData()
	}
	
	func isSearching() -> Bool {
		let isSearchBarEmpty = searchController.searchBar.text?.isEmpty ?? true
		return searchController.isActive && !isSearchBarEmpty
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		let currentFont = UserDefaultsController.shared.font
		if cell.textLabel?.text == currentFont {
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
		tableView.reloadRows(at: [indexPath], with: .automatic)
				
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isSearching() {
			return filteredFonts.count
		}
		
		return fonts.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		var fontName: String
		if isSearching() {
			fontName = filteredFonts[indexPath.row]
		} else {
			fontName = fonts[indexPath.row]
		}
		
		cell.textLabel?.text = fontName
		cell.textLabel?.font = UIFont(name: fontName, size: 16)
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let cell = tableView.cellForRow(at: indexPath)
		if let fontName = cell?.textLabel?.text {
			UserDefaultsController.shared.font = fontName
		}
		
		self.navigationController?.popViewController(animated: true)
	}
}

extension FontPickerViewController: UISearchResultsUpdating {
	
	func updateSearchResults(for searchController: UISearchController) {
		if let searchText = searchController.searchBar.text {
			searchFonts(searchText: searchText)
		}
	}
}
