//
//  HabitsUITests.swift
//  HabitsUITests
//
//  Created by Michael Forrest on 14/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import XCTest

class HabitsUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
    }
    func pathsForStore(name:String)->String{
        return ["sqlite", "sqlite-shm", "sqlite-wal"].map { type in
            return NSBundle(forClass: HabitsUITests.self).pathForResource(name, ofType: type)!
            }.joinWithSeparator(";")
    }
    func pathsForStores(names:[String])->String{
        return names.map { name in
            return self.pathsForStore(name)
            }.joinWithSeparator(";")
    }
    func testOnlyOneStoreFound(){
        let app = XCUIApplication()
        app.launchEnvironment = [
            "RemoveGroupStoreAtStartup": "YES",
            "TestingStorePaths": pathsForStore("HabitsStoreSecondForTesting")
        ]
        app.launch()
        var habitsListTable = app.tables["Habits List"]
        habitsListTable.otherElements["Checkbox for New Habit Not checked"].tap()
        habitsListTable.otherElements["Checkbox for New Habit Checked"].tap()
        habitsListTable.otherElements["Checkbox for New Habit Broken"].tap()
        
        
        // don't migrate twice
        app.terminate()
        app.launchEnvironment["RemoveGroupStoreAtStartup"] = "NO"
        app.launch()
        habitsListTable = app.tables["Habits List"]
        habitsListTable.otherElements["Checkbox for New Habit Not checked"].tap()
        habitsListTable.otherElements["Checkbox for New Habit Checked"].tap()
        habitsListTable.otherElements["Checkbox for New Habit Broken"].tap()
    }
    func testMultipleStoresFound(){
        let app = XCUIApplication()
        app.launchEnvironment = [
            "RemoveGroupStoreAtStartup": "YES",
            "TestingStorePaths": pathsForStores([
                "HabitsStoreSecondForTesting",
                "HabitsStoreThirdForTesting",
                "HabitsStoreFourthForTesting"
                ])
        ]
        app.launch()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["12 habits, used 4 months ago"].tap()
        tablesQuery.staticTexts["12 habits, used 9 days ago"].tap()
        app.navigationBars["Habits.MigrateFrom_iCloudTableView"].buttons["Continue"].tap()
        app.tables["Habits List"].otherElements["Checkbox for Sing for fun Not checked"].tap()
        
        // don't migrate twice
        app.terminate()
        app.launchEnvironment["RemoveGroupStoreAtStartup"] = "NO"
        app.launch()
        
        let habitsListTable = XCUIApplication().tables["Habits List"]
        habitsListTable.otherElements["Checkbox for Sing for fun Checked"].tap()
        habitsListTable.otherElements["Checkbox for Sing for fun Broken"].tap()
        
    }
}
