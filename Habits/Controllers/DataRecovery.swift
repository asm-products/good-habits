//
//  DataRecovery.swift
//  Habits
//
//  Created by Michael Forrest on 06/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import UIKit
import HabitsCommon

@objc class DataRecovery: NSObject{
    var clients = [CoreDataClient]()
    var selectedStoreIndex = 0
    override init(){
        super.init()
        prepareForTestingIfNecessary()
        globClients()
        determineMostLikelyClient()
    }
    var isNotRequired:Bool{
        return clients.count == 0 || groupStoreExists
    }
    var groupStoreExists:Bool{
        let url = CoreDataClient.groupStoreURL()
        print("Group Store URL = \(url?.path)")
        if let path = url?.path{
            return FileManager.default.fileExists(atPath: path)
        }else{
            return false
        }
    }
    var hasOnlyOneOption:Bool{
        return clients.count == 1
    }
    fileprivate func globClients(){
        let url = URL(fileURLWithPath: documentsPath as String)
        let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [URLResourceKey.isDirectoryKey], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles, errorHandler: nil)!
        for file in enumerator{
            if let url = file as? URL{
                if url.lastPathComponent.hasSuffix("sqlite"){
                    let client = CoreDataClient(readOnlyStore: url)
                    print("found a Sqlite file at \(url) client \(client)")
                    let count = client?.allHabits().count
                    if count! > 0 {
                        clients.append(client!)
                    }
                }
            }
        }
    }
    
    fileprivate func determineMostLikelyClient(){
        var newestDate = Date(timeIntervalSince1970: 0)
        var mostHabits = 0
        for (index,client) in clients.enumerated(){
            let date = client.lastUsedDate()
            let count = client.allHabits().count
            if (date?.timeIntervalSince1970)! > newestDate.timeIntervalSince1970{
                newestDate = date!
                if mostHabits <= count{
                    selectedStoreIndex = index
                    mostHabits = count
                }
            }
            
        }
    }
    func migrateSelectedStoreToSharedContainer(_ completion:@escaping ()->Void){
        let client = clients[selectedStoreIndex]
        client.migrate {
            completion()
            self.cleanUpIfBeingTested()
        }
    }
    func migrationIgnored(){
        self.cleanUpIfBeingTested()
    }
    // MARK: - Utility
    var documentsPath: NSString{
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    }
    // MARK: - Testing
    // not ideal to put this in here but I can't see a way to bootstrap data into UI tests from the test host
    fileprivate var testingDataSources:[TestingDataSource]?
    fileprivate func prepareForTestingIfNecessary(){
        let dict = ProcessInfo.processInfo.environment
        if let removeGroupStoreAtStartup = dict["RemoveGroupStoreAtStartup"] , removeGroupStoreAtStartup == "YES"{
            let url = CoreDataClient.groupStoreURL()
            do{
                try FileManager.default.removeItem(at: url!)
                print("Deleted group store from url \(url)")
            }catch{
                print("Couldn't delete group store from \(url)!")
            }
            
        }
        
        let pathsString = dict["TestingStorePaths"]
        if let sourcePaths = pathsString?.components(separatedBy: ";"){
            self.testingDataSources = sourcePaths.map { sourcePath in
                let fileName = URL(string:sourcePath)!.lastPathComponent
                let destPath = self.documentsPath.appendingPathComponent(fileName)
                let operation = TestingDataSource(source: sourcePath, dest: destPath)
                operation.copySourceToDest()
                return operation
            }
        }
    }
    fileprivate func cleanUpIfBeingTested(){
        if let stores = testingDataSources{
            for store in stores{
                store.removeDest()
            }
        }
    }
}

private class TestingDataSource{
    var sourcePath:String
    var destPath:String
    init(source:String, dest:String){
        self.sourcePath = source
        self.destPath = dest
    }
    func copySourceToDest(){
        print("Copying \(sourcePath) to \(destPath)")
        try? FileManager.default.copyItem(atPath: sourcePath, toPath: destPath)
    }
    func removeDest(){
        print("Remove file \(destPath)")
        try! FileManager.default.removeItem(atPath: destPath)
    }
}


