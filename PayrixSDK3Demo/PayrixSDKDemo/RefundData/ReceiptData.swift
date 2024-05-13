//
//  ReceiptData.swift
//  PayrixMobile
//
//  Created by Prakash KOtwal on 25/01/2022.
//  Copyright © 2022 Payrix. All rights reserved.
//

import PayrixSDK

class ReceiptData : NSObject
{
	let sharedUtils = SharedUtilities.init()
	func getReceiptArray(payCoreTxn : PayCoreTxn) -> [[[String]]]
	{
		var receiptArray : [[[String]]] = []
//		var receiptSignArray : [[[String]]] = []
		var receiptNoSignArray : [[[String]]] = []
		
		var theAmount:Double = 0.00
		var theTotal: Double = 0.00
		var theTax: Double = 0.00
		
		let numberFmt = NumberFormatter()
		numberFmt.maximumFractionDigits = 2
		let totalAmt = getTotal(transaction: payCoreTxn)
		
		let strPayAmt = NSString(format: "%.2f",(Double(totalAmt) / 100))
		let thePayAmt = numberFmt.number(from: strPayAmt as String)
		
		theTotal = thePayAmt as! Double
		
		
		theTax = (Double(payCoreTxn.tax ?? 0)) / 100
		theAmount = theTotal - theTax
		var createdDate = ""
		
		let dateFmt = DateFormatter()
		dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
		if let dateFromString = payCoreTxn.created
		{
			dateFmt.dateFormat  =   "MM/dd/yy HH:mm:ss"
			createdDate = dateFmt.string(from: dateFromString)
		}
		
		var useMerchant = payCoreTxn.merchant?.dba
		if (useMerchant == "") || (useMerchant == nil)
		{
			
			useMerchant = sharedUtils.getMerchantDBA()
		}
		
		if (useMerchant == "") || (useMerchant == nil)
		{
			useMerchant = sharedUtils.getMerchantID()
		}
		
		let addr1 = payCoreTxn.address1 ?? ""
		let city = payCoreTxn.city ?? ""
		let state = payCoreTxn.state ?? ""
		let postalCode = payCoreTxn.zip ?? ""
		let countryCode = payCoreTxn.country ?? ""
		
		
		
		var addr2 = (city.isEmpty ? "" : city + " | ") + (state.isEmpty ? "" : state + " | ") //(payResponse.receiptCity ?? "") + " | " + (payResponse.receiptStateprovince ?? "") + " | "//"Payrixville" "FL"
		addr2 = addr2 + (postalCode.isEmpty ? "" : postalCode + " | ") + (countryCode.isEmpty ? "" : countryCode + " | ")//addr2 + (payResponse.receiptPostalCodezip ?? "") + " | " + (payResponse.receiptCountryCode ?? "")//"33027" "USA"
		
		var addressArray = [[useMerchant ?? ""]]
		if !addr1.isEmpty
		{
			addressArray.append([addr1])
		}
		
		if !addr2.isEmpty
		{
			addressArray.append([addr2])
		}
		
		
		let terminalID = payCoreTxn.terminal
		let defaultTID = UserDefaults.standard.string(forKey: PayCardSharedAttr.bluetoothReaderSerialNumberKey) ?? " "//sharedUtils.getBTReader() ?? ""
		
//		receiptSignArray = [
//			addressArray,
//			
//			[
//				["Transaction Type" + ":", "SALE"],
//				["TID" + ": ", "\(terminalID ?? defaultTID)"],
//				["Txn/Invc" + ": ", "\(payCoreTxn.id ?? "")"],
//				["Date", createdDate],
//				["APPR CODE",  payCoreTxn.authorization ?? ""]
//			],
//			[
//				["Entry Mode" , getEntryMode(payCoreTxn: payCoreTxn)],
//				["Card Number" + ":", String((payCoreTxn.payment?.number ?? "").suffix(4))],
//				["Expiration" + ":", (payCoreTxn.expiration ?? "")],
//				["AMOUNT", String(format: "$%.2f", theAmount)],
//				["TAX", String(format: "$%.2f", theTax)],
//				["TOTAL", String(format: "$%.2f", theTotal)]
//			],
//			[
//				["AID" + ":", ""],
//				["TVR" + ":", ""],
//				["TSL" + ":", ""],
//				["Application Label" + ":", ""],
//			],
//			[
//				["Signature" , "X________________________"]
//			],
//			[
//				["I AGREE TO PAY ABOVE TOTAL AMOUNT\nIn ACCORDANCE WITH CARD ISSUER'S")],
//				["AGREEMENT"],
//				["(MERCHANT AGREEMENT IF CREDIT VOUCHER)\nRETAIN THIS COPY FOR STATEMENT\nVERIFICATION"],
//				["CUSTOMER COPY"]
//			]
//		]
		
		receiptNoSignArray = [
			addressArray,
			[
				["Transaction Type" + ":", "SALE"],
				["TID" + ": ", "\(terminalID ?? defaultTID)"],
				["Txn/Invc" + ": ", "\(payCoreTxn.id ?? "")"],
				["Date", createdDate],
				["APPR CODE",  payCoreTxn.authorization ?? ""]
			],
			[
				["Entry Mode" , getEntryMode(payCoreTxn: payCoreTxn)],
				["Card Number" + ":", String((payCoreTxn.payment?.number ?? "").suffix(4))],
				["Expiration" + ":", (payCoreTxn.expiration ?? "")],
				["AMOUNT", String(format: "$%.2f", theAmount)],
				["TAX", String(format: "$%.2f", theTax)],
				["TOTAL", String(format: "$%.2f", theTotal)],
			],
//			[
//				["AID" + ":", ""],
//				["TVR" + ":", ""],
//				["TSL" + ":", ""],
//				["Application Label" + ":", ""],
//			]
			//,
//			[
//				["I AGREE TO PAY ABOVE TOTAL AMOUNT\nIn ACCORDANCE WITH CARD ISSUER'S"],
//				["AGREEMENT"],
//				["(MERCHANT AGREEMENT IF CREDIT VOUCHER)\nRETAIN THIS COPY FOR STATEMENT\nVERIFICATION"],
//				["CUSTOMER COPY"]
//			]
		]
		
//		if (payCoreTxn.signature ?? true)
//		{
//			receiptArray = receiptSignArray
//		}
//		else
//		{
			receiptArray = receiptNoSignArray
//		}
		
		return receiptArray
	}
	
	
	func getTotal(transaction: PayCoreTxn) -> Double
	{
		var useNumberTotal:Double = 0.0
		
		if let transactionValue = transaction.settledTotal
		{
			let num = NSNumber.init(value: transactionValue)
			useNumberTotal = (num as! Double)
		}
		else if let transactionValue = transaction.total
		{
			let num = NSNumber.init(value: transactionValue)
			useNumberTotal = (num as! Double)
		}
		else
		{
			useNumberTotal = 0.0
		}
		return useNumberTotal
	}
	
