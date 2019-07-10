//
//  UserDefaultsController.swift
//  Textor
//
//  Created by Louis D'hauwe on 13/03/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import CoreGraphics

class UserDefaultsController {

	static let shared = UserDefaultsController(userDefaults: .standard)

	private var userDefaults: UserDefaults

	private init(userDefaults: UserDefaults) {
		self.userDefaults = userDefaults
	}

	var theme: Theme {
		get {
			guard let rawValue = userDefaults.object(forKey: "selectedTheme") as? String else {
				return .light
			}

			return Theme(rawValue: rawValue) ?? .light
		}
		set {
			userDefaults.set(newValue.rawValue, forKey: "selectedTheme")
		}
	}

	var isCodingMode: Bool {
		get {
			return userDefaults.bool(forKey: "codeMode")
		}
		
		set {
			userDefaults.set(newValue, forKey: "codeMode")
		}
	}
	
	var isDarkMode: Bool {
		get {
			return theme == .dark
		}
		set {
			theme = newValue ? .dark : .light
		}
	}

	var fontSize: CGFloat {
		get {
			return userDefaults.object(forKey: "fontSize") as? CGFloat ?? 17.0
		}
		set {
			userDefaults.set(newValue, forKey: "fontSize")
		}
	}
	
	var font: String {
		get {
			return userDefaults.string(forKey: "font") ?? "Menlo-Regular"
		}
		set {
			userDefaults.set(newValue, forKey: "font")
		}
	}

	var isFastlane: Bool {
		return userDefaults.bool(forKey: "FASTLANE_SNAPSHOT") == true
	}

	//completeFileName -> syntax highlighting
	//0 means prefers tabs
	//positive number of spaces in a tab
	var syntaxPreferences: [String:String] {
		get {
			return (userDefaults.dictionary(forKey: "languagePreferences") as? [String : String]) ?? [:]
		}
		set {
			userDefaults.set(newValue, forKey: "languagePreferences")
		}
	}
	//completeFileName -> spacePreferences
	//0 means prefers tabs
	//positive number of spaces in a tab
	var spacePreferences: [String: Int] {
		get {
			return userDefaults.dictionary(forKey: "spacePreferences") as? [String : Int] ?? [:]
		}
		set {
			userDefaults.set(newValue, forKey: "spacePreferences")
		}
	}

}

//USER DEFAULT METHODS
func setSpacePreference(completeFilename: String, pref: Int) {
	var dict = UserDefaultsController.shared.spacePreferences
	dict[completeFilename] = pref
	UserDefaultsController.shared.spacePreferences = dict
	
}

func getSpacePreferences(completeFilename: String)->Int {
	let dict = UserDefaultsController.shared.spacePreferences
	return dict[completeFilename] ?? 0
}

//pref is either the language or the value "No Highlighting", which means dont highlight (textStorage.langauge = nil)
func setSyntaxPreference(completeFilename: String, pref: String) {
	var dict = UserDefaultsController.shared.syntaxPreferences
	dict[completeFilename] = pref
	UserDefaultsController.shared.syntaxPreferences = dict
}

//if this returns nil -> there is no preference
//if this returns "No Highlighting" -> Don't highlight anyhting (textStorage.language = nil)
//else it will return the langauge is a format that the textStorage should accept
func getSyntaxPreferences(completeFilename: String)->String? {
	let dict = UserDefaultsController.shared.syntaxPreferences
	return dict[completeFilename] ?? nil
}

