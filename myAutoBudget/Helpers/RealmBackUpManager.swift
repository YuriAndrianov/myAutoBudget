//
//  RealmBackUpManager.swift
//  myAutoBudget
//
//  Created by MacBook on 22.01.2022.
//

import Foundation
import RealmSwift

struct DocumentsDirectory {
    static let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last!
    static let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
}

class RealmBackUpManager {

    // Return true if iCloud is enabled

    func isCloudEnabled() -> Bool {
        if DocumentsDirectory.iCloudDocumentsURL != nil {
            return true
        } else { return false }
    }

    func uploadDatabaseToCloudDrive() {
        guard isCloudEnabled() else { return }

        let fileManager = FileManager.default

        let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents", isDirectory: true)

        let iCloudDocumentToCheckURL = iCloudDocumentsURL?.appendingPathComponent("default.realm", isDirectory: false)

        let realmArchiveURL = iCloudDocumentToCheckURL // containerURL?.appendingPathComponent("MyArchivedRealm.realm")

        if(fileManager.fileExists(atPath: realmArchiveURL?.path ?? "")) {
            do {
                try fileManager.removeItem(at: realmArchiveURL!)
                print("REPLACE")
                let realm = try! Realm()
                try! realm.writeCopy(toFile: realmArchiveURL!)

            } catch {
                print("ERR")
            }
        } else {
            print("Need to store ")
            let realm = try! Realm()
            try! realm.writeCopy(toFile: realmArchiveURL!)
        }
    }

    //    func DownloadDatabaseFromICloud() {
    //        let fileManager = FileManager.default
    //        // Browse your icloud container to find the file you want
    //        if let icloudFolderURL = DocumentsDirectory.iCloudDocumentsURL,
    //            let urls = try? fileManager.contentsOfDirectory(at: icloudFolderURL, includingPropertiesForKeys: nil, options: []) {
    //
    //            // Here select the file url you are interested in (for the exemple we take the first)
    //            if let myURL = urls.first {
    //                // We have our url
    //                var lastPathComponent = myURL.lastPathComponent
    //                if lastPathComponent.contains(".icloud") {
    //                    // Delete the "." which is at the beginning of the file name
    //                    lastPathComponent.removeFirst()
    //                    let folderPath = myURL.deletingLastPathComponent().path
    //                    let downloadedFilePath = folderPath + "/" + lastPathComponent.replacingOccurrences(of: ".icloud", with: "")
    //                    var isDownloaded = false
    //                    while !isDownloaded {
    //                        if fileManager.fileExists(atPath: downloadedFilePath) {
    //                            isDownloaded = true
    //                            print("REALM FILE SUCCESSFULLY DOWNLOADED")
    //                            self.copyFileToLocal()
    //
    //                        }
    //                        else
    //                        {
    //                            // This simple code launch the download
    //                            do {
    //                                try fileManager.startDownloadingUbiquitousItem(at: myURL )
    //                            } catch {
    //                                print("Unexpected error: \(error).")
    //                            }
    //                        }
    //                    }
    //
    //
    //                    // Do what you want with your downloaded file at path contains in variable "downloadedFilePath"
    //                }
    //            }
    //        }
    //    }

    //    func copyFileToLocal() {
    //        if isCloudEnabled() {
    //            deleteFilesInDirectory(url: DocumentsDirectory.localDocumentsURL)
    //            let fileManager = FileManager.default
    //            let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.iCloudDocumentsURL!.path)
    //            while let file = enumerator?.nextObject() as? String {
    //
    //                do {
    //                    try fileManager.copyItem(at: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file), to: DocumentsDirectory.localDocumentsURL.appendingPathComponent(file))
    //
    //                    print("Moved to local dir")
    //
    //                } catch let error as NSError {
    //                    print("Failed to move file to local dir : \(error)")
    //                }
    //            }
    //        }
    //    }

}
