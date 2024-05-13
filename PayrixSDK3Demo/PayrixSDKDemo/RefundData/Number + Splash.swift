//
//  Number + Splash.swift

//
//  Copyright © 2018 Payrix. All rights reserved.
//

import Foundation
import UIKit

extension NSNumber {
  func localCurrencyStringForAmountInCents(currencyCode : String) -> String
  {
    let dollarFloat = self.floatValue / 100
    let dollarValue = NSNumber.init(value: dollarFloat)
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    let currencySymbol = getCurrencySymbol(currencyCode: currencyCode)
    formatter.currencySymbol = currencySymbol
    return formatter.string(from: dollarValue)!
  }
	func getCurrencySymbol(currencyCode : String = "") -> String
	{
		var code = UserDefaults.standard.value(forKey: "AppCurrency") as? String ?? "USD"
		if currencyCode != ""
		{
			code = currencyCode
		}
		let locale = NSLocale(localeIdentifier: code)
		if locale.displayName(forKey: .currencySymbol, value: code) == code {
			let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
			return newlocale.displayName(forKey: .currencySymbol, value: code) ?? "USD"
		}
		return locale.displayName(forKey: .currencySymbol, value: code) ?? "USD"
		
	}
  
	func getCurrencyLocale() -> Locale
 {
	 var locale : Locale!
	 guard let userDLocale = UserDefaults.standard.value(forKey: "AppCurrencyLocale") as? String
	 else
	 {
		 locale = Locale(identifier: "en-US")
		 return locale
	 }
	 locale = Locale(identifier: userDLocale)
	 return locale
 }
  func localCurrencyStringForDollarValue() -> String
  {
    let currencyCode = UserDefaults.standard.value(forKey: "AppCurrency") as? String ?? "USD"
    print("currency code in localCurrencyStringForDollarValue : \(currencyCode)")
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.usesGroupingSeparator = true
    formatter.numberStyle = .currency
    formatter.locale = getCurrencyLocale()
    //        let currencyCode = (getLocale() as NSLocale).object(forKey: .currencyCode) as? String ?? "USD"
    let currencySymbol = getCurrencySymbol()
    formatter.currencySymbol = currencySymbol
    formatter.minimumIntegerDigits = 1
    formatter.maximumFractionDigits = 2
    print("check for converted string: \(formatter.string(from: self)!)")
    return formatter.string(from: self)!
  }
}
