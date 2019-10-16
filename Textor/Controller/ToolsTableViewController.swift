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
	
	@IBOutlet weak var spacesSlider: UISlider!
	@IBOutlet weak var currentLanguage: UILabel!
	@IBOutlet weak var spacesLabel: UILabel!
	var numberOfSections: Int = 1
	var completeFilename: String? //set in the segue inside of DocumentViewController
	var documentVC: DocumentViewController?
	
	@IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true) {
			//nothing to do
		}
	}
	
	@IBAction func spacesSliderChanged(_ sender: UISlider) {
		sender.value = sender.value.rounded()
		if completeFilename != nil {
			setSpacePreference(completeFilename: completeFilename!, pref: Int(sender.value))
		}
		let val = spacesSlider.value
		if val > 0 {
			spacesLabel.text = "Tab Size: \(Int(val.rounded())) Spaces"
		} else {
			spacesLabel.text = "Tab Spacing"
		}
	}
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		if UserDefaultsController.shared.isCodingMode {
			numberOfSections = 2 //show the other section
		}
		updateTheme()
		
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateTheme()
		
		
		//set current label text
		var labelText = "Syntax: "
		if completeFilename != nil {
			labelText += getSyntaxPreferences(completeFilename: completeFilename!) ?? ""
		}
		currentLanguage.text = labelText
		
		//set the spaces information
		if completeFilename != nil {
			spacesSlider.value = Float(getSpacePreferences(completeFilename: completeFilename!))
			
		}
		let val = spacesSlider.value
		if val > 0 {
			spacesLabel.text = "Tab Size: \(Int(val.rounded())) Spaces"
		} else {
			spacesLabel.text = "Tab Spacing"
		}
		
		
	}
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return numberOfSections
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		switch (indexPath.section, indexPath.item) {
		case (0, 0): //Find
			documentVC?.activateFind()
			self.dismiss(animated: true, completion: nil)
		case (0, 1): //Find & Replace
			//1. Create the alert controller.
			let alert = UIAlertController(title: "Replace", message: "Specify what text you should replace", preferredStyle: .alert)
			
			//2. Add the text field. You can configure it however you need.
			alert.addTextField { (textField) in
				textField.placeholder = "this"
				
			}
			
			alert.addTextField { (textField) in
				textField.placeholder = "with that"
			}
			
			
			// 3. Grab the value from the text field, and print it when the user clicks OK.
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
				let textField1 = alert?.textFields![0] // Force unwrapping because we know it exists.
				let textField2 = alert?.textFields![1]
				if textField1!.text != nil && textField1!.text! != "" && textField2!.text != nil && textField2!.text! != "" {
					self.documentVC?.replace(this: textField1!.text!, withThat: textField2!.text!)
				}
				
			}))
			
			alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

			
			// 4. Present the alert.
			self.present(alert, animated: true, completion: nil)
		case (0, 2): //Document Statistics
			let statsVC = self.storyboard!.instantiateViewController(withIdentifier: "StatsViewController") as! StatisticsViewController
			statsVC.text = documentVC!.textView.text
			self.show(statsVC, sender: nil)
		case (1, 0): //Current Language
			let langVC = self.storyboard!.instantiateViewController(withIdentifier: "SyntaxViewController") as! SytanxTableViewController
			langVC.completeFilename = completeFilename
			self.show(langVC, sender: nil)
		case (1, 1): //spacing
			() //do nothing
		case (1, 2): //convert tabs to spaces
			documentVC?.switchToSpaces(numOfSpaces: 4)
			self.dismiss(animated: true, completion: nil)
		case (1, 3): //convert spaces to tabs
			documentVC?.switchToTabs()
			self.dismiss(animated: true, completion: nil)
		case (1, 4): //convert curly to quotes
			documentVC?.removeCurlyQuotes()
			self.dismiss(animated: true, completion: nil)
		case (1, 5): //remove trailing white spaces
			documentVC?.removeTrailingSpaces()
			self.dismiss(animated: true, completion: nil)
		default:
			() //do nothing
		}
	}

	/*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToolCell", for: indexPath) as! ToolTableViewCell
		let index = indexPath.item
		cell.toolImage.image = (availableTools[index]).1
		cell.toolName.text = (availableTools[index]).0
        // Configure the cell...

        return cell
    }*/
	
	//THEME
	func updateTheme() {
		navigationController?.navigationBar.tintColor = .appTintColor
		for cell in tableView.visibleCells {
			updateTheme(for: cell)
		}
		
	}
	
	
	func updateTheme(for cell: UITableViewCell) {

		for subview in cell.deepSubviews() {
			if let view = subview as? UIImageView {
				view.tintColor = .appTintColor
			}
		}
		
	}
	
	//END
	
	
	

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
