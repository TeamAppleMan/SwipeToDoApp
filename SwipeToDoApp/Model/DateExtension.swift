//
//  DataExtension.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/25.
//

import Foundation
// Date型でできることを増やす
extension Date {

    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        //calendar.locale   = .current
        return calendar
    }

    // Dataの初期値
    init(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) {
        self.init(
            timeIntervalSince1970: Date().fixed(
                year:   year,
                month:  month,
                day:    day,
                hour:   hour,
                minute: minute,
                second: second
            ).timeIntervalSince1970
        )
    }

    // Dataの修正。上書きされる。
    func fixed(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        let calendar = self.calendar

        var comp = DateComponents()
        comp.year   = year   ?? calendar.component(.year,   from: self)
        comp.month  = month  ?? calendar.component(.month,  from: self)
        comp.day    = day    ?? calendar.component(.day,    from: self)
        comp.hour   = hour   ?? calendar.component(.hour,   from: self)
        comp.minute = minute ?? calendar.component(.minute, from: self)
        comp.second = second ?? calendar.component(.second, from: self)

        return calendar.date(from: comp)!
    }

    // Dataの追加。「-1」などの記入で１日前に戻ることも可能。
    func added(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        let calendar = self.calendar

        var comp = DateComponents()
        comp.year   = (year   ?? 0) + calendar.component(.year,   from: self)
        comp.month  = (month  ?? 0) + calendar.component(.month,  from: self)
        comp.day    = (day    ?? 0) + calendar.component(.day,    from: self)
        comp.hour   = (hour   ?? 0) + calendar.component(.hour,   from: self)
        comp.minute = (minute ?? 0) + calendar.component(.minute, from: self)
        comp.second = (second ?? 0) + calendar.component(.second, from: self)

        return calendar.date(from: comp)!
    }

    // 引数が含む月の最終日を取得（その月が何日まであるのか、を調べる）
    func getMonthLastDay(MonthLastDate: Date) -> Int {
        let nextMonthDate = MonthLastDate.added(year: 0, month: 1, day: 0, hour: 0, minute: 0, second: 0)

        //何故かずれるため、２日戻す
        let frontOfnextMonthDate = nextMonthDate.added(year: 0, month: 0, day: -2, hour: 0, minute: 0, second: 0)
        return frontOfnextMonthDate.day
    }

    // 引数が含む月〜現在の月までが何ヶ月あるかを取得
    func getMonthCount(between fromDate: Date) -> Int {
        guard let monthsLeft = calendar.dateComponents([.month], from: fromDate, to: Date()).month else { return 0 }
        return monthsLeft + 2
    }

    // 引数が含む月〜現在の月までが何ヶ月あるかを取得
    func getMonthCount(fromDate: Date) -> Int {
        guard let monthsLeft = calendar.dateComponents([.month], from: fromDate, to: Date()).month else { return 0 }
        return monthsLeft + 2
    }

    // 「Data型.year」などでInt型で値を取得できるコード
    var year: Int {
        return calendar.component(.year, from: self.added(year: 0, month: 0, day: 0, hour: -9, minute: 0, second: 0))
    }

    var month: Int {
        return calendar.component(.month, from: self.added(year: 0, month: 0, day: 0, hour: -9, minute: 0, second: 0))
    }

    var day: Int {
        return calendar.component(.day, from: self.added(year: 0, month: 0, day: 0, hour: -9, minute: 0, second: 0))
    }

    var hour: Int {
        return calendar.component(.hour, from: self.added(year: 0, month: 0, day: 0, hour: -9, minute: 0, second: 0))
    }

    var minute: Int {
        return calendar.component(.minute, from: self.added(year: 0, month: 0, day: 0, hour: -9, minute: 0, second: 0))
    }

    var second: Int {
        return calendar.component(.second, from: self.added(year: 0, month: 0, day: 0, hour: -9, minute: 0, second: 0))
    }

}
