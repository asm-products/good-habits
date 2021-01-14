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

private func countDays(from: Date, to: Date)->Int{
    let fromComponents = Calendar.current.dateComponents([.year,.month,.day], from: from)
    let toComponents = Calendar.current.dateComponents([.year,.month,.day], from: to)
    return abs( Calendar.current.dateComponents([.day], from: fromComponents, to: toComponents).day ?? 0)
}


private func d(_ date: Date?)->String{
    if let date = date {
        return DateFormatter(dateFormat: "d MMM yyyy").string(from: date)
    }else{
        return "n/a"
    }
}
struct ChainPair:Identifiable{
    var id:NSManagedObjectID
    let chain: Chain
    let next: Chain?
    let daysCoveredByChain: Int // longer than the day count when not all days are required
    var daysBetween: Int
    init(pair: (Chain,Chain?)){
        
        self.chain = pair.0
        self.next = pair.1
        self.id = chain.objectID
        
        self.daysCoveredByChain = countDays(from: chain.firstDateCache ?? TimeHelper.today(), to: chain.lastDateCache ?? TimeHelper.today()) + 1
        self.daysBetween = max(0,countDays(
            from: chain.lastDateCache ?? TimeHelper.today(),
            to: next?.firstDateCache ?? TimeHelper.today()
        ) - 1)

        if chain.habit.title == "Russian"{ // FIXME: REMOVE THIS IT WAS JUST FOR TESTING
            print("Russian: \(d(chain.firstDateCache))-\(d(chain.lastDateCache)), \(d(next?.firstDateCache)): \(daysCoveredByChain) day(s) long, \(daysBetween) day(s) between")
        }
    }
    
}

private func width(days: Int)->CGFloat{
    8.0 * CGFloat(days)
}

private func days(inMonth components: DateComponents)->Int?{
    let thisMonth = Calendar.current.dateComponents([.year,.month,.day], from: TimeHelper.today())
    if thisMonth.year == components.year && thisMonth.month == components.month{
        return thisMonth.day
    }
    let date = Calendar.current.date(from: components) ?? TimeHelper.today()
    return Calendar.current.range(
        of: .day,
        in: .month,
        for: date
    )?.count
}

private func monthWidth(components: DateComponents)->CGFloat{
    width(days: days(inMonth: components) ?? 10)
}

extension DateFormatter{
    convenience init(dateFormat: String){
        self.init()
        self.dateFormat = dateFormat
    }
}
fileprivate let shortDate = DateFormatter(dateFormat: "d MMM")

struct ChainsView: View {
    var habit:Habit
    var earliestDate: Date
    
    var body: some View{
        habit.chains.forEach{ if $0.firstDateCache == nil || $0.lastDateCache == nil || $0.daysCountCache == 0 { $0.emergencyCacheRefresh()}}
        CoreDataClient.default()?.save()
        let chains = habit.chains.filter{$0.firstDateCache != nil && $0.lastDateCache != nil}.sorted(by: { $0.firstDateCache! < $1.firstDateCache! })
        let pairs = zip(chains, chains.dropFirst().map{$0} as [Chain?] + [nil]).map{ChainPair(pair: $0)}
        
        var offsetWidth:CGFloat = 0
        if let firstChainStart = chains.first?.firstDateCache{
            let components = Calendar.current.dateComponents([.day], from: earliestDate, to: firstChainStart)
            if let days = components.day{
                offsetWidth = width(days: days)
            }
        } 
        
        return HStack(spacing:0) {
            Rectangle().fill(Color.clear).frame(width: offsetWidth)
            ForEach(pairs){ pair in
                Group {
                    Capsule()
                        .fill(Color(habit.color))
                        .frame(width: width(days: pair.daysCoveredByChain), height: 8)
//                        .overlay(
//                            Text("\(d(pair.chain.firstDateCache))- \(d(pair.chain.lastDateCache)) (\(pair.chain.daysCountCache ?? -1))")
//                        )
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: width(days: pair.daysBetween), height: 8 )
//                        .overlay(Text("\(pair.daysBetween )"))
                    
                }.onTapGesture {
                    print(("\(d(pair.chain.firstDateCache))- \(d(pair.chain.lastDateCache)) (\(pair.chain.daysCountCache ?? -1))"))
                }
            }
        }
    }
}

struct GreyRect: View{
    var body: some View{
        Rectangle().fill(Color(Colors.grey()))
    }
}

func startOfMonth(date: Date)->Date{
    let firstDateComponents = Calendar.current.dateComponents([.year,.month], from: date)
    return Calendar.current.date(from: firstDateComponents)!
}

@available(iOS 14.0, *)
struct Timeline: View {
    var habits: FetchedResults<Habit>
    
    @Binding var selectedMonth: DateComponents?
    @State var offset: CGPoint = .zero
    
    let TitlesWidth:CGFloat = 85
    let TitlesPadding:CGFloat = 5

    func months(since earliestDate: Date)->[DateComponents]{
        var results = [DateComponents]()
        var nextDate:Date? = startOfMonth(date: earliestDate)
        while let date = nextDate, date <= TimeHelper.today() {
            results.append(Calendar.current.dateComponents([.year,.month], from: date))
            nextDate = Calendar.current.date(byAdding: DateComponents(month: 1), to: date)
        }
        return results
    }
    
