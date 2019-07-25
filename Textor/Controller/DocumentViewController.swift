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

	//FIND
	//current one the user has selected
	var currentFind = 0
	//to get the number of find matches take the length
	//of findRanges
	var findRanges: [NSRange] = []

	
	private let keyboardObserver = KeyboardObserver()

	let textStorage = CodeAttributedString()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//print(document?.fileURL.absoluteString)
		//SET UP HIGHLIGHTR
		if UserDefaultsController.shared.isCodingMode {
			//syntax language set up in viewWillAppear
			let layoutManager = NSLayoutManager()
			textStorage.addLayoutManager(layoutManager)
			
			let textContainer = NSTextContainer(size: view.bounds.size)
			layoutManager.addTextContainer(textContainer)
			
			textStorage.highlightDelegate = self
			let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
			textView = UITextView(frame: frame, textContainer: textContainer)
			//textView = UITextView(frame: self.placeholderView.bounds, textContainer: textContainer)
			
		} else {
			let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
			textView = UITextView(frame: frame)
		}
		//self.placeholderView.addSubview(textView)
//		let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height-400)
//		self.textView.frame(forAlignmentRect: frame)
		//let h = self.textView.frame.height - CGFloat(25)
		//let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: h)
		//self.textView.frame = frame
		
	
		
		self.view.addSubview(textView)

		textView.delegate = self
		//END
		
