//
//  ToolsTableViewController.swift
//  Textor
//
//  Created by Matteo Bart on 7/4/19.
//  Copyright © 2019 Silver Fox. All rights reserved.
//

import UIKit

//ADD
//Find
//Find & Replace
//Convert tabs to spaces
//Convert spaces to tabs
//Convert ‘ to '

class ToolsTableViewController: UITableViewController {
	//@IBOutlet weak var navBar: UINavigationBar!
	
	var availableTools = [
		("Find", UIImage.init(named: "Find")),
		("Find & Replace", UIImage.init(named: "FindNReplace")),
		("Tabs to Spaces", UIImage.init(named: "Tabs2Spaces")),
		("Spaces to Tabs", UIImage.init(named: "Spaces2Tabs")),
		("Convert Curlys to Quotes", UIImage.init(named: "Curlys2Quotes")),
		("Choose Language for Syntax", UIImage.init()),
		("Tab Mode/Space Mode", UIImage.init())
		
	]
	
	@IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true) {
			//nothing to do
		}
	}
	override func viewDidLoad() {
        super.viewDidLoad()
		updateTheme()
		self.navigationController?.setNavigationBarHidden(false, animated: false)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateTheme()
	}
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return availableTools.count
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let num = indexPath.item
		if num == 5 {
			let langVC = self.storyboard!.instantiateViewController(withIdentifier: "SyntaxViewController")
			
			self.show(langVC, sender: nil)
		}
	}

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToolCell", for: indexPath) as! ToolTableViewCell
		let index = indexPath.item
		cell.toolImage.image = (availableTools[index]).1
		cell.toolName.text = (availableTools[index]).0
        // Configure the cell...

        return cell
    }
	
	
	func updateTheme() {
		
		let theme = UserDefaultsController.shared.theme
		
		switch theme {
		case .light:
			tableView.backgroundColor = .groupTableViewBackground
				navigationController?.navigationBar.barStyle = .default
			//navBar.barStyle = .default
			tableView.separatorColor = .gray
			
		case .dark:
			tableView.backgroundColor = .darkBackgroundColor
			//navBar.barStyle = .blackTranslucent
			navigationController?.navigationBar.barStyle = .black
			tableView.separatorColor = UIColor(white: 0.2, alpha: 1)
			
		}
		
		for cell in tableView.visibleCells {
			updateTheme(for: cell)
		}
		
	}
	
	
	func updateTheme(for cell: UITableViewCell) {
		
		let theme = UserDefaultsController.shared.theme
		
		switch theme {
		case .light:
			cell.backgroundColor = .white
			
			for label in cell.subviewLabels() {
				label.textColor = .black
				label.highlightedTextColor = .white
			}
			
		case .dark:
			cell.backgroundColor = UIColor(white: 0.07, alpha: 1)
			
			for label in cell.subviewLabels() {
				label.textColor = .white
				label.highlightedTextColor = .black
			}
			
		}
		
	}



    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
