//
//  Calendar.swift
//  SH4RE
//
//  Created by Hannah Brooks on 2023-01-10.
//

import Foundation
import SwiftUI
import Combine

struct DatePicker: View {
    @State private var dates: Set<DateComponents> = []
    let screenSize: CGRect = UIScreen.main.bounds

    @Environment(\.calendar) var calendar
    @Environment(\.timeZone) var timeZone

    var bounds: PartialRangeFrom<Date> {
            let start = calendar.date(
                from: DateComponents(
                    timeZone: timeZone,
                    year: Calendar.current.component(.year, from: Date()),
                    month: Calendar.current.component(.month, from: Date()),
                    day: Calendar.current.component(.day, from: Date()))
            )!
            return start...
        }

    init(dates: Set<DateComponents> = []) {
        self.dates = dates
    }
    
    var body: some View {
        MultiDatePicker(
            "Start Date",
            selection: $dates,
            in: bounds
        )
        .datePickerStyle(.graphical)
        .frame(maxWidth: screenSize.width * 0.9)
    }
}

struct DatePicker_Previews: PreviewProvider {
    static var previews: some View {
        DatePicker()
    }
}
