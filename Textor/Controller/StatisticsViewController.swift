//
//  StatisticsViewController.swift
//  Textor
//
//  Created by Matteo Bart on 8/2/19.
//  Copyright © 2019 Silver Fox. All rights reserved.
//


import UIKit

class StatisticsViewController: UIViewController {
	
	@IBOutlet weak var statisticsLabel: UILabel!
	@IBOutlet weak var linesLabel: UILabel!
	@IBOutlet weak var wordsLabel: UILabel!
	@IBOutlet weak var characterWSpacesLabel: UILabel!
	@IBOutlet weak var characterWoSpacesLabel: UILabel!
	@IBOutlet weak var numLinesLabel: UILabel!
	@IBOutlet weak var numWordsLabel: UILabel!
	@IBOutlet weak var numCharactersWSpacesLabel: UILabel!
	@IBOutlet weak var numCharactersWoSpacesLabel: UILabel!
	@IBOutlet weak var countNoteLabel: UILabel!
	
	var text: String = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//calculate statistics
		var numLines = 0
		let numCharsWSpaces = text.count
		var numCharsWoSpaces = text.count
		for char in text {
			if char == "\n"{
				numLines += 1
				numCharsWoSpaces -= 1
			} else if char == " " {
				numCharsWoSpaces -= 1
			} else if char == "\t" {
				numCharsWoSpaces -= 1
			}
		}
		let comp = text.components(separatedBy: [",", " ", "!",".","?", "\n"]).filter({!$0.isEmpty})
		let numWords = comp.count
		numCharactersWoSpacesLabel.text = numCharsWoSpaces.description
		numCharactersWSpacesLabel.text = numCharsWSpaces.description
		numWordsLabel.text = numWords.description
		numLinesLabel.text = numLines.description
	}
	
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destination.
	// Pass the selected object to the new view controller.
	}
	*/
	
}
