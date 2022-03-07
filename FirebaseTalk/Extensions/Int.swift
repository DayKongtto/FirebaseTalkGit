//
//  Int.swift
//  FirebaseTalk
//
//  Created by PSJ on 2022/03/07.
//

import Foundation

extension Int {
    var toDayTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date(timeIntervalSince1970: Double(self) / 1000)
        return dateFormatter.string(from: date)
    }
}
