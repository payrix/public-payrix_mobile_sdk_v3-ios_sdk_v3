//
//  DemoTransaction.swift
//  PayrixSDKDemo
//
//  Created by Steve Sykes on 7/22/20.
//  Copyright © 2020 Payrix. All rights reserved.
//

import UIKit
import PayrixSDK

class DemoTransaction: UIViewController, PayrixSDKDelegate
{
  @IBOutlet weak var btnBack: UIButton!
  @IBOutlet weak var btnStartTxn: UIButton!
    @IBOutlet weak var btnReceipt: UIButton!
    
  @IBOutlet weak var txtItemCost: UITextField!
  @IBOutlet weak var txtTaxRate: UITextField!
  @IBOutlet weak var txtTipAmt: UITextField!
  @IBOutlet weak var txtCardNumber: UITextField!
  
  @IBOutlet weak var vwCardDetails: UIView!
  @IBOutlet weak var txtCardHolder: UITextField!
  @IBOutlet weak var txtExpMM: UITextField!
  @IBOutlet weak var txtExpYY: UITextField!
  @IBOutlet weak var txtCVV: UITextField!
  @IBOutlet weak var txtZip: UITextField!
  
  @IBOutlet weak var lblCalcTotal: UILabel!
  @IBOutlet weak var lblProcessLog: UITextView!
  
  @IBOutlet weak var txtPINEntry: UITextField!
  @IBOutlet weak var lblActionMessage: UILabel!
  
  let sharedUtils = SharedUtilities.init()
    
  /** (Step 1)
  * Instantiate PayrixSDK class - Which handles the transactional requests and responses with the Payrix gateway API's.
  */
  
  var payrixSDK = PayrixSDK.sharedInstance
  
  var theMerchantID: String!
  var theMerchantDBA: String = ""
  
  var currentTransaction = CurrentTransaction.sharedInstance
  
  var btDeviceSerialNumber: String = ""
  var btDeviceUUID: String = ""
  var btDeviceManfg: String = ""
  
  var newTransDict = [String:Any]()
  var passedMessage:String?
  var cardReaderDeviceType = String()
  var debitCreditType:String? = String()
  
  var cardEntryMode:String = ""  // SWIPE or EMV or TAP
    //Path for receiptFile Name, if this file has no name, then hide the Report button
  var transactionFileName = ""
  var payResponse : PayResponse!
  
  let numberFmt = NumberFormatter()
  
  //passing payResponse appSelection object to ApplicationSelection Viewcontroller
  var appsSelectionArray : [[String : Int]] = []
  var paymentStatus : String!
    
  override func viewDidLoad()
  {
    super.viewDidLoad()

    payrixSDK.delegate = self
    
    numberFmt.maximumFractionDigits = 2
    
    /* (Step 2)
    * Start doSetPayrixPlatform
    * This step establishes the necessary connections for Callback processing and
    * initializes the PayrixSDK parameters.
    */
  }
  
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    vwCardDetails.isHidden = true
    txtPINEntry.isHidden = true
    
    lblProcessLog.isHidden = false
    
    /*
    * Step X:
    * a. Set the host URL
    * b. Set Demo - Sandbox mode
    * TODO: Add to Documentation
    */
    
    let useManfg = doDetermineManfg()
    let isSandBox =  sharedUtils.getSandBoxOn()!
    let theEnv =  sharedUtils.getEnvSelection()!
    payrixSDK.doSetPayrixPlatform(platform: theEnv, demoSandbox: isSandBox, deviceManfg: useManfg)
  
    sharedUtils.setDemoMode(modeKey: isSandBox)
    
    // Sample Test Values
    
    txtItemCost.text = "5.02"
    txtTaxRate.text = "0.0"
    txtTipAmt.text = "0.00"
    
//  Test Data for Manual Entry Transactions
//    txtCardNumber.text = "4111111111111111"
//    txtCardHolder.text = "John Doe"
//    txtExpMM.text = "12"
//    txtExpYY.text = "23"
//    txtCVV.text = "357"
//    txtZip.text = "33027"
    
