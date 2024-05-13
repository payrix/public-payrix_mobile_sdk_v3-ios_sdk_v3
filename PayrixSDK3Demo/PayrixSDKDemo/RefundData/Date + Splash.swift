//
//  Date + Splash.swift

//
//  Copyright © 2018 Payrix. All rights reserved.
//

import Foundation
import UIKit

extension Date {
  
  func relativeDayString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    dateFormatter.doesRelativeDateFormatting = true
    return dateFormatter.string(from: self)
  }
  
  func timeString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .short
    return dateFormatter.string(from: self)
  }
  
  func fallsOnSameDayAs(date: Date) -> Bool {
    let diff = Calendar.current.dateComponents([.day], from: self, to: date)
    return diff.day == 0
  }
  
  init(dateString:String, format: String) {
    let dateStringFormatter = DateFormatter()
    dateStringFormatter.dateFormat = format
    dateStringFormatter.locale = Locale.current
    let d = dateStringFormatter.date(from: dateString)!
    self.init(timeInterval: 0, since: d)
  }
  
  func dateTimeString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter.string(from: self)
  }
  
}