//		NSLayoutConstraint.activate([
//			textView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 400),
//			textView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
//			textView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: 20),
//			textView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 0),
////			textView.topAnchor.constraint(equalTo: self.view.topAnchor),
////			textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
////			textView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 20),
////			textView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
//		])
		
		self.textView!.translatesAutoresizingMaskIntoConstraints = false
		
		// create the constraints with the constant value you want.
		let bSpace = NSLayoutConstraint(item: self.textView!, attribute: .bottom, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
		let tSpace = NSLayoutConstraint(item: self.textView!, attribute: .top, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0)
		let lSpace = NSLayoutConstraint(item: self.textView!, attribute: .left, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .left, multiplier: 1, constant: 0)
		let rSpace = NSLayoutConstraint(item: self.textView!, attribute: .right, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .right, multiplier: 1, constant: 0)
		// activate the constraints
		NSLayoutConstraint.activate([bSpace, tSpace, lSpace, rSpace])
		
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
		redo.isEnabled = textView.undoManager?.canRedo ?? false
		undo.isEnabled = textView.undoManager?.canUndo ?? false
		bar.isTranslucent = true
		bar.items = [tab, space, undo, redo]
		bar.sizeToFit()
		
		standardBar = bar //set the class variable
		
		textView.inputAccessoryView = standardBar
		textView.contentMode = .redraw
		
		self.navigationController?.view.tintColor = .appTintColor
		self.view.tintColor = .appTintColor
		
		updateTheme()

		textView.alwaysBounceVertical = true
		
		keyboardObserver.observe { [weak self] (state) in
			
			guard let textView = self?.textView else {
				return
			}
			
			guard let `self` = self else {
				return
			}
			
			let rect = textView.convert(state.keyboardFrameEnd, from: nil).intersection(textView.bounds)
			
			UIView.animate(withDuration: state.duration, delay: 0.0, options: state.options, animations: {
				//legacy code start
				//textView.contentInset.bottom = rect.height - self.view.safeAreaInsets.bottom
				//textView.scrollIndicatorInsets.bottom = rect.height - self.view.safeAreaInsets.bottom
				//end
				
				//new code- trying to solve hidden find options
				print(state.type)
				print(self.view.frame.height)
				print(rect.height)
				print(state.keyboardFrameEnd.height)
				let x = textView.frame.minX //this is important for taking care of the notch on X
				let y = textView.frame.minY
				//let frame = CGRect(x: 0, y: 0, width: textView.frame.width, height: self.view.frame.height - rect.height)
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
	
	private func updateTheme() {
		
		let font = UserDefaultsController.shared.font
		let fontSize = UserDefaultsController.shared.fontSize
		textView.font = UIFont(name: font, size: fontSize)
		if textView.font != nil {
			textStorage.highlightr.theme.setCodeFont(textView.font!)
		}
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
		} else {
			textView.autocapitalizationType = .sentences
			textView.autocorrectionType = .default
		}
		self.view.layoutIfNeeded()
		self.textView.layoutIfNeeded()
    }
	
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		documentsClosed += 1

		if !hasAskedForReview && documentsClosed >= 4 {
			hasAskedForReview = true
			SKStoreReviewController.requestReview()
		}

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

	@objc func tabButtonPressed () {
		let spot = textView.selectedRange.upperBound
		var add = ""
		if tabSize == 0 {
			add = "\t"
		} else {
			add = String.init(repeating: " ", count: tabSize)
		}
		addText(to: textView, add: add, inPosition: spot)
	}
	
	@objc func undoButtonPressed(button: UIBarButtonItem) {
		textView.undoManager?.undo()
		button.isEnabled = textView.undoManager?.canUndo ?? false
	}
	
	@objc func redoButtonPressed(button: UIBarButtonItem) {
		textView.undoManager?.redo()
		button.isEnabled = textView.undoManager?.canRedo ?? false
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

	@IBAction func moreButtonPressed(_ sender: UIBarButtonItem) {
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
	
}

//functions for the tools to use
//Find, Replace, Etc
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
	
	func find(_ searchFor: String){
		let bar = UIToolbar()
		let up = UIBarButtonItem(title: "/\\", style: .plain, target: self, action: #selector(upButtonPressed))
		let down = UIBarButtonItem(title: "\\/", style: .plain, target: self, action: #selector(downButtonPressed))
		let searchField = UISearchBar(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
		searchField.delegate = self
		let search = UIBarButtonItem(customView: searchField)
		let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonPressed))
		let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		bar.items = [up, down, space, search, done]
		bar.sizeToFit()
		textView.inputAccessoryView = bar
		textView.reloadInputViews()
		textView.becomeFirstResponder()

	}
	
	
	@objc func upButtonPressed(){
		if let bar = textView.inputAccessoryView as? UIToolbar {
			for item in bar.items ?? [] {
				if let searchBar = item.customView as? UISearchBar {
						searchBar.resignFirstResponder()
				}
			}
		}

		currentFind-=1
		if currentFind == -1 {
			currentFind = findRanges.count - 1
		}
		textView.selectedRange = findRanges[currentFind]
		textView.setNeedsLayout()
		textView.scrollRangeToVisible(findRanges[currentFind])
		//textView.scro
	}
	
	@objc func downButtonPressed(){
		
		if let bar = textView.inputAccessoryView as? UIToolbar {
			for item in bar.items ?? [] {
				if let searchBar = item.customView as? UISearchBar {
					searchBar.resignFirstResponder()
				}
			}
		}
		
		currentFind+=1
		if currentFind == findRanges.count {
			currentFind = 0
		}
		textView.selectedRange = findRanges[currentFind]
		textView.setNeedsLayout()
		textView.scrollRangeToVisible(findRanges[currentFind])
		
	}
	
	//CURRENT PROBLEM IS TO FIX SLIGHTLY OFF
	//FIND
	//TYPICALLY A BIT HIGH
	//OR A BIT LOW
	
	@objc func doneButtonPressed(){
		findRanges = []
		currentFind = 0
		
		//remove the find tool bar
		if let bar = textView.inputAccessoryView as? UIToolbar {
			for item in bar.items ?? [] {
				if let search = item.customView as? UISearchBar {
					search.resignFirstResponder()
				}
			}
		}
		textView.inputAccessoryView = standardBar
		textView.reloadInputViews()
		
		
		//may also want to use a similar solution for removing the highlighting
		//with each new key in textfield
		let a = NSMutableAttributedString(attributedString: textView.attributedText)
		a.removeAttribute(NSAttributedString.Key.backgroundColor, range: NSRange(location: 0, length: textView.text.utf16.count))
		a.removeAttribute(NSAttributedString.Key.foregroundColor, range: NSRange(location: 0, length: textView.text.utf16.count))
		textView.attributedText = a
	}
	
	

}

extension DocumentViewController: UISearchBarDelegate {

	//a bit wonky but...
	//when we search, we simply replace the whole view, so that the highlighr is called
	//real highlighting the find words can be found there
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		//let r = NSRange(location: 0, length: textView.text.utf16.count)
		//let t = textView.text ?? ""
		//let r = NSRange(location: 0, length: t.count)
		//textStorage.replaceCharacters(in: r, with: t)
		textView.text = textView.text
		
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
	//this function essentially gets called whenever text is added
	//this is the place to add more color on top of the highlighting
	func didHighlight(_ range: NSRange, success: Bool) {
		
		
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
							//this probably isn't needed
							//can probably use the else for all cases
							if UserDefaultsController.shared.isCodingMode {
								textStorage.addAttributes(attrs, range: match.range)
							} else {
								textView.textStorage.addAttributes(attrs, range: match.range)
							}
							findRanges.append(match.range)
						}
					}
				}
			}
		}
	}
}

