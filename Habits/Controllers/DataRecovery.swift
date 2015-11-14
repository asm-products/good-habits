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
        print("Group Store URL = \(url.path)")
        if let path = url.path{
            return NSFileManager.defaultManager().fileExistsAtPath(path)
        }else{
            return false
        }
    }
    var hasOnlyOneOption:Bool{
        return clients.count == 1
    }
    private func globClients(){
        let url = NSURL(fileURLWithPath: documentsPath as String)
        let enumerator = NSFileManager.defaultManager().enumeratorAtURL(url, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: NSDirectoryEnumerationOptions.SkipsHiddenFiles, errorHandler: nil)!
        for file in enumerator{
            if let url = file as? NSURL{
                if url.lastPathComponent!.hasSuffix("sqlite"){
                    let client = CoreDataClient(readOnlyStoreUrl: url)
                    print("found a Sqlite file at \(url) client \(client)")
                    let count = client.allHabits().count
                    if count > 0 {
                        clients.append(client)
                    }
                }
            }
        }
    }
    
    private func determineMostLikelyClient(){
        var newestDate = NSDate(timeIntervalSince1970: 0)
        var mostHabits = 0
        for (index,client) in clients.enumerate(){
            let date = client.lastUsedDate()
            let count = client.allHabits().count
            if date.timeIntervalSince1970 > newestDate.timeIntervalSince1970{
                newestDate = date
                if mostHabits <= count{
                    selectedStoreIndex = index
                    mostHabits = count
                }
            }
            
        }
    }
    func migrateSelectedStoreToSharedContainer(completion:()->Void){
        let client = clients[selectedStoreIndex]
        client.migrateToAppGroupStore {
            completion()
            self.cleanUpIfBeingTested()
        }
    }
    func migrationIgnored(){
        self.cleanUpIfBeingTested()
    }
    // MARK: - Utility
    var documentsPath: NSString{
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    }
    // MARK: - Testing
    // not ideal to put this in here but I can't see a way to bootstrap data into UI tests from the test host
    private var testingDataSources:[TestingDataSource]?
    private func prepareForTestingIfNecessary(){
        let dict = NSProcessInfo.processInfo().environment
        if let removeGroupStoreAtStartup = dict["RemoveGroupStoreAtStartup"] where removeGroupStoreAtStartup == "YES"{
            let url = CoreDataClient.groupStoreURL()
            do{
                try NSFileManager.defaultManager().removeItemAtURL(url)
                print("Deleted group store from url \(url)")
            }catch{
                print("Couldn't delete group store from \(url)!")
            }
            
        }
        
        let pathsString = dict["TestingStorePaths"]
        if let sourcePaths = pathsString?.componentsSeparatedByString(";"){
            self.testingDataSources = sourcePaths.map { sourcePath in
                let fileName = NSURL(string:sourcePath)!.lastPathComponent
                let destPath = self.documentsPath.stringByAppendingPathComponent(fileName!)
                let operation = TestingDataSource(source: sourcePath, dest: destPath)
                operation.copySourceToDest()
                return operation
            }
        }
    }
    private func cleanUpIfBeingTested(){
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
        try? NSFileManager.defaultManager().copyItemAtPath(sourcePath, toPath: destPath)
    }
    func removeDest(){
        print("Remove file \(destPath)")
        try! NSFileManager.defaultManager().removeItemAtPath(destPath)
    }
}