    func updateSelectedMonth(months: [DateComponents], offset:CGPoint){
        var x:CGFloat = 0
        let offsetX = -offset.x + (UIScreen.main.bounds.width / 2) // HACK won't work windowed on iPad.
        for month in months{
            let nextX = x + monthWidth(components: month)
            if offsetX >= x && offsetX <= nextX{
                withAnimation {
                    selectedMonth = month
                }
            }
            x = nextX
        }
        self.offset = offset
    }
    
    var body: some View{
        let earliestDate = habits.reduce(TimeHelper.today()) { (memo, habit) -> Date in
            let date = habit.earliestDate() ?? TimeHelper.today()
            return date < memo ? date : memo
        }
        let startOfFirstMonth = startOfMonth(date: earliestDate)
        let months = self.months(since: earliestDate)
        return TrackableScrollView(
            axes: .horizontal,
            showsIndicators: false,
            offsetChanged: {
                updateSelectedMonth(months: months, offset: $0)
            }
        ){
            ScrollViewReader{ scrollViewReader in
                VStack(alignment: .leading, spacing: 0){
                    VStack(alignment: .leading, spacing: 0) {
                        // month labels:
                        HStack(spacing: 0){
                            ForEach(months, id: \.self){ components in
                                Text("  \(Calendar.current.shortMonthSymbols[components.month! - 1]) \(String(components.year ?? 0))")
                                    .frame(
                                        width: monthWidth(components: components),
                                        alignment: .leading
                                    )
                                    .foregroundColor(Color(Colors.grey()))
                                    .overlay(GreyRect().frame(width: 1, height: 1000),alignment: .topLeading)
                            }
                            // pad out behind the titles overlay
                            Spacer(minLength: TitlesWidth + TitlesPadding).id("end")
                            
                        }
                        // bottom border:
                        GreyRect().frame(maxWidth: .infinity, maxHeight: 1)
                        
                    }
                    // chains:
                    ForEach(habits.filter{$0.identifier != nil}, id: \.identifier){ (habit: Habit) in
                        ChainsView(habit: habit, earliestDate: startOfFirstMonth).frame(height: 20)
                    }
                }
                .frame(maxWidth: .infinity)
                .onAppear{
                    scrollViewReader.scrollTo("end")
                    updateSelectedMonth(months: months, offset: offset)
                }
            }
//            .padding(.trailing, 72)
        }
        .overlay( // titles layer
            VStack(alignment: .leading, spacing: 0){
                ForEach(habits, id: \.identifier){ (habit:Habit) in
                    Text(habit.title)
                        
                        .lineLimit(1)
                        .frame(width: TitlesWidth, height: 20, alignment: .leading)
                        .padding(.leading, TitlesPadding)
                }
                .background(Color(UIColor.systemBackground))
                .overlay(GreyRect().frame(width: 1), alignment: .leading)
            },
            alignment: .bottomTrailing
        )
        .font(.system(size: 11))
    }
}

@available(iOS 14.0, *)
struct TrendsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: Habit.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Habit.isActive, ascending: false),
            NSSortDescriptor(keyPath: \Habit.order, ascending: true)
        ]) var habits: FetchedResults<Habit>
    
    @State var selectedMonth: DateComponents?
    @ObservedObject var appFeatures = AppFeaturesObserver()
 
    @State var overlayRevealed = false // for fade in
    
    var body: some View {
        VStack{
            SelectedMonth(habits: habits, selectedMonth: selectedMonth ?? Calendar.current.dateComponents([.year,.month], from: TimeHelper.today()))
            .padding()
            Spacer()
            Timeline(habits: habits, selectedMonth: $selectedMonth)
                .padding(.bottom)
                .background(Color(UIColor.systemBackground))
        }
        .background(Color(Colors.grey()).opacity(0.4))
        .blur(radius: appFeatures.statsEnabled ? 0 : 6.0)
        .overlay(
            appFeatures.statsEnabled && overlayRevealed ? nil :
                StatsAndTrendsPurchaseView()
                .padding(20)
                .opacity(overlayRevealed ? 1.0 : 0)
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation{
                            overlayRevealed = true
                        }
                    }
                }
        )
    }
}

@available(iOS 14.0, *)
struct TrendsView_Previews: PreviewProvider {
    static var previews: some View {
        let client = CoreDataClient.default()!
        let moc = client.managedObjectContext!
        PreviewHelpers.loadFixture(named: "testing.goodtohear.habits")
        return NavigationView{
            TrendsView()
                .navigationBarTitle("Trends")
        }
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
        let firstDate = Calendar.current.date(from: DateComponents(year: 2014, month: 10, day: 2))!
        let options = ["addTimeInterval": NSNumber(value: TimeHelper.today().timeIntervalSinceReferenceDate - firstDate.timeIntervalSinceReferenceDate)]
        PlistStoreToCoreDataMigrator.performMigration(
            with: array
//            ,options: options
        ) { _ in
            
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