extension DocumentViewController: UITextViewDelegate {
	
	//PLEASE FIX, SWIFT WAS GIVING ME SO MUCH CRAP
	//GIVEN A textView and a range, grab the lowerbound of the range
	//Get the preceding space/tabs in the line
	func getBeginningSpacing(_ textView: UITextView, range: NSRange) -> String {
		
		let text = textView.text!
		let findBefore = range.lowerBound
		var searchText = ""
		for char in text.prefix(findBefore).reversed() {
			if char != "\n" {
				searchText = String(char) + searchText
			} else {
				break
			}
		}
		var ret = ""
		for char in searchText {
			if char == " " || char == "\t" {
				ret = ret + String(char)
			} else {
				break
			}
		}
		return ret
	}
	
	func addText(to textView: UITextView, add: String, inPosition: Int) {
		let text = textView.text!
		let textLength = text.count
		textView.text = text.prefix(inPosition) + add + text.suffix(textLength - inPosition)
	}
	

	
	//this gets called when anything gets called is added to textview
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		
		//first update the undo/redo button
		if let bar = textView.inputAccessoryView as? UIToolbar {
			for item in bar.items ?? [] {
				if item.title == "Undo" {
					item.isEnabled = textView.undoManager?.canUndo ?? false
				} else if item.title == "Redo" {
					item.isEnabled = textView.undoManager?.canRedo ?? false
				}
			}
		}
		

		//check what they are typing, to see if you must
		//change it
		if UserDefaultsController.shared.isCodingMode {
			
			if (text == "") { //so deleting works properly
				return true
			} else if (text == "\n") { //keep tabbing the same
				let spaces = getBeginningSpacing(textView, range: range)
				addText(to: textView, add: "\n" + spaces, inPosition: range.upperBound)
				//put cursor where it should be
				let cursorPosition = range.upperBound + 1 + spaces.count
				let textPosition = textView.position(from: textView.beginningOfDocument, offset: cursorPosition)
				textView.selectedTextRange = textView.textRange(from: textPosition!, to: textPosition!)
				//textViewDidChange()
				return false
			} else if (text == "\t") {
				//just ignore a regular tab
				tabButtonPressed()
				let cursorPosition = range.upperBound + (tabSize==0 ? 1 : tabSize)
				let textPosition = textView.position(from: textView.beginningOfDocument, offset: cursorPosition)
				textView.selectedTextRange = textView.textRange(from: textPosition!, to: textPosition!)
				//textViewDidChange()
				return false
			} else { //just make sure that there is no curly quotes
				let newText = text.replacingOccurrences(of: "‘", with: "'").replacingOccurrences(of: "’", with: "'").replacingOccurrences(of: "“", with: "\"").replacingOccurrences(of: "”", with: "\"")
				addText(to: textView, add: newText, inPosition: range.upperBound)
				//put cursor where it should be
				let cursorPosition = range.upperBound + newText.count
				let textPosition = textView.position(from: textView.beginningOfDocument, offset: cursorPosition)
				textView.selectedTextRange = textView.textRange(from: textPosition!, to: textPosition!)
				//textViewDidChange()
				return false
				
			}
		}
		
		
		return true
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
