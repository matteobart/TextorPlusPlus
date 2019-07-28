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
		print(sender.value)
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
			print("Find")
			documentVC?.activateFind()
			self.dismiss(animated: true, completion: nil)
		case (0, 1): //Find & Replace
			print("FindN")
		case (1, 0): //Current Language
			let langVC = self.storyboard!.instantiateViewController(withIdentifier: "SyntaxViewController") as! SytanxTableViewController
			langVC.completeFilename = completeFilename
			self.show(langVC, sender: nil)
		case (1, 1): //spacing
			print("Spacing cell tapped")
			//do nothing
		case (1, 2): //convert tabs to spaces
			documentVC?.switchToSpaces(numOfSpaces: 4)
			self.dismiss(animated: true, completion: nil)
		case (1, 3): //convert spaces to tabs
			documentVC?.switchToTabs()
			self.dismiss(animated: true, completion: nil)
		case (1, 4): //conver curly to quotes
			documentVC?.removeCurlyQuotes()
			self.dismiss(animated: true, completion: nil)
		default:
			print("No selection")
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
		
		let theme = UserDefaultsController.shared.theme
		
		switch theme {
		case .light:
			tableView.backgroundColor = .groupTableViewBackground
				navigationController?.navigationBar.barStyle = .default
			//navBar.barStyle = .default
			tableView.separatorColor = .gray
			
			
		case .dark:
			
			tableView.backgroundColor = .darkBackgroundColor
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
	
	//MORE THEME SETTINGS (DARK MODE SETTINGS)
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let header = view as? UITableViewHeaderFooterView {
			if UserDefaultsController.shared.isDarkMode {
				header.textLabel?.textColor = .white
				
			} else {
				header.textLabel?.textColor = .black
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
