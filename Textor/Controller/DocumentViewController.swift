//
//  DocumentViewController.swift
//  Textor
//
//  Created by Louis D'hauwe on 31/12/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import UIKit
import StoreKit
import Highlightr
var hasAskedForReview = false

var documentsClosed = 0

class DocumentViewController: UIViewController {

	
	var textView: UITextView!
	var document: Document?
	var tabSize = 0 //0 = tab, else number of spaces
	var standardBar: UIToolbar?
	var syntaxLanguage: String?

    
	//FIND VARIABLES
	//current one the user has selected
	var currentFind = 0
	//to get the number of find matches take the length of findRanges
	var findRanges: [NSRange] = []

	
	private let keyboardObserver = KeyboardObserver()

	let textStorage = CodeAttributedString()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//SET UP HIGHLIGHTR
		//syntax language set up in viewWillAppear
		let layoutManager = NSLayoutManager()
		textStorage.addLayoutManager(layoutManager)
		
		let textContainer = NSTextContainer(size: view.bounds.size)
		layoutManager.addTextContainer(textContainer)
		
		textStorage.highlightDelegate = self
		let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
		textView = UITextView(frame: frame, textContainer: textContainer)


		self.view.addSubview(textView)
		//END
		
        textView.delegate = self
		textView.translatesAutoresizingMaskIntoConstraints = false
        textView.contentMode = .redraw
        textView.alwaysBounceVertical = true

