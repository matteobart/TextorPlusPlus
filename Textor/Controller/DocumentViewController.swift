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

	
	@IBOutlet weak var placeholderView: UIView!
	
	
	var textView: UITextView!
	var document: Document?
	var tabSize = 0 //0 = tab, else number of spaces

	

	
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
			
			textView = UITextView(frame: self.placeholderView.bounds, textContainer: textContainer)
			
		} else {
			
			textView = UITextView(frame: self.placeholderView.bounds)
		}
		self.placeholderView.addSubview(textView)

		textView.delegate = self
		//END
		
		let bar = UIToolbar()
		let tab = UIBarButtonItem(title:"Tab", style: .plain, target: self, action: #selector(tabButtonPressed))
		tab.tintColor = .appTintColor

		if UserDefaultsController.shared.isDarkMode {
			bar.barTintColor = .black
		} else {
			bar.barTintColor = .white
		}
		bar.isTranslucent = true
		bar.items = [tab]
		bar.sizeToFit()

		textView.inputAccessoryView = bar
		
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
				
				textView.contentInset.bottom = rect.height - self.view.safeAreaInsets.bottom
				textView.scrollIndicatorInsets.bottom = rect.height - self.view.safeAreaInsets.bottom
				
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
			var syntaxLanguage: String?
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
			textStorage.language = syntaxLanguage
			
			//set up keyboard
			textView.autocapitalizationType = .none
			textView.autocorrectionType = .no
		} else {
			textView.autocapitalizationType = .sentences
			textView.autocorrectionType = .default
		}
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
//		let storyboard = UIStoryboard(name: "Main_iPhone", bundle: nil)
//		let vc = storyboard.instantiateViewControllerWithIdentifier("POIListViewController") as! UIViewController
//
		let toolsVC = self.storyboard!.instantiateViewController(withIdentifier: "ToolsViewController") as! ToolsTableViewController
		toolsVC.completeFilename = document?.fileURL.absoluteString
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
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		
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
				return false
			} else if (text == "\t") {
				//just ignore a regular tab
				tabButtonPressed()
				return false
			} else { //just make sure that there is no curly quotes
				let newText = text.replacingOccurrences(of: "‘", with: "'").replacingOccurrences(of: "’", with: "'").replacingOccurrences(of: "“", with: "\"").replacingOccurrences(of: "”", with: "\"")
				addText(to: textView, add: newText, inPosition: range.upperBound)
				//put cursor where it should be
				let cursorPosition = range.upperBound + newText.count
				let textPosition = textView.position(from: textView.beginningOfDocument, offset: cursorPosition)
				textView.selectedTextRange = textView.textRange(from: textPosition!, to: textPosition!)
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
