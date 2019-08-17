//
//  DocumentManager.swift
//  Textor
//
//  Created by Louis D'hauwe on 31/12/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

extension String {

	/// Name without extension
	func getFileName() -> String {
		let split = self.split(separator: ".", maxSplits: 1)
		print (split.first!.description)
		return split.first?.description ?? ""
		
	}
	
	func hasExtension()->Bool {
		return self.contains(".") && self.suffix(1) != "."
	}
	
	func getExtension()->String {
		let split = self.split(separator: ".", maxSplits: 1)
		return split.last?.description ?? ""
	}

}

class DocumentManager {

	static let shared = DocumentManager(fileManager: .default)

	let fileManager: FileManager

	//when not specified defaults to txt file
	private var defaultFileExtension: String {
		return "txt"
	}

	private init(fileManager: FileManager) {

		self.fileManager = fileManager
		
		let documentsFolder = activeDocumentsFolderURL

		if !fileManager.fileExists(atPath: documentsFolder.path) {
			try? fileManager.createDirectory(at: documentsFolder, withIntermediateDirectories: true, attributes: nil)
		}

	}
	
	//CHANGE?
	private let ICLOUD_IDENTIFIER = "iCloud.com.silverfox.plaintextedit"

	private var localDocumentsURL: URL {
		return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
	}

	private var cachesURL: URL {
		return URL(fileURLWithPath: NSTemporaryDirectory())
//		return fileManager.urls(for: .cachesDirectory, in: .userDomainMask).last!
	}

	private var cloudDocumentsURL: URL? {

		guard iCloudAvailable else {
			return nil
		}

		let ubiquityContainerURL = fileManager.url(forUbiquityContainerIdentifier: ICLOUD_IDENTIFIER)

		return ubiquityContainerURL?.appendingPathComponent("Documents")
	}

	private var activeDocumentsFolderURL: URL { 
		if let cloudDocumentsURL = cloudDocumentsURL {
			return cloudDocumentsURL
		} else {
			return localDocumentsURL
		}
	}

	var iCloudAvailable: Bool {
		return fileManager.ubiquityIdentityToken != nil
	}

	func cacheUrl(for fileName: String) -> URL? {

		let docURL = fileName.hasExtension() ?
		cachesURL.appendingPathComponent(fileName.getFileName()).appendingPathExtension(fileName.getExtension()):
		cachesURL.appendingPathComponent(fileName).appendingPathExtension(defaultFileExtension) //while files made in Textor++ will have a file extension, can not be sure of iCloud Drive
		

		return docURL
	}

	func url(for fileName: String) -> URL? {

		let baseURL = activeDocumentsFolderURL

		let docURL = fileName.hasExtension() ?
			baseURL.appendingPathComponent(fileName.getFileName()).appendingPathExtension(fileName.getExtension()):
			baseURL.appendingPathComponent(fileName).appendingPathExtension(defaultFileExtension)
		
		return docURL
	}

}

extension DocumentManager {

	/// - Parameter proposedName: Must have an extension
	
	func availableFileName(forProposedName proposedName: String) -> String {
		
		let files = fileList()//.map { $0.getFileName().lowercased() }

		var availableFileName = proposedName
		
		var i = 0
		while files.contains(availableFileName) {

			i += 1
			availableFileName = proposedName.getFileName() + String(i)
			
			if proposedName.hasExtension(){
				availableFileName += "." + proposedName.getExtension()
			}

		}

		return availableFileName
	}

	/// File list, including file extensions.
	private func fileList() -> [String] {

		let documentsURL = activeDocumentsFolderURL

		guard let contents = try? self.fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles]) else {
			return []
		}
		let files = contents.map({ $0.lastPathComponent })

		return files
	}

}