    // ****************************************
    
    doSetCurrentTransaction()
    //Hiding the Show Recipt button if transaction file is not created
    btnReceipt.isHidden =  transactionFileName.isEmpty
  }
  
  override func viewDidAppear(_ animated: Bool)
  {
    super.viewDidAppear(animated)
    payrixSDK.delegate = self
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
      if segue.identifier ==  "SegToReceipt"
      {
          let receiptVC : ReceiptVC   =   segue.destination as! ReceiptVC
          receiptVC.fileName      =   self.transactionFileName
          receiptVC.payResponse   =   payResponse
          receiptVC.status    =   paymentStatus
      }
      else if segue.identifier   ==  "SegToAppSelection"
      {
          let appSelectionVC : ApplicationSelectionVC   =   segue.destination as! ApplicationSelectionVC
          appSelectionVC.appsSelectionArray =   appsSelectionArray
          appSelectionVC.delegateAppSelection =   self
      }
  }
  
  private func doDetermineManfg() -> PaySharedAttributes.PaySupportedReaders
  {
    let devManfg = sharedUtils.getBTManfg() ?? ""
    var useManfg: PaySharedAttributes.PaySupportedReaders = PaySharedAttributes.PaySupportedReaders.reader_BBPOS
    
    if devManfg == PaySharedAttributes.PaySupportedReaders.reader_IDTECH.rawValue
    {
      useManfg = PaySharedAttributes.PaySupportedReaders.reader_IDTECH
    }
    else if devManfg == PaySharedAttributes.PaySupportedReaders.reader_BBPOS.rawValue
    {
      useManfg = PaySharedAttributes.PaySupportedReaders.reader_BBPOS
    }
    return useManfg
  }
  
  
  /**
  **doSetCurrentTransaction**
  (Step 3a)
  This method prepares to perform a transaction.
  The demo app uses an object called CurrentTransaction to capture and hold the payment transaction information
  throughout the lifecycle of the transaction.
  In the demo, information created during the Authentication and BT Scan steps are used here and elsewhere in this class.
  */
  private func doSetCurrentTransaction()
  {
    theMerchantDBA = sharedUtils.getMerchantDBA() ?? ""
    theMerchantID = sharedUtils.getMerchantID()
    
    if theMerchantID != nil
    {
      self.currentTransaction.merchantID = theMerchantID
      self.currentTransaction.merchantDBA = theMerchantDBA
      self.currentTransaction.taxPercentage = 0
    }
    else
    {
      updateLog(newMessage: "Authenticate before processing a transaction")
    }
  }
  
  
  /**
  **doBuildTxnAmts**
  (Step 3b)
  This is a utility method to calculate values as needed and then store them in the
  CurrentTransaction object.
  */
  private func doBuildTxnAmts()
  {
    let nbrCost = numberFmt.number(from: String(txtItemCost.text!))
    var decCost = (nbrCost?.decimalValue ?? 0)
    
    var decResult: Decimal = 0
    NSDecimalRound(&decResult, &decCost, 2, .up)
    decCost = decResult
    
    var decTaxRate: Decimal = 0
    if txtTaxRate.text != "" && txtTaxRate.text != nil
    {
      let nbrTaxRate = numberFmt.number(from: String(txtTaxRate.text!)) ?? 0
      self.currentTransaction.taxPercentage = nbrTaxRate.intValue
      decTaxRate = nbrTaxRate.decimalValue
      decTaxRate = decTaxRate / 100.00
      decResult = 0
      NSDecimalRound(&decResult, &decTaxRate, 2, .up)
      decTaxRate = decResult
    }
    else
    {
      self.currentTransaction.taxPercentage = 0
      decTaxRate = 0
    }
    
    var decTip: Decimal = 0
    if txtTipAmt.text != "" && txtTipAmt.text != nil
    {
      let nbrTip = numberFmt.number(from: String(txtTipAmt.text!)) ?? 0
      decTip = nbrTip.decimalValue
      decResult = 0
      NSDecimalRound(&decResult, &decTip, 2, .up)
      decTip = decResult
    }
    
    let intTip = decTip * 100
    let intCost = decCost * 100
    self.currentTransaction.tipAbsoluteAmount = NSDecimalNumber(decimal: intTip).intValue
    self.currentTransaction.amount = NSDecimalNumber(decimal: intCost).intValue
    
    self.currentTransaction.tipPercentage = 0

    let calcTax = decCost * decTaxRate
    let calcTotal = decCost + calcTax + decTip
    
    lblCalcTotal.text = String(format: "%.2f", NSDecimalNumber(decimal: calcTotal).doubleValue)
    
    let logMsg = "Starting Transaction Processing: \nTotal Amount: " + String(format: "%.2f", NSDecimalNumber(decimal: calcTotal).doubleValue)
    updateLog(newMessage: logMsg)
  }
  
  
  @IBAction func goBack(_ sender: Any)
  {
    self.dismiss(animated: true, completion: nil)
  }
  
  
  @IBAction func goCardEntry(_ sender: Any)
  {
    // A card number was entered
    vwCardDetails.isHidden = false
  }
  
  @IBAction func goToReceipt(_ sender: Any)
  {
      self.performSegue(withIdentifier: "SegToReceipt", sender: self)
  }
    
  
  /**
  **goStartTxn**
  * (Step 4)
   This method listens for the Start Transaction button to be tapped.
   The information provided is used to start transaction processing.
   In this demo if the Card Number is the provided then the transaction is managed as
   a manual entry transaction.  Otherwise the transaction will require a BT card reader be used.
  */
  @IBAction func goStartTxn(_ sender: Any)
  {
    hideKeyboard()
    lblProcessLog.text = ""
    doBuildTxnAmts()
    payrixSDK.delegate = self
    
    if (txtCardNumber.text == nil) || (txtCardNumber.text == "")
    {
      doPrepCardReader()
      // Follow Steps: 5a - 11a
    }
    else
    {
      doManualTxn()
      // Follow Steps: 5b - 6b
    }
  }
  
  func doAppSelection(response: PayResponse!)
  {
    appsSelectionArray = response.appSelection ?? []
    if !appsSelectionArray.isEmpty
    {
        self.performSegue(withIdentifier: "SegToAppSelection", sender: nil)
    }
    else
    {
        sharedUtils.showMessage(theController: self, theTitle: "Transaction", theMessage: "No Apps provided for App Selection")
    }
  }
  
  
  func verifyResponse(payResponse : PayResponse!, isForReceipt : Bool)
  {
    if let response = payResponse // as? PayResponse
    {
      if isForReceipt
      {
        updateForReceipt(response: response)
      }
    }
    else
    {
        print("response is nil")
    }
  }
  
  func updateForReceipt(response : PayResponse)
  {
      btnReceipt.isHidden =   false
      let dateFmt = DateFormatter()
      dateFmt.dateFormat = "yy-MM-dd_HHmmss"
      let useTimeStamp = dateFmt.string(from: Date())
      let transactionIdPrefix =   (response.transactionID ?? "") + "_"
      let fName =  transactionIdPrefix + useTimeStamp + "_" + "Receipt"
      let logData = sharedUtils.doGenLogString(source: response)
      sharedUtils.doWriteLogFile(fileName: fName, fileData: logData)
      self.transactionFileName = fName
      self.payResponse = response
  }
    
    
  /**
  **doPrepCardReader**
  * (Step 5a)
   Prepare the card reader by connecting to the Bluetooth Reader.
   If the reader connects successfully then the transaction processing will be triggered
  */
  private func doPrepCardReader()
  {
    payrixSDK.delegate = self
    let payDevice = PayDevice.sharedInstance
    payDevice.deviceManfg = sharedUtils.getBTManfg()
    payDevice.deviceSerial = sharedUtils.getBTReader()
    
    payrixSDK.doConnectBTReader(payDeviceObj: payDevice)
  }
  
  
  /**
  **didReceiveBTConnectResults**
  (Step 6a)
  This is the callback for the BT Connect request.  Once the device is connected the transaction can be processed.
  */
  public func didReceiveBTConnectResults(connectSuccess: Bool!, theDevice: String!)
  {
    // Handle Successful Connection
    if connectSuccess
    {
      updateLog(newMessage: "BT Device: " + btDeviceSerialNumber + " Connected")
      doCardReaderTxn()
    }
    else
    {
      updateLog(newMessage: "BT CONNECTION FAILED: Device: " + btDeviceSerialNumber)
      updateLog(newMessage: "Transaction Not Started \n\n")
    }
  }
  
  
  /**
  **didReceiveBTScanTimeOut**
  This is the callback for the BT Connect request.
  */
  public func didReceiveBTScanTimeOut()
  {
    updateLog(newMessage: "The automatic connection of the Card Reader was unsuccessful.")
  }
  
  public func didReceiveScanResults(scanSuccess: Bool!, scanMsg: String!, payDevices: [AnyObject]?)
  {
    if scanSuccess
    {
      updateLog(newMessage: scanMsg)
      // Capture Scanned Readers objects
    }
    else
    {
      updateLog(newMessage: "The automatic connection of the Card Reader was unsuccessful.")
    }
  }
  
  /**
  **doCardReaderTxn**
  * (Step 7a)
   Started Card Reading (Swipe) process with PayCard doReadCard request passing the transaction information.
  */
  private func doCardReaderTxn()
  {
    cardEntryMode = "EMV"

    var decResult: Decimal = 0
    var decTaxRate: Decimal = 0
    if let intTaxRate = currentTransaction.taxPercentage
    {
      decTaxRate = Decimal(intTaxRate)
      decTaxRate = decTaxRate / 100
      NSDecimalRound(&decResult, &decTaxRate, 2, .up)
      decTaxRate = decResult
    }
    
    decResult = 0
    var decAmount:Decimal = 0
    if let intAmount = currentTransaction.amount
    {
      decAmount = Decimal(intAmount)
      decAmount = decAmount / 100
      NSDecimalRound(&decResult, &decAmount, 2, .up)
      decAmount = decResult
    }
    
    decResult = 0
    var decTip: Decimal = 0.00
    if let intTip = currentTransaction.tipAbsoluteAmount
    {
      decTip = Decimal(intTip)
      decTip = decTip / 100
      NSDecimalRound(&decResult, &decTip, 2, .up)
      decTip = decResult
    }
    
    let calcTax = decAmount * decTaxRate
    let calcTotal = (decAmount + calcTax + decTip) * 100
    let calcTaxI = calcTax * 100
    
    let payRequest = PayRequest.sharedInstance
//    payRequest.doPayInit()
    
    payRequest.payTotalAmt = NSDecimalNumber(decimal: calcTotal).intValue
    payRequest.payTaxAmt = NSDecimalNumber(decimal: calcTaxI).intValue
    payRequest.payTipAmt = currentTransaction.tipAbsoluteAmount
    payRequest.payAmount = currentTransaction.amount
    payRequest.payCurrencyCode = "USD"
    payRequest.payHostURL = sharedUtils.getURL(theURI: "")
    payRequest.payDeviceMode = PaySharedAttributes.PayDeviceMode.cardDeviceMode_SwipeOrInsertOrTap
    payRequest.paySessionKey = sharedUtils.getSessionKey()
    payRequest.payrixMerchantID = sharedUtils.getMerchantID()
    payRequest.payrixSandoxDemoMode = true
    
    doWriteToLog(logType: "Sale-Request", inObj: payRequest)
    payrixSDK.doPaymentTransaction(payRequestObj: payRequest)
  }
  
  
  private func doWriteToLog(logType: String, inObj: AnyObject!)
  {
    let dateFmt = DateFormatter()
    dateFmt.dateFormat = "yy-MM-dd_HHmmss"
    let useTimeStamp = dateFmt.string(from: Date())
    
    let fName = "Log_" + useTimeStamp + "_" + logType
    
    let logData = sharedUtils.doGenLogString(source: inObj)
    sharedUtils.doWriteLogFile(fileName: fName, fileData: logData)
  }
  
  
  /**
  **doManualTxn**
  * (Step 5b)
   Prepare the transaction for processing using the manually entered card information.
  */
  private func doManualTxn()
  {
    currentTransaction.ccName = txtCardHolder.text
    currentTransaction.ccEXP = txtExpMM.text! + txtExpYY.text!
    currentTransaction.ccCVV = txtCVV.text
    currentTransaction.zip = txtZip.text
    currentTransaction.ccNumber = txtCardNumber.text
    
    determineCardType()
    doProcessManualCard()
  }
  
  
  func determineCardType()
  {
    let inputValue = currentTransaction.ccNumber ?? ""
      currentTransaction.ccCardType = nil
      for ccType in SharedUtilities.ccTypeRegex.keys {
          if let regex = SharedUtilities.ccTypeRegex[ccType],
             let _ = inputValue.range(of: regex,
                                      options: .regularExpression) {
              currentTransaction.ccCardType = ccType
          }
      }
  }
  
  
  /**
  **doProcessManualCard**
  * (Step 6b)
   This method prepares and starts the manual card processing using the
   PayCoreMaster method: doManualCardTransaction
   
   The callback is: didReceiveTransactionResponse
  */
  private func doProcessManualCard()
  {
    let useCardType:PaySharedAttributes.CCType?
    if let useCCtype = currentTransaction.ccCardType
    {
      useCardType = PaySharedAttributes.CCType(rawValue: (useCCtype.rawValue))
    }
    else
    {
      useCardType = nil
    }
    
//    var dblTaxRate:Double = 0.00
//    if let intTaxRate = currentTransaction.taxPercentage
//    {
//      dblTaxRate = Double(intTaxRate)
//      dblTaxRate = dblTaxRate / 100
//    }
//
//    var dblAmount:Double = 0.00
//    if let intAmount = currentTransaction.amount
//    {
//      dblAmount = Double(intAmount)
//      dblAmount = dblAmount / 100
//    }
//
//    var dblTip:Double = 0.00
//    if let intTip = currentTransaction.tipAbsoluteAmount
//    {
//      dblTip = Double(intTip)
//      dblTip = dblTip / 100
//    }
//
//    let calcTax = dblAmount * dblTaxRate
//    let calcTotal = dblAmount + calcTax + dblTip
    
    var decResult: Decimal = 0
    var decTaxRate: Decimal = 0
    if let intTaxRate = currentTransaction.taxPercentage
    {
      decTaxRate = Decimal(intTaxRate)
      decTaxRate = decTaxRate / 100
      NSDecimalRound(&decResult, &decTaxRate, 2, .up)
      decTaxRate = decResult
    }
    
    decResult = 0
    var decAmount:Decimal = 0
    if let intAmount = currentTransaction.amount
    {
      decAmount = Decimal(intAmount)
      decAmount = decAmount / 100
      NSDecimalRound(&decResult, &decAmount, 2, .up)
      decAmount = decResult
    }
    
    decResult = 0
    var decTip: Decimal = 0.00
    if let intTip = currentTransaction.tipAbsoluteAmount
    {
      decTip = Decimal(intTip)
      decTip = decTip / 100
      NSDecimalRound(&decResult, &decTip, 2, .up)
      decTip = decResult
    }
    
    let calcTax = decAmount * decTaxRate
    let calcTotal = (decAmount + calcTax + decTip) * 100
    
    currentTransaction.receiptEMVChipInd = "Manual Entry"
    
    let sessionKey = sharedUtils.getSessionKey()
    let payRequest = PayRequest.sharedInstance
    
    payRequest.payrixSandoxDemoMode = true
    payRequest.payHostURL = sharedUtils.getURL(theURI: "")
    payRequest.payCurrencyCode = "USD"
    payRequest.payrixMerchantID = currentTransaction.merchantID
    payRequest.paySessionKey = sessionKey
    
    payRequest.payTotalAmt = NSDecimalNumber(decimal: calcTotal).intValue
    payRequest.payTaxAmt = NSDecimalNumber(decimal: calcTax).intValue
//    payRequest.payTotalAmt = Int((calcTotal * 100).rounded()) // calcTotal
//    payRequest.payTaxAmt = Int((calcTax * 100).rounded()) // calcTax
    payRequest.payTipAmt = currentTransaction.tipAbsoluteAmount
    payRequest.payAmount = currentTransaction.amount
//    payRequest.payAmount = Int((currentTransaction.amount ?? 0.00 * 100).rounded()) // currentTransaction.amount
//    payRequest.payTaxPercent = Int((useTax * 100).rounded()) // useTax
//    payRequest.payTipPercent = Int((currentTransaction.tipPercentage ?? 0.00 * 100).rounded())
//    payRequest.payTipAmt = Int((currentTransaction.tipAbsoluteAmount ?? 0.00 * 100).rounded())
//    payRequest.payTotalAmt = Int((calcTotal * 100).rounded()) // calcTotal
    
    payRequest.payManualEntry = true
    payRequest.payCardHolder = currentTransaction.ccName
    payRequest.payCCNumber = currentTransaction.ccNumber
    payRequest.payCardType = useCardType
    payRequest.payCardCVV = currentTransaction.ccCVV
    payRequest.payCardExp = currentTransaction.ccEXP
    payRequest.payOrigin = PaySharedAttributes.PayTxnOrigin.eCommerceSystem
    payRequest.payPostalCodeZip = currentTransaction.zip
    payRequest.payDeviceMode = PaySharedAttributes.PayDeviceMode.cardDeviceMode_Unknown
    
    doWriteToLog(logType: "Manual-Request", inObj: payRequest)
    payrixSDK.doPaymentTransaction(payRequestObj: payRequest)
  }
  
  
  public func didReceivePayResults(responseType: Int!, actionMsg: String?, infoMsg: String?, payResponse: AnyObject?)
  {
    // ResponseTypes: 1 = Card Action Message   | App Should immediately display to user to do that action
    //                2 = Info Message          | App Should Display the informative message, but not required
    //                3 = PIN Entry Required    | App should Display Field for PIN Entry
    //                4 = App Selection Needed  | App should Display List of Apps to Display
    //                5 = Send Final EMV Data   | App should Catch and use EMV Data as desired
    //                9 = Error Occurred        | App Should Display the error and end processing the transaction
    //                0 = Transaction Complete  | The transaction ended and the PayResponse object contains the
    //                                            completed transaction data.
    
    let usePayResponse = payResponse as? PayResponse
    
    switch responseType
    {
    case 0:
      // Transaction Complete
      doWriteToLog(logType: "Sale-Response", inObj: payResponse)
      sharedUtils.showMessage(theController: self, theTitle: "Transaction Complete - " + (usePayResponse?.receiptApprovedDeclined ?? "") + " -", theMessage: infoMsg ?? "")
      
      let useMsg = "Transaction Complete - \n" + (usePayResponse?.receiptApprovedDeclined ?? "") + "\n" + (infoMsg ?? "")
      updateLog(newMessage: useMsg)
      
      paymentStatus = usePayResponse?.receiptApprovedDeclined ?? ""
      verifyResponse(payResponse: usePayResponse, isForReceipt: true)

      var debugLog = ""
      if let useLogMsg = usePayResponse?.debugSDKData
      {
        debugLog = doDumpDebugInfo(debugLog: useLogMsg)
      }
      else
      {
        debugLog = "No Log Data"
      }
      
      updateLog(newMessage: debugLog)
      print(debugLog)
      break
    case 1:
      // Take Action
      sleep(1)
      lblActionMessage.text = actionMsg
      let useMsg = "Action Message: " + (actionMsg ?? " - ")
      updateLog(newMessage: useMsg)
      paymentStatus = actionMsg
      print(useMsg)
      break
    case 2:
      // Information Message
      sleep(1)
      lblActionMessage.text = ""
      let useMsg = "Info Message: " + (infoMsg ?? " - ") + (actionMsg ?? "")
      updateLog(newMessage: useMsg)
      print(useMsg)
      break
    case 3:
      // PIN Entry Required
      sleep(3)
      txtPINEntry.isHidden = false
      let useMsg = "PIN Entry Required: "
      lblActionMessage.text = useMsg
      updateLog(newMessage: useMsg)
      print(useMsg)
      break
    case 4:
      // App Selection Needed
      let useMsg = "App Selection Needed: "
      lblActionMessage.text = useMsg
      updateLog(newMessage: useMsg)
      print(useMsg)
      doAppSelection(response: usePayResponse)
      
      // verifyResponse(payResponse: usePayResponse, isForReceipt: false)
      break
    case 5:
      // Final EMV Batch Data Sent
      doWriteToLog(logType: "Sale-Final EMV Data", inObj: payResponse)
      txtPINEntry.isHidden = true
      let useMsg = "EMV Final Batch Data Received"
      lblActionMessage.text = useMsg
      updateLog(newMessage: useMsg)
      print(useMsg)
      break
    case 9:
      // Take Action
      sharedUtils.showMessage(theController: self, theTitle: "Action Message", theMessage: actionMsg ?? "")
      break
      
    case 99:
      // Simulation of App Selection Complete
      sharedUtils.showMessage(theController: self, theTitle: "Simulation Completed", theMessage: "App Selection - Simulation Completed")
      paymentStatus = infoMsg
      break
      
    default:
      sharedUtils.showMessage(theController: self, theTitle: "Info Message", theMessage: infoMsg ?? "")
      break
    }
  }
  
  
  func doDumpDebugInfo(debugLog: [String:String]!) -> String
  {
    var dumpedLog = "Payrix Debug Log: \n"
    for (key, value) in debugLog
    {
      dumpedLog = dumpedLog + "Key \(key) contains value: \(value) \n"
    }
    return dumpedLog
  }
  
  
  public func didReceiveRefundResults(success: Bool!, responseCode: Int!, refundMsg: String!, refundResponse: AnyObject?)
  {
    if success
    {
      if responseCode == 7
      {
        // Successful Device Reversal
        sharedUtils.showMessage(theController: self, theTitle: "Device Reversal Request", theMessage: "Device Reversal Request SUCCEEDED!")
        let useMsg = "Successful Device Reversal"
        lblActionMessage.text = useMsg
        updateLog(newMessage: useMsg)
        print(useMsg)
      }
    }
    else
    {
      if responseCode == 6
      {
        // Device Reversal Request Failed
        sharedUtils.showMessage(theController: self, theTitle: "Device Reversal Request", theMessage: "Device Reversal Request FAILED!")
        let useMsg = "Device Reversal Request FAILED: \(refundMsg ?? "NO Msg")"
        lblActionMessage.text = useMsg
        updateLog(newMessage: useMsg)
        print(useMsg)
      }
    }
  }
  
  
  func hideKeyboard()
  {
    view.endEditing(true)
  }
  
  private func updateLog(newMessage: String)
  {
    var currentLog = lblProcessLog.text
    currentLog = currentLog! + "\n" + newMessage
    lblProcessLog.text = currentLog
  }
  
  func refreshLogInfo()
  {
    self.view.setNeedsLayout()
    self.lblProcessLog.setNeedsDisplay()
  }
  
}


extension DemoTransaction : AppSelectedDelegate
{
    func selected(app: [String : Int])
    {
        payrixSDK.doProcessAppSelection(appIndex: app.values.first!, appName: app.keys.first!)
    }
}


