//
//  ReceiptVC.swift
//  PayrixSDKDemo
//
//  Created by PRAKASH on 4/6/21.
//  Copyright © 2021 Payrix. All rights reserved.
//

import UIKit
import PayrixSDK
import MessageUI

class ReceiptVC: UIViewController
{
  @IBOutlet weak var tableViewReceipt: UITableView!
    @IBOutlet weak var segmentCustomerMerchantCopy: UISegmentedControl!
    
  let sharedUtils = SharedUtilities.init()
  
  var payResponse : PayResponse!
  var status : String!
  
  var fileName : String = ""
  var receiptArray : [[String]] = []
  var receiptSignArray : [[String]] = []
  var receiptNoSignArray : [[String]] = []
  var receiptDeclineArray : [[String]] = []
  
  let regularFont = UIFont.systemFont(ofSize: 15)
  let boldFont = UIFont.boldSystemFont(ofSize: 15)
  
  let declineMessage = "DECLINE"
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  
  override func viewWillAppear(_ animated: Bool)
  {
    super .viewWillAppear(animated)
    updateTableView()
    
  }
    
  func updateTableView()
  {
    var theCost:Double = 0.00
    var theTotal: Double = 0.00
    var theTax: Double = 0.00
    var theTip: Double = 0.00
    let numberFmt = NumberFormatter()
    numberFmt.maximumFractionDigits = 2
    
    if let useAmt = payResponse.amount
    {
      let strPayAmt = NSString(format: "%.2f",(Double(useAmt) / 100))
      let thePayAmt = numberFmt.number(from: strPayAmt as String)
      theCost = thePayAmt as! Double
      theTotal = thePayAmt as! Double
    }
    
    if let useTip = payResponse.tipAbsoluteAmount
    {
      let strVal = NSString(format: "%.2f",(Double(useTip) / 100))
      let dblVal = numberFmt.number(from: strVal as String)
      theTip = dblVal as! Double
    }
  
    theTax = (Double(payResponse.originalPayRequest?.payTaxAmt ?? 0)) / 100
    
//    if let useTax = payResponse.taxPercentage
//    {
//      let strVal = NSString(format: "%.2f",(Double(useTax) / 100))
//      let dblVal = numberFmt.number(from: strVal as String)
//      let thePayTaxPct = dblVal as! Double
//      theTax = (theTotal - theTip) * Double(thePayTaxPct)
//    }
    
//    theTip = (Float(payResponse.originalPayRequest?.payTipAmt ?? 0)) / 100
//    theTax = (Float(payResponse.originalPayRequest?.payTaxAmt ?? 0)) / 100
    
    theCost = theTotal - (theTax + theTip)
    
    var cardValue = "---"
    if let cardType = payResponse.ccCardType
    {
      cardValue  =   sharedUtils.getCardName(cardType: cardType)
    }
    else if let cardBrand = payResponse.receiptCardBrandName
    {
      cardValue = cardBrand
    }

    var createdDate = ""
    if let date = payResponse.payTxn?.created
    {
      let dateFmt = DateFormatter()
      dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
      if let dateFromString = dateFmt.date(from: date)
      {
        dateFmt.dateFormat  =   "MM/dd/yy HH:mm:ss"
        createdDate = dateFmt.string(from: dateFromString)
      }
    }
    
    if (createdDate == "")
    {
      let todayNow = Date()
      let dateFmt = DateFormatter()
      dateFmt.dateFormat = "MM/dd/yy HH:mm:ss"
      createdDate = dateFmt.string(from: todayNow)
    }
    
    
    /*
     public enum readerEntryMode: String
     {
       case read_Manual_Entry = "1"        // Manual Entry
       case read_Track1 = "2"              // Track 1
       case read_Track2 = "3"              // Track 2
       case read_MagneticStrip = "4"       // Full magnetic stripe read
       case read_EMV_ChipCard = "5"        // ICC
       case read_Contactless_EMV = "6"     // Contactless EMV
       case read_Fallback_Magnetic = "7"   // Fallback magnetic stripe read
       case read_Fallback_Keyed = "8"      // Fallback Keyed Entry
       case read_ApplePay = "9"            // ApplePay
     }
     */
    
    var entryMode = ""
    var payMode: String = payResponse.posEntryMode ?? ""
    if (payMode == "")
    {
      payMode = payResponse.payTxn?.entryMode ?? ""
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
    
    var useMerchant = payResponse.merchantDBA
    if (useMerchant == "") || (useMerchant == nil)
    {
      useMerchant = sharedUtils.getMerchantDBA()
    }
    
    if (useMerchant == "") || (useMerchant == nil)
    {
      useMerchant = "Co ID: " + (sharedUtils.getMerchantID() ?? "---")
    }
    
    let addr1 = payResponse.receiptAddressLine1 ?? "Cert Merchant Street Address"
    var addr2 = (payResponse.receiptCity ?? "Payrixville") + " | " + (payResponse.receiptStateprovince ?? "FL") + " | "
    addr2 = addr2 + (payResponse.receiptPostalCodezip ?? "33027") + " | " + (payResponse.receiptCountryCode ?? "USA")
    
    let terminalID = payResponse.receiptTerminal
    let defaultTID = sharedUtils.getBTReader() ?? ""
    
    receiptSignArray = [
      [useMerchant ?? ""],
      [addr1],
      [addr2],
      ["SALE"],
      ["TID: ", "\(terminalID ?? defaultTID)"],
      ["Txn/Invc: ", "\(payResponse.transactionID ?? "")"],
      ["Date", createdDate],
      ["APPR CODE",  payResponse.receiptAuthApprovalCode ?? ""],
      ["Card", cardValue],
      ["Entry Mode" , entryMode],
      ["Card Number:", payResponse.ccNumber ?? ""],
      ["Expiration:", (payResponse.ccEXP ?? "")],
      ["AMOUNT", String(format: "$%.2f", theCost)],
      ["TAX", String(format: "$%.2f", theTax)],
      ["TIP", String(format: "$%.2f", theTip)],
      ["TOTAL", String(format: "$%.2f", theTotal)],
      [status],
      ["X________________________"],
      ["Card", cardValue],
      ["AID:", payResponse.receiptAID_4F ?? ""],
      ["TVR:", payResponse.receiptTVRCVR_95 ?? ""],
      ["TSL:", payResponse.receiptTSI_9B ?? ""],
      ["Application Label:", payResponse.receiptAppLabel ?? ""],
      ["I AGREE TO PAY ABOVE TOTAL AMOUNT\nIn ACCORDANCE WITH CARD ISSUER'S"],
      ["AGREEMENT"],
      ["(MERCHANT AGREEMENT IF CREDIT VOUCHER)\nRETAIN THIS COPY FOR STATEMENT\nVERIFICATION"],
        [segmentCustomerMerchantCopy.selectedSegmentIndex == 0 ? "MERCHANT COPY" : "CUSTOMER COPY"]
    ]
    
    receiptNoSignArray = [
      [payResponse.merchantDBA ?? ""],
      [addr1],
      [addr2],
      ["SALE"],
      ["TID: ", "\(terminalID ?? defaultTID)"],
      ["Txn/Invc: ", "\(payResponse.transactionID ?? "")"],
      ["Date", createdDate],
      ["APPR CODE",  payResponse.receiptAuthApprovalCode ?? ""],
      ["Card", cardValue],
      ["Entry Mode" , entryMode],
      ["Card Number:", payResponse.ccNumber ?? ""],
      ["Expiration:", (payResponse.ccEXP ?? "")],
      ["AMOUNT", String(format: "$%.2f", theCost)],
      ["TAX", String(format: "$%.2f", theTax)],
      ["TIP", String(format: "$%.2f", theTip)],
      ["TOTAL", String(format: "$%.2f", theTotal)],
      [status],
      ["Card", cardValue],
      ["AID:", payResponse.receiptAID_4F ?? ""],
      ["TVR:", payResponse.receiptTVRCVR_95 ?? ""],
      ["TSL:", payResponse.receiptTSI_9B ?? ""],
      ["Application Label:", payResponse.receiptAppLabel ?? ""],
      ["I AGREE TO PAY ABOVE TOTAL AMOUNT\nIn ACCORDANCE WITH CARD ISSUER'S"],
      ["AGREEMENT"],
      ["(MERCHANT AGREEMENT IF CREDIT VOUCHER)\nRETAIN THIS COPY FOR STATEMENT\nVERIFICATION"],
        [segmentCustomerMerchantCopy.selectedSegmentIndex == 0 ? "MERCHANT COPY" : "CUSTOMER COPY"]
    ]
    
    receiptDeclineArray = [
      [payResponse.merchantDBA ?? ""],
      [addr1],
      [addr2],
      ["SALE"],
      ["TID: ", "\(terminalID ?? defaultTID)"],
      ["Txn/Invc: ", "\(payResponse.transactionID ?? "")"],
      ["Date", createdDate],
      ["APPR CODE",  payResponse.receiptAuthApprovalCode ?? ""],
      ["Card", cardValue],
      ["Entry Mode" , entryMode],
      ["Card Number:", payResponse.ccNumber ?? ""],
      ["Expiration:", (payResponse.ccEXP ?? "")],
      ["AMOUNT", String(format: "$%.2f", theCost)],
      ["TAX", String(format: "$%.2f", theTax)],
      ["TIP", String(format: "$%.2f", theTip)],
      ["TOTAL", String(format: "$%.2f", theTotal)],
      [status],
      ["Card", cardValue],
      ["AID:", payResponse.receiptAID_4F ?? ""],
      ["TVR:", payResponse.receiptTVRCVR_95 ?? ""],
      ["TSL:", payResponse.receiptTSI_9B ?? ""],
      ["Application Label:", payResponse.receiptAppLabel ?? ""]
    ]
    
    
    if status.contains(declineMessage)
    {
        segmentCustomerMerchantCopy.isHidden = true
        receiptArray = receiptDeclineArray
    }
    else
    {
      if (payResponse.receiptSignLineRequired ?? true)
      {
        receiptArray = receiptSignArray
      }
      else
      {
        receiptArray = receiptNoSignArray
      }
    }
        
    tableViewReceipt.reloadData()
  }

  @IBAction func actionSwitchCopies(_ sender: Any) {
      updateTableView()
  }
    
  @IBAction func actionDownloadReceipt(_ sender: Any)
  {
      saveReceiptToGallery()
  }
    
  func saveReceiptToGallery(){
      if let image = self.tableViewReceipt.image
      {
          UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
          sharedUtils.showMessage(theController: self, theTitle: "Image Saved To Gallery", theMessage: "")
      }
  }

  @IBAction func actionShare(_ sender: Any)
  {
      let actionSheet = UIAlertController(title: "Select Action", message: "", preferredStyle: .actionSheet)
      
      let emailAction = UIAlertAction(title: "Email Receipt", style: .default)
      { (_) in
          self.sendEmail()
      }
      
      let downloadAction = UIAlertAction(title: "Download", style: .default)
      { (_) in
          self.saveReceiptToGallery()
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      actionSheet.addAction(emailAction)
      actionSheet.addAction(downloadAction)
      actionSheet.addAction(cancelAction)
      
      present(actionSheet, animated: true, completion: nil)
  }
    
  @IBAction func goBack(_ sender: Any)
  {
      self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func goToEmail(_ sender: Any)
  {
      sendEmail()
  }
  
  
  //show email popup
  func sendEmail()
  {
    if MFMailComposeViewController.canSendMail()
    {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients([""])
        mail.setSubject("Receipt")
        
        if let data = self.tableViewReceipt.image?.pngData()
        {
            mail.addAttachmentData(data, mimeType: "image/jpeg" , fileName: fileName + ".png")
        }
        present(mail, animated: true)
    }
    else
    {
        // show failure alert
        sharedUtils.showMessage(theController: self, theTitle: "Email not set up in this device.", theMessage: "")
    }
  }
}

extension ReceiptVC : MFMailComposeViewControllerDelegate
{
  //delegate method from email composer for error or success response from email client
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
  {
    controller.dismiss(animated: true)
    {
        if error == nil
        {
            print("Email sent")
        }
        else
        {
            print("Email not sent")
        }
    }
  }
}


extension ReceiptVC : UITableViewDataSource, UITableViewDelegate
{
  func numberOfSections(in tableView: UITableView) -> Int
  {
      return 1
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
      return receiptArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let valueAtIndex = receiptArray[indexPath.row]
    if valueAtIndex.count == 1
    {
      let cell = tableView.dequeueReusableCell(withIdentifier: "TitleOnlyCell")!
      cell.textLabel?.textAlignment = .center
      if indexPath.row == 1
      {
          cell.textLabel?.font = boldFont
      }
      else
      {
          cell.textLabel?.font = regularFont
      }
      cell.textLabel?.text = valueAtIndex.first
   //   cell.textLabel?.numberOfLine = 0
    
      return cell
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: "TitleDetailCell")!
    cell.textLabel?.text = valueAtIndex.first
    cell.detailTextLabel?.text = nil
    if valueAtIndex.count == 2
    {
      cell.detailTextLabel?.text = valueAtIndex.last
    }
    cell.textLabel?.font = regularFont
    cell.detailTextLabel?.font = regularFont
    
    if !status.contains(declineMessage) && (indexPath.row == 13 || indexPath.row == 14 || indexPath.row == 15)
    {
      cell.textLabel?.font = boldFont
      cell.detailTextLabel?.font = boldFont
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
  {
    if !status.contains(declineMessage)
    {
      if indexPath.row == (payResponse.receiptSignLineRequired ?? false ? 22 : 21)
      {
        return 51
      }
      if indexPath.row == (payResponse.receiptSignLineRequired ?? false ? 24 : 23)
      {
        return 72
      }
    }
    return 17
  }
}

extension UIView
{

    // If Swift version is lower than 4.2,
    // You should change the name. (ex. var renderedImage: UIImage?)

    var image: UIImage?
    {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in layer.render(in: rendererContext.cgContext) }
    }
}