        //CONSTARINTS
		let bSpace = NSLayoutConstraint(item: self.textView!, attribute: .bottom, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
		let tSpace = NSLayoutConstraint(item: self.textView!, attribute: .top, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0)
		let lSpace = NSLayoutConstraint(item: self.textView!, attribute: .left, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .left, multiplier: 1, constant: 0)
		let rSpace = NSLayoutConstraint(item: self.textView!, attribute: .right, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .right, multiplier: 1, constant: 0)
		NSLayoutConstraint.activate([bSpace, tSpace, lSpace, rSpace])
		//END
        
        //SET UP TOOLBAR
		let bar = UIToolbar()
		let tab = UIBarButtonItem(title:"Tab", style: .plain, target: self, action: #selector(tabButtonPressed))
		let undo = UIBarButtonItem(title: "Undo", style: .plain, target: self, action: #selector(undoButtonPressed))
		let redo = UIBarButtonItem(title: "Redo", style: .plain, target: self, action: #selector(redoButtonPressed))
		let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		tab.tintColor = .appTintColor

		if UserDefaultsController.shared.isDarkMode {
			bar.barTintColor = .black
		} else {
			bar.barTintColor = .white
		}
		//need to dot his manually here
        undo.isEnabled = textView.undoManager?.canUndo ?? false
		redo.isEnabled = textView.undoManager?.canRedo ?? false
		
		bar.isTranslucent = true
		bar.items = [tab, space, undo, redo]
		bar.sizeToFit()
		
		standardBar = bar //set the class variable
		
		textView.inputAccessoryView = standardBar
        //END
        
		
		self.navigationController?.view.tintColor = .appTintColor
		self.view.tintColor = .appTintColor
		
		
		updateTheme()

		
		keyboardObserver.observe { [weak self] (state) in //this make sure that the textView resizes on keyboard appearing
			
			guard let textView = self?.textView else {
				return
			}
			
			guard let `self` = self else {
				return
			}
			
			//let rect = textView.convert(state.keyboardFrameEnd, from: nil).intersection(textView.bounds)
			
			UIView.animate(withDuration: state.duration, delay: 0.0, options: state.options, animations: {
				//LEGACY CODE START
				//textView.contentInset.bottom = rect.height - self.view.safeAreaInsets.bottom
				//textView.scrollIndicatorInsets.bottom = rect.height - self.view.safeAreaInsets.bottom
				//END
				
				let x = textView.frame.minX //this is important for taking care of the notch on X
				let y = textView.frame.minY
				if state.type == .didShow {
					let frame = CGRect(x: x, y: y, width: textView.frame.width, height: self.view.frame.height - state.keyboardFrameEnd.height - y)
					textView.frame = frame
				} else if state.type == .didHide {
					let frame = CGRect(x: x, y: y, width: textView.frame.width, height: self.view.frame.height - y)
					textView.frame = frame
				}
			}, completion: nil)
			
		}
		
		textView.text = ""
		
		document?.open(completionHandler: { [weak self] (success) in
			
			guard let `self` = self else {
				return
			}
			
			if success {
				
				self.textView.text = self.document?.text
				
				// Calculate layout for full document, so scrolling is smooth.
				self.textView.layoutManager.ensureLayout(forCharacterRange: NSRange(location: 0, length: self.textView.text.count))
				
				if self.textView.text.isEmpty {
					self.textView.becomeFirstResponder()
				}
				
			} else {
				
				self.showAlert("Error", message: "Document could not be opened.", dismissCallback: {
					self.dismiss(animated: true, completion: nil)
				})
				
			}
			
		})
		
	}
	
	
	override var keyCommands: [UIKeyCommand]? {
		return [
			UIKeyCommand(input: "f", modifierFlags: .command, action: #selector(activateFind)),
			UIKeyCommand(input: "\t", modifierFlags: .shift, action: #selector(untab))
		]
	}
	
	private func updateTheme() {
		
		let fontName = UserDefaultsController.shared.font
		let fontSize = UserDefaultsController.shared.fontSize
		let font = UIFont(name: fontName, size: fontSize)!
		textView.font = font
		textStorage.highlightr.theme.setCodeFont(font)
		if UserDefaultsController.shared.isDarkMode {
			textView.textColor = .white
			textView.backgroundColor = .darkBackgroundColor
			textView.keyboardAppearance = .dark
			textView.indicatorStyle = .white
			navigationController?.navigationBar.barStyle = .blackTranslucent
		} else {
			textView.textColor = .black
			textView.backgroundColor = .white
			textView.keyboardAppearance = .default
		}
		
		self.view.backgroundColor = textView.backgroundColor
		
	}
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		updateTheme()
		if UserDefaultsController.shared.isCodingMode {
			//set up highlighting
			let filename = self.navigationController?.title ?? ""
			if document != nil  {
				//syntax highlighting
				if let lang = getSyntaxPreferences(completeFilename: document!.fileURL.absoluteString){
					if lang == "No Highlighting" {//special case
						syntaxLanguage = nil
					} else {
						syntaxLanguage = lang
					}
				} else {
					syntaxLanguage = fileNameToLanguage(filename)
					setSyntaxPreference(completeFilename: document!.fileURL.absoluteString, pref: syntaxLanguage ?? "No Highlighting") //if no syntax language then default to nil ("No Highlighting")
				}
				//spacing preferences
				tabSize = getSpacePreferences(completeFilename: document!.fileURL.absoluteString)
			} else {
				syntaxLanguage = fileNameToLanguage(filename)
			}
			textStorage.language = syntaxLanguage //this is all going to change
			
			//set up keyboard
			textView.autocapitalizationType = .none
			textView.autocorrectionType = .no
		} else { //no coding mode... no highlighting, autocorrect on
			syntaxLanguage = nil
			textStorage.language = nil
			textView.autocapitalizationType = .sentences
			textView.autocorrectionType = .default
		}
		self.view.layoutIfNeeded()
		self.textView.layoutIfNeeded()
    }
	
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
        //used to ask for review, commented during testing
        /*
		documentsClosed += 1
		if !hasAskedForReview && documentsClosed >= 4 {
			hasAskedForReview = true
			SKStoreReviewController.requestReview()
		}
         */
	}

	@IBAction func shareDocument(_ sender: UIBarButtonItem) {

		guard let url = document?.fileURL else {
			return
		}

		textView.resignFirstResponder()
		
		var activityItems: [Any] = [url]

		if UIPrintInteractionController.isPrintingAvailable {
			
			let printFormatter = UISimpleTextPrintFormatter(text: self.textView.text ?? "")
			let printRenderer = UIPrintPageRenderer()
			printRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
			activityItems.append(printRenderer)
		}

		let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

		activityVC.popoverPresentationController?.barButtonItem = sender

		self.present(activityVC, animated: true, completion: nil)
	}

	@objc func tabButtonPressed() {
		//let spot = textView.selectedRange.upperBound
		var add = ""
		if tabSize == 0 {
			add = "\t"
		} else {
			add = String.init(repeating: " ", count: tabSize)
		}
		textView.replace(textView.selectedTextRange!, withText: add)
	}
	
	//this is triggered with a shift+tab on an external keyboard
	//will go back the first spaces (tab or spaces) in that line
	//order of operations tab -> tabSize # of spaces (if 0 then 4 spaces) -> whatever prefix spaces are left
	@objc func untab(){
		if textView.selectedRange.length == 0 {
			let startingPos = textView.selectedRange.location
			var pos = textView.selectedRange.location
			//if the cursor is between the spaces, not necessarily after
			for char in textView.text.suffix(textView.text.count-startingPos) {
				if char != " " || char != "\t" {
					pos+=1
				} else {
					break
				}
			}
			let text = textView.text!
			var rangeLoc = pos
			var rangeLen = 0
			var searchText = ""
			//get the string for the line
			for char in text.prefix(pos).reversed() {
				if char != "\n" {
					searchText = String(char) + searchText
					rangeLoc-=1
				} else {
					break
				}
			}
			//replace the beginning spaces
			for char in searchText {
				if (char == " ") {
					rangeLen+=1
					if rangeLen == tabSize || (tabSize == 0 && rangeLen == 4) { //found all the needed spaces
						//if for some reason we are in tab mode and there are spaces there, remove 4 of them
						if let range = NSRange(location: rangeLoc, length: rangeLen).toTextRange(textInput: textView) {
							textView.replace(range, withText: "")
						}
						break
					}
				} else if (char == "\t") {
					rangeLen+=1
					if let range = NSRange(location: rangeLoc, length: rangeLen).toTextRange(textInput: textView) {
						textView.replace(range, withText: "")
					}
					break
				} else {
					if let range = NSRange(location: rangeLoc, length: rangeLen).toTextRange(textInput: textView) {
						textView.replace(range, withText: "")
					}
					break
				}
			}
			//put the cursor in a good spot
			let newSelectedRange = NSRange(location: startingPos-rangeLen, length: 0)
			textView.selectedRange = newSelectedRange
			//TODO: When removing the tabs/spaces at the front of the line, it may push you off into the next line
			// instead just keep the cursor at the first position
		}
	}
	
	@objc func undoButtonPressed(button: UIBarButtonItem) {
		textView.undoManager?.undo()
		updateUndoButtons()
	}
	
	@objc func redoButtonPressed(button: UIBarButtonItem) {
		textView.undoManager?.redo()
		updateUndoButtons()
	}
	
	
	func updateUndoButtons() {
		if let bar = textView.inputAccessoryView as? UIToolbar {
			for item in bar.items ?? [] {
				if item.title == "Undo" {
					item.isEnabled = textView.undoManager?.canUndo ?? false
				} else if item.title == "Redo" {
					item.isEnabled = textView.undoManager?.canRedo ?? false
				}
			}
		}
	}
	
	//ADD MORE TO LIST
	func fileNameToLanguage(_ filename: String) -> String? {
		if filename.hasExtension() {
			let ext = filename.getExtension()
			switch ext.lowercased(){
			case "py", "pyc":
				return "python"
			case "java":
				return "java"
			case "cpp":
				return "cpp"
			case "c":
				return "c"
			case "swift":
				return "swift"
			default:
				return nil
				
			}
		} else {
			return nil
		}
	}

	@IBAction func toolsButtonPressed(_ sender: UIBarButtonItem) {
		let toolsVC = self.storyboard!.instantiateViewController(withIdentifier: "ToolsViewController") as! ToolsTableViewController
		toolsVC.completeFilename = document?.fileURL.absoluteString
		toolsVC.documentVC = self
		let navCon = UINavigationController(rootViewController: toolsVC)
		navCon.modalPresentationStyle = .formSheet
		self.present(navCon, animated: true, completion: nil)
	}
	
	
	@IBAction func dismissDocumentViewController() {
		let currentText = self.document?.text ?? ""
		self.document?.text = self.textView.text
		if currentText != self.textView.text {
			self.document?.updateChangeCount(.done)
		}
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
	
	//this function will remove the attributes, and then ask highlightr to rehighlight
	func removeAttributes(){
		//ideally, we can remove attributes like below, and then manually trigger the rehighlight
		//this needs to be here for when no syntax highlighting
		textStorage.removeAttribute(NSAttributedString.Key.backgroundColor, range: NSRange(location: 0, length: textView.text.utf16.count))
		textStorage.removeAttribute(NSAttributedString.Key.foregroundColor, range: NSRange(location: 0, length: textView.text.utf16.count))
		//if statement is needed here so that cursor doesn't move for non-coding mode
		if syntaxLanguage != nil { //only needs to be done if highlightr is on
			textView.text = textView.text //while stupid, this is the only way for us to manually call the highlightr
		}
	}
}

//METHODS FOR TOOLS
//FIND, REPLACE, ETC
extension DocumentViewController {
	//currently only converts 4 spaces -> 1 tab
	func switchToTabs(){
		var text = textView.text
		text = text?.replacingOccurrences(of: String.init(repeating: " ", count: 4), with: "\t")
		textView.text = text
	}
	
	func switchToSpaces(numOfSpaces: Int){
		var text = textView.text
		text = text?.replacingOccurrences(of: "\t", with: String.init(repeating: " ", count: numOfSpaces))
		textView.text = text
	}
	
	func removeCurlyQuotes(){
		var text = textView.text
		text = text?.replacingOccurrences(of: "‘", with: "'").replacingOccurrences(of: "’", with: "'").replacingOccurrences(of: "“", with: "\"").replacingOccurrences(of: "”", with: "\"")
		textView.text = text
	}
	
	func removeTrailingSpaces(){
		let text = textView.text
		var arrText = text?.split(separator: "\n")
		if arrText != nil {
			for lineNumber in 0..<arrText!.count {
				for char in arrText![lineNumber].reversed() {
					if char == " " || char == "\t" {
						arrText![lineNumber] = arrText![lineNumber].prefix(arrText![lineNumber].count-1)
					} else {
						break
					}
				}
				
			}
		}
		var newText = ""
		for line in arrText! {
			newText+=line+"\n"
		}
		textView.text = newText
	}
	
	func replace(this str: String, withThat replacement: String) {
		let text = textView.text
		textView.text = text?.replacingOccurrences(of: str, with: replacement)
	}
	
	@objc func activateFind(){
		let bar = UIToolbar()
		let up = UIBarButtonItem(title: "/\\", style: .plain, target: self, action: #selector(upButtonPressed))
		let down = UIBarButtonItem(title: "\\/", style: .plain, target: self, action: #selector(downButtonPressed))
		let searchField = UISearchBar(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
		searchField.delegate = self
		let search = UIBarButtonItem(customView: searchField)
		let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(searchBarDoneButtonPressed))
		let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		bar.items = [up, down, space, search, done]
		bar.sizeToFit()
		textView.inputAccessoryView = bar
		textView.reloadInputViews()
		textView.becomeFirstResponder()

	}
	
	
	@objc func upButtonPressed(){
        //remove the keyboard for the search bar
		if let bar = textView.inputAccessoryView as? UIToolbar {
			for item in bar.items ?? [] {
				if let searchBar = item.customView as? UISearchBar {
						searchBar.resignFirstResponder()
				}
			}
		}

		if currentFind == 0 {
			currentFind = findRanges.count-1
		} else {
			currentFind-=1
		}
		
		if findRanges != [] {
			textView.selectedRange = findRanges[currentFind]
			textView.setNeedsLayout()
			textView.scrollRangeToVisible(findRanges[currentFind])
		}
	}
	
	@objc func downButtonPressed(){
        //remove the keyboard for the search bar
		if let bar = textView.inputAccessoryView as? UIToolbar {
			for item in bar.items ?? [] {
				if let searchBar = item.customView as? UISearchBar {
					searchBar.resignFirstResponder()
				}
			}
		}
		
		if currentFind == findRanges.count-1 {
			currentFind = 0
		} else {
			currentFind+=1
		}
		if findRanges != [] {
			textView.selectedRange = findRanges[currentFind]
			textView.setNeedsLayout()
			textView.scrollRangeToVisible(findRanges[currentFind])
		}
	}
	
	@objc func searchBarDoneButtonPressed(){
		findRanges = []
		currentFind = 0
		
		//remove the search keyboard
		if let bar = textView.inputAccessoryView as? UIToolbar {
			for item in bar.items ?? [] {
				if let search = item.customView as? UISearchBar {
					search.resignFirstResponder()
				}
			}
		}
		textView.inputAccessoryView = standardBar
		textView.reloadInputViews()
		
		//this will remove the current attributes
		//then ask rehighlightr to highlight
		removeAttributes()
	}
	
	

}

extension DocumentViewController: UISearchBarDelegate {

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		//this will remove the current attributes
		//then ask highlightr to highlight -> will yellow highlight over it
		removeAttributes()
		
		if syntaxLanguage == nil {//we need to call it manually if no syntax highlighting
			didHighlight(NSRange(location: 0, length: textView.text.count), success: false)
		}
	}
	
	//we auto search so no real logic needs to go here
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
	}
	
}

extension DocumentViewController: HighlightDelegate {
	
	//this function essentially gets called whenever text is added or highlighted
	//this is the place to add more color on top of the highlighting
	func didHighlight(_ range: NSRange, success: Bool) {
		//update the buttons here too
		updateUndoButtons()

		//keep the highlighted text highlighted
		//look for a search bar, if there is one then...
 		if let bar = textView.inputAccessoryView as? UIToolbar {
			for item in bar.items ?? [] {
				if let searchBar = item.customView as? UISearchBar {
					
					findRanges = []
					currentFind = 0
					
					let searchString = searchBar.text ?? ""
					let baseString = textView.text ?? ""
					var regex: NSRegularExpression?
					do {
						try regex = NSRegularExpression(pattern: searchString, options: .caseInsensitive)
					} catch {
						regex = nil
					}
					if regex != nil {
						for match in (regex?.matches(in: baseString, options: [], range: NSRange(location: 0, length: baseString.utf16.count)))! {
							var attrs: [NSAttributedString.Key : Any] = [:]
							attrs[NSAttributedString.Key.backgroundColor] = UIColor.yellow
							attrs[NSAttributedString.Key.foregroundColor] = UIColor.black
							textStorage.addAttributes(attrs, range: match.range)
							findRanges.append(match.range)
						}
					}
				}
			}
		}
	}
}

extension DocumentViewController: UITextViewDelegate {
	
    //this function can always use a refactoring
    //given a textView and the spot (position)
	//Get the preceding space/tabs in the line
	func getBeginningSpacing(_ textView: UITextView, spot: Int) -> String {
		
		let text = textView.text!
		var searchText = ""
		for char in text.prefix(spot).reversed() {
			if char != "\n" {
				searchText = String(char) + searchText
			} else {
				break
			}
		}
		var ret = ""
		for char in searchText {
			if char == " " || char == "\t" { //doesn't discriminate between types of spaces
				ret = ret + String(char)
			} else {
				break
			}
		}
		return ret
	}
	
	//this gets called when anything gets called is added to textview
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		//first update the undo/redo button
		updateUndoButtons()
		
		//check what they are typing, to see if you must
		//change it
		if UserDefaultsController.shared.isCodingMode {
			if (text == "") { //so deleting works properly
				return true
			} else if (text == "\n") { //keep tabbing the same
				let spaces = getBeginningSpacing(textView, spot: range.lowerBound)
				textView.replace(range.toTextRange(textInput: textView)!, withText: "\n"+spaces)
				if syntaxLanguage == nil { //when no highlighting the methods won't be called
					removeAttributes()
					didHighlight(NSRange(location: 0, length: textView.text.count), success: false)
				}
				return false
			} else if (text == "\t") {
				//just ignore a regular tab
				tabButtonPressed()
				if syntaxLanguage == nil { //when no highlighting the methods won't be called
					removeAttributes()
					didHighlight(NSRange(location: 0, length: textView.text.count), success: false)
				}
				return false
			} else { //just make sure that there is no curly quotes
				let newText = text.replacingOccurrences(of: "‘", with: "'").replacingOccurrences(of: "’", with: "'").replacingOccurrences(of: "“", with: "\"").replacingOccurrences(of: "”", with: "\"")
				textView.replace(range.toTextRange(textInput: textView)!, withText: newText)
				if syntaxLanguage == nil { //when no highlighting the methods won't be called
					removeAttributes()
					didHighlight(NSRange(location: 0, length: textView.text.count), success: false)
				}
				return false
			}
		}
		return true
	}
	
	//this is only used for non-coding mode, to make sure that the find words get highlighted
	//this method is only called when the above method (textView willChangeText)returns true
	func textViewDidChange(_ textView: UITextView) {
		if !UserDefaultsController.shared.isCodingMode {
			removeAttributes()
			didHighlight(NSRange(location: 0, length: textView.text.count), success: false)
		}
		
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		let currentText = self.document?.text ?? ""
		self.document?.text = self.textView.text
		if currentText != self.textView.text {
			self.document?.updateChangeCount(.done)
		}

	}
	
}

extension DocumentViewController: StoryboardIdentifiable {
	
	static var storyboardIdentifier: String {
		return "DocumentViewController"
	}
	
}

extension NSRange {
	func toTextRange(textInput:UITextInput) -> UITextRange? {
		if let rangeStart = textInput.position(from: textInput.beginningOfDocument, offset: location),
			let rangeEnd = textInput.position(from: rangeStart, offset: length) {
			return textInput.textRange(from: rangeStart, to: rangeEnd)
		}
		return nil
	}
}