	func getEntryMode(payResponse : PayResponse? = nil, payCoreTxn : PayCoreTxn? = nil) -> String
	{
		var entryMode = ""
		var payMode: String = payResponse?.posEntryMode ?? ""
		if (payCoreTxn?.id ?? "") != ""
		{
			payMode = payCoreTxn?.entryMode ?? ""
		}
		if (payMode == "")
		{
			payMode = payResponse?.payTxn?.entryMode ?? ""
			if payCoreTxn?.id != ""
			{
				payMode = payCoreTxn?.fromtxn?.entryMode ?? ""
			}
			if payResponse?.originalPayRequest?.payManualEntry ?? false
			{
				payMode = "1"
			}
		}
		
		entryMode = "Unknown: " + payMode + " *"
		
		switch payMode
		{
			case "1":
				entryMode = "Manual Entry"
				break
			case "2":
				entryMode = "Swipe - Track1"
				break
			case "3":
				entryMode = "Swipe - Track2"
				break
			case "4":
				entryMode = "Swipe - FullMagStrip"
				break
			case "5":
				entryMode = "Chip - Insert"
				break
			case "6":
				entryMode = "Contactless"
				break
			case "7":
				entryMode = "Fallback - MagStrip"
				break
			case "8":
				entryMode = "Fallback - KeyedEntry"
				break
			case "9":
				entryMode = "Other - ApplePay"
				break
			default:
				entryMode = "Unknown: " + payMode
				break
		}
		return entryMode
	}	
}
