//
//  TrendsView.swift
//  Habits
//
//  Created by Michael Forrest on 29/10/2020.
//  Copyright © 2020 Good To Hear. All rights reserved.
//

import SwiftUI
import HabitsCommon
import CoreData

struct ChainPair:Identifiable{
    var id:NSManagedObjectID{
        chain.objectID
    }
    let chain: Chain
    let next: Chain
    let daysBetween: Int
    init(pair: (Chain,Chain)){
        self.chain = pair.0
        self.next = pair.1
        self.daysBetween = abs( Calendar.current.dateComponents([.day], from: chain.lastDateCache, to: next.firstDateCache).day ?? 0)
    }
    
}

struct ChainsView: View {
    @ObservedObject var habit:Habit
    var body: some View{
        let chains = (habit.chains as! Set<Chain>).sorted(by: { $0.firstDateCache < $1.firstDateCache })
        let pairs = zip(chains.dropFirst(),chains).map{ChainPair(pair: $0)}
        
        return HStack {
            ForEach(pairs){ pair in
                Group {
                    Capsule()
                        .fill(Color(habit.color))
                        .frame(width: 8 * CGFloat(truncating: pair.chain.daysCountCache), height: 8)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: CGFloat(pair.daysBetween) * 8, height: 8 )
                    
                }
            }
        }
    }
}

struct TrendsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: Habit.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Habit.order, ascending: true)
        ]) var habits: FetchedResults<Habit>
    
    var body: some View {
        
        ScrollView(.horizontal){
            VStack(alignment: .leading){
                ForEach(habits, id: \.identifier){ (habit: Habit) in
                    ChainsView(habit: habit)
                }
            }
        }.overlay(VStack{
            ForEach(habits, id: \.identifier){ habit in
                Text(habit.title)
            }
        }, alignment: .trailing)
    }
}

struct TrendsView_Previews: PreviewProvider {
    static var previews: some View {
        let client = CoreDataClient.default()!
        let moc = client.managedObjectContext!
        PreviewHelpers.loadFixture(named: "testing.goodtohear.habits")
        return TrendsView()
            .environment(\.managedObjectContext, moc)
    }
}

struct PreviewHelpers{
    static func deleteAllData(){
        HabitsQueries.deleteAllHabits()
        HabitsQueries.refresh()
    }
    static func loadFixture(named name: String){
        deleteAllData()
        let bundle = Bundle.main
        let path = Bundle.main.path(forResource: name, ofType: "plist", inDirectory: Locale.current.languageCode) ?? bundle.path(forResource: name, ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path)!
        let array = dict.value(forKeyPath: "goodtohear.habits_habits") as! [Any]
        PlistStoreToCoreDataMigrator.performMigration(with: array) { _ in
            
        }
        HabitsQueries.refresh()
    
    }
}


//+(NSArray*)loadFixtureFromUserDefaultsNamed:(NSString *)name{
//    [HabitsQueries deleteAllHabits];
//    [HabitsQueries refresh];
//    NSString * path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist" inDirectory: [NSLocale currentLocale].languageCode];
//    NSBundle * testBundle = [NSBundle bundleForClass:[self class]];
//    if(!path) path = [testBundle pathForResource:name ofType:@"plist"];
//    if(!path) @throw [NSException exceptionWithName:@"NoFixtureFound" reason:[NSString stringWithFormat:@"Couldn't find %@.plist anywhwere", name] userInfo:nil];
//    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:path];
//    NSArray * array = [[dict valueForKeyPath:@"goodtohear.habits_habits"] map:^NSDictionary*(NSDictionary* record) {
//        NSMutableDictionary * result = [record mutableCopy];
//        result[@"title"] = NSLocalizedStringWithDefaultValue(record[@"title"], nil, testBundle, nil, nil);
//        return result;
//    }];
//    [PlistStoreToCoreDataMigrator performMigrationWithArray:array progress:^(float progress) {
//    }];
//    [HabitsQueries refresh];
//    [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:nil];
//    return array;
//
//}
