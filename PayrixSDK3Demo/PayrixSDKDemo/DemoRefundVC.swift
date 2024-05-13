//
//  DemoRefundVC.swift
//  PayrixSDKDemo
//
//  Created by PRAKASH on 5/20/21.
//  Copyright © 2021 Payrix. All rights reserved.
//

import UIKit
import PayrixSDK

class DemoRefundVC: UIViewController, UITextFieldDelegate {
	//outlets
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var btnRefund: UIButton!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var imgCardType: UIImageView!
	@IBOutlet weak var lblAmount: UILabel!
	@IBOutlet weak var lblTop: UILabel!
	@IBOutlet weak var viewRefundButton: UIView!
	
	//variables
	let txnList : [String] = ["Amount:", "Card Type:", "Last 4:", "Transaction Type:", "Status:", "Date:", "ID:"]
	let amountList : [String] = ["Sale Amount:", "Tax:", "Total:"]
	let refundList : [String] = ["Refund Amount:", "Refund Date:", "Refund ID:"]
	let boldFont = UIFont.boldSystemFont(ofSize: 15)
	let regularFont = UIFont.systemFont(ofSize: 15)
	var refundResponse : RefundResponse!
	var passedTransaction : PayCoreTxn!
	var historyDetailRowHeight: CGFloat = 302.0
	let sharedUtils = SharedUtilities.init()
	var payrixSDK = PayrixSDKMaster.sharedInstance
	var enteredRefundAmount : String = ""
	var receiptArray : [[[String]]] = []
	var relatedTransactions = [PayCoreTxn]()
	
	//set this key to true or false to use TxnSessionKey for transactions
	//set this key to true or false to use TxnSessionKey for transactions
	var useTxnSessionKey : Bool!
	var merchantId : String!
	var txnSessionKey : String?
	var paySessionKey : String?
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		//Due to occasional API issues, we need to add comments to this code as sometimes the refund eligibility cannot be determined.
		btnRefund.isHidden = true
		btnRefund.isEnabled = false
		relatedTransactions = []
		doGetSubsequentTransactions()
		
		tableView.register(UINib(nibName: "TitleDetailCell", bundle: nil), forCellReuseIdentifier: "TitleDetailCell")
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultTableCell")
		if !(passedTransaction.type ==  PayCoreTxnType.reverseAuthorization || passedTransaction.type ==  PayCoreTxnType.refundTransaction)
		{
			self.receiptArray = ReceiptData().getReceiptArray(payCoreTxn: passedTransaction)//, selectedSegmentIndex: 0)
		}
		else
		{
			relatedTransactions.append(passedTransaction)
		}
		
		refreshTransactionDetails()
	}
	
	/**
	 **refreshTransactionDetails**
	 
	 This method handles the refreshing of the App screen with the latest data.
	 
	 */
	func refreshTransactionDetails()
	{
		self.tableView.separatorStyle = .none
		self.tableView.setNeedsLayout()
		self.tableView.setNeedsDisplay()
		self.tableView.reloadData()
	}
	
	/**
	 **doGetSubsequentTransactions**
	 
	 This method retrieves transactions related to the original transaction.
	 These Related or Subsequent transactions are displayed in the receipt detailed history.
	 */
	func doGetSubsequentTransactions()
	{
		//		// Retrieve Related Transactions including Refunds.
		//		if ((useSessionID == nil) || (useMerchantID == nil)) && !useTxnSessionKey
		//		{
		//
		//			let unexpectedError = "An unexpected error has occurred"
		//			let retrievingTxn = "retrieving related transactions"
		//			let signOutAndSignIn =  "Please Sign Out and Sign Back in or get the TxnId and Retry."
		//			let message = unexpectedError + " " + retrievingTxn + ".  " + signOutAndSignIn
		//			print(message)
		//			showMessage(inMessage: message)//"An Unexpected Error retrieving related transactions.  Please Sign Out and Sign Back in and Retry.")
		//		}
		//		else if useTxnSessionKey && (txnSessionKey == nil || txnSessionKey == "" || txnSessionKey?.isEmpty ?? false)
		//		{
		//			let unexpectedError = "An unexpected error has occurred"
		//			let retrievingTxn = "retrieving related transactions"
		//			let signOutAndSignIn =  "Please Sign Out and Sign Back in or get the TxnId and Retry."
		//			let message = unexpectedError + " " + retrievingTxn + ".  " + signOutAndSignIn
		//			print(message)
		//			showMessage(inMessage: message)
		//		}
		//		else
		//		{
		// Initialize TxnDataRequest Object
		let theTxnRequest = TxnDataRequest.init()
		theTxnRequest.pagination = 20
		theTxnRequest.currentPage = 0
		theTxnRequest.payTxn = passedTransaction
		theTxnRequest.payrixMerchantID = merchantId
		
		if useTxnSessionKey{
			theTxnRequest.paySessionKey = ""
			theTxnRequest.useTxnSessionKey = true
			theTxnRequest.payTxnSessionKey = txnSessionKey
		}
		else{
			theTxnRequest.paySessionKey = paySessionKey
			theTxnRequest.useTxnSessionKey = false
			theTxnRequest.payTxnSessionKey = ""
		}
		
		
		
		theTxnRequest.payrixTxnID = passedTransaction.id
		//      theTxnRequest.totalPages = 0
		theTxnRequest.payrixSandoxDemoMode = true
		theTxnRequest.requestType = 3
		// Call the method to retrieve the transactions
		payrixSDK.delegate = self
		payrixSDK.doTransactionDataRequest(txnRequestObj: theTxnRequest)
		//		}
		
	}
	
	@IBAction func goReverseAuth(_ sender: Any) {
		var totalRefundAmt  : Double = 0.0
		let passedTxnType = passedTransaction.type?.rawValue
		if passedTxnType == 2 || passedTxnType == 3 || passedTxnType == 4 || passedTxnType == 5
		{
			totalRefundAmt = Double(passedTransaction.total ?? 0)
		}
		let currAmt = passedTransaction.approved
		let isReverseAuthDone = (passedTransaction.type?.rawValue ?? 0) == 4
		print("Total Refund Done: \(totalRefundAmt) and Approved \(currAmt)")
		if (totalRefundAmt <= 0) {
			if (currAmt != nil) {
				processRefundRequest(refundAmt: Double(currAmt ?? 0), isReversal: true)
			} else {
				sharedUtils.showMessage(theController: self, theTitle: "History Details", theMessage: "You can't perform reverse auth on a failed or refunded transaction")
			}
		} else if (isReverseAuthDone) {
			sharedUtils.showMessage(theController: self, theTitle: "History Details", theMessage: "Reverse auth already done on this transaction.");
		} else {
			sharedUtils.showMessage(theController: self, theTitle: "History Details", theMessage: "Partial reversal is not allowed! Kindly use refund instead.");
		}
	}
	/**
	 **goRefund**
	 
	 This method is triggered by the Refund button displayed on the scene, and initiates
	 Refund processing.
	 
	 */
	@IBAction func goRefund(_ sender: Any)
	{
		showGetRefundAmt()
	}
	
	@IBAction func goBack(_ sender: Any)
	{
		self.dismiss(animated: false, completion: nil)
	}
	
	@IBAction func processRefund(_ sender: Any)
	{
		let alertControl = UIAlertController(title: "Refund Request", message: "Enter Amount to be Refunded.", preferredStyle: .alert)
		let processButton = UIAlertAction(title: "Process Refund", style: .default) { (action) in
			let refundRequest = RefundRequest.sharedInstance
			
			if self.useTxnSessionKey{
				refundRequest.paySessionKey = nil
				refundRequest.useTxnSessionKey = true
				refundRequest.payTxnSessionKey = self.txnSessionKey
			}
			else{
				refundRequest.paySessionKey = self.paySessionKey
				refundRequest.useTxnSessionKey = false
				refundRequest.payTxnSessionKey = nil
			}
			
			
			refundRequest.payTxn = self.refundResponse.originalTxn
			refundRequest.requestType = 5
			refundRequest.payrixMerchantID = self.merchantId
			let amountForRefund = self.dollarToCent(amount: (alertControl.textFields?.first?.text ?? ""))
			refundRequest.refundAmt = Int(Float(amountForRefund * 100).rounded())
			self.activityIndicator.startAnimating()
			self.payrixSDK.doRefundTransaction(refundRequestObj: refundRequest, gatewayData: nil)
		}
		let cancel = UIAlertAction(title: "Cancel Request", style: .cancel, handler: nil)
		alertControl.addAction(processButton)
		alertControl.addAction(cancel)
		
		alertControl.addTextField
		{ (textField) in
			textField.text  =   "$\(self.centToDollar(amount: self.refundResponse.originalTxn?.total ?? 0))"
			textField.keyboardType  =   .decimalPad
			textField.becomeFirstResponder()
		}
		present(alertControl, animated: true, completion: nil)
	}
	
	/**
	 **showGetRefundAmt**
	 
	 This method display a UIAlertController to accept the amount the user wishes to refund.
	 
	 */
	func showGetRefundAmt() {
		let aliasAlertController = UIAlertController(title: "Request Refund", message: "Enter Amount to be Refunded", preferredStyle: .alert)
		
		// Add a text field to the alert controller
		aliasAlertController.addTextField { textField in
			textField.placeholder = "Enter amount"
			textField.keyboardType = .decimalPad // Set keyboard type if needed
		}
		
		// Add action buttons
		let processRefund = UIAlertAction(title: "Process Refund", style: .default) { action in
			// Handle process refund action
			if let textField = aliasAlertController.textFields?.first, let amount = textField.text {
				// Process refund using the entered amount
				print("Refund amount entered: \(amount)")
				self.enteredRefundAmount = amount
				//				self.handleRefundRequest(isForReversal: true)
				self.handleRefundRequest(isForReversal: false)
			}
		}
		
		let cancel = UIAlertAction(title: "Cancel Request", style: .default) { action in
			// Handle cancel action
		}
		
		// Add actions to the alert controller
		aliasAlertController.addAction(processRefund)
		aliasAlertController.addAction(cancel)
		
		// Present the alert controller
		present(aliasAlertController, animated: true, completion: nil)
	}
	
	func centToDollar(amount : Int) -> String
	{
		let valueInFloat = Float(amount)/100
		let stringValue = String(format: "%.2f", valueInFloat)
		return stringValue
	}
	
	func dollarToCent(amount : String) -> Float
	{
		let value = amount.replacingOccurrences(of: "$", with: "")
		let amountInCent = NSString(string: value).floatValue
		return amountInCent
	}
	
	/*
	 // MARK: - Navigation
	 
	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	 // Get the new view controller using segue.destination.
	 // Pass the selected object to the new view controller.
	 }
	 */
	
	func showMessage(inMessage: String)
	{
		
		let msgAlertController = UIAlertController(title: "Transaction Receipt", message: inMessage, preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default)
		{ (alert) in
		}
		msgAlertController.addAction(ok)
		self.present(msgAlertController, animated: true, completion: nil)
	}
}

extension DemoRefundVC : PayrixSDKDelegate
{
	//	func askUserToDorefund(title : String)
	//	{
	//		let alertC = UIAlertController(title: title, message: "Reverse Auth is decliend, want to do Refund?", preferredStyle: .alert)
	//		let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
	//		let refundButton  = UIAlertAction(title: "Do Refund", style: .default) { action in
	//			self.handleRefundRequest(isForReversal: false)
	//		}
	//		alertC.addAction(refundButton)
	//		alertC.addAction(cancelButton)
	//		present(alertC, animated: true)
	//	}
	
	func didReceiveRefundResults(success: Bool!, responseCode: Int!, refundMsg: String!, refundResponse: AnyObject?)
	{
		
		//    - ResponseCodes:
		//      -  0 = Transaction Complete  | Refund Request Completed Successfully
		//      -  1 = Refund Declined       | Refund Declined by Payrix Platform
		//      -  2 = Reversal Declined     | Reversal Declined by Payrix Platform
		//      -  3 = Not Refund Eligible   | The transaction does not meet the criteria for a Refund
		//      -  4 = Refund Eligible       | The transaction does meet the criteria for a Refund
		//      -  5 = Invalid Amt Requested | The amount requested is either zero or greater than amount available
		//      -  6 = Device RevAuth Failed | Device Reverse Auth Declined by Payrix Platform
		//      -  7 = Device RevAuth Success| Device Reverse Auth Approved
		
		
		
		//      -  9 = Unexpected Error      | An unexpected error occured
		if !success
		{
			
			//			if responseCode == 2{
			//				askUserToDorefund(title: refundMsg)
			//			}
			//			else{
			showMessage(inMessage: refundMsg)
			//			}
			return
		}
		else
		{
			//Steve, do we need to check cases other 0, 4 and 7
			switch responseCode
			{
				case 0:
					if let refundRes = refundResponse as? RefundResponse, let txn = refundRes.refundTxn//refundRes.originalTxn
					{
						self.doHandleRefundSuccess(refundTxn: txn)
					}
					else
					{
						let unexpectedError =  "An unexpected error has occurred"
						let processingRefund =  "processing Refund"
						let contactSupport =  "Please contact customer support."
						let message = unexpectedError + " " + processingRefund + ". " + contactSupport
						
						showMessage(inMessage: message)
					}
				case 1:
					let refundDeclined =  "Refund Declined"
					showMessage(inMessage: refundDeclined)
				case 2:
					print("inside case2 - \(refundMsg)")
					//					self.handleRefundRequest(isForReversal: false)
				case 5:
					let invalidReqestedAmount = "The amount requested is either zero or greater than amount available"
					showMessage(inMessage: invalidReqestedAmount)
					
				default:
					showMessage(inMessage: refundMsg)
			}
			
			
			
			return
		}
		
	}
	func didReceiveTxnDataResults(success: Bool!, responseCode: Int!, txnMsg: String!, txnResponse: AnyObject?) {
		/*
		 responseCode:
		 *  1 = Retrieve Specific Txn;
		 *  2 = Retrieve All Txns (for Merchant);
		 *  3 = Retrieve Related (Subsequent) Transactions;
		 *  4 = Check if Transaction is Refund Eligible
		 */
		if responseCode == 3
		{
			if success,
				 let theTxnData = txnResponse as? TxnDataResponse,
				 let transactions = theTxnData.payrixTxns
			{
				self.doHandleRelatedTransSuccess(relatedTrans: transactions)
				self.doCheckRefundEligible()
				return
			}
			else
			{
				self.doCheckRefundEligible()
				return
			}
			
		}
		else if responseCode == 4
		{
			//Due to occasional API issues, we need to add comments to this code as sometimes the refund eligibility cannot be determined.
			if success,
				 let txnDataResponse = txnResponse as? TxnDataResponse,
				 txnDataResponse.txnsRefundEligible ?? false
			{
				self.btnRefund.isHidden = false
				self.btnRefund.isEnabled = true
			}
			else
			{
				self.btnRefund.isHidden = true
				self.btnRefund.isEnabled = false
			}
		}
	}
	
	/**
	 **handleRefundRequest**
	 
	 This method is triggered from the Alert popup which request a refund amount.
	 The entry is then accepted and the next step in the refund process is triggered.
	 
	 */
	func handleRefundRequest(isForReversal : Bool)
	{
		if !enteredRefundAmount.isEmpty//(popupRefundAmt.text != nil) && (popupRefundAmt.text != "")
		{
			let useRefundAmt = self.dollarToCent(amount: enteredRefundAmount)//popupRefundAmt.text!)//Double(popupRefundAmt.text!).
			processRefundRequest(refundAmt: NSNumber(floatLiteral: Double(useRefundAmt)).doubleValue, isReversal: isForReversal)
		}
		else
		{
			processRefundRequest(refundAmt: nil, isReversal: isForReversal)
		}
	}
	
	/**
	 **doHandleRefundSuccess(refundTxn**
	 
	 This method handles a successful response from PayCore in the
	 Refund request.
	 - Parameters:
	 - refundTxn: The resulting New Refund Transaction generated from the Refund request.
	 
	 */
	func doHandleRefundSuccess(refundTxn: PayCoreTxn?)
	{
		if let useTxn = refundTxn
		{
			//      relatedTransactions.append(useTxn)
			relatedTransactions.insert(useTxn, at: 0)
			refreshTransactionDetails()
			self.doCheckRefundEligible()
		}
	}
	
	/**
	 **doHandleRelatedTransSuccess**
	 
	 This method handles the successful retrieval of subsequent transactions.
	 - Parameters:
	 - relatedTrans: An array of Transactions returned from the host request for subsequent transactions
	 */
	func doHandleRelatedTransSuccess(relatedTrans: [PayCoreTxn])
	{
		for transaction in relatedTrans
		{
			self.relatedTransactions.append(transaction)
			refreshTransactionDetails()
		}
	}
	/**
	 **doCheckRefundEligible**
	 
	 This method uses PayCore to check if a transaction is eligible for refund.
	 */
	func doCheckRefundEligible()
	{
		let theTxnRequest = TxnDataRequest.init()
		
		// Set Required Vaules to retrieve all transactions for the merchant
		theTxnRequest.payrixMerchantID = merchantId
		theTxnRequest.payTxn = self.passedTransaction
		theTxnRequest.requestType = 4
		theTxnRequest.pagination = 100
		theTxnRequest.currentPage = 0
		
		
		if useTxnSessionKey{
			theTxnRequest.paySessionKey = nil
			theTxnRequest.useTxnSessionKey = true
			theTxnRequest.payTxnSessionKey = txnSessionKey
		}
		else{
			theTxnRequest.paySessionKey = paySessionKey
			theTxnRequest.useTxnSessionKey = false
			theTxnRequest.payTxnSessionKey = nil
		}
		
		
		theTxnRequest.payrixSandoxDemoMode = true
		payrixSDK.delegate = self
		// Call the method to retrieve the transactions
		payrixSDK.doTransactionDataRequest(txnRequestObj: theTxnRequest)
		
	}
	
	
	
	/**
	 **processRefundRequest**
	 
	 This method invokes a call to PayCore to process a refund.  The response is handled by
	 two subsequent method calls; one for a success response, and one for a failure response.
	 - Parameters:
	 - refundAmt: The amount to be refunded for this transaction
	 
	 */
	
	func processRefundRequest(refundAmt: Double?, isReversal : Bool, isManualTxn: Bool = false, ccNumber : String = "")
	{
		// Data passed to Refund Transaction Request (doRefundTransaction)
		// The Request Type Determines what action to perform
		// 1 = Check if Txn is Refund Eligible
		// 2 = Reserved
		// 3 = Reserved
		// 4 = Reverse Auth / Void
		// 5 = Refund
		let refundRequest = RefundRequest.sharedInstance
		
		refundRequest.payrixMerchantID = merchantId
		refundRequest.refundAmt = Int(Float((refundAmt ?? 0) * 100).rounded())
		refundRequest.payTxn = self.passedTransaction
		
		
		if useTxnSessionKey{
			refundRequest.paySessionKey = nil
			refundRequest.useTxnSessionKey = true
			refundRequest.payTxnSessionKey = txnSessionKey
		}
		else{
			refundRequest.paySessionKey = paySessionKey
			refundRequest.useTxnSessionKey = false
			refundRequest.payTxnSessionKey = nil
		}
		
		
		refundRequest.payrixSandoxDemoMode = true
		refundRequest.originalTxnID = self.passedTransaction.id
		
		if isReversal
		{
			refundRequest.requestType = 4
			self.payrixSDK.doPaymentReversal(refundRequestObj: refundRequest)
		}
		else
		{
			refundRequest.requestType = 5
			refundRequest.refundAmt = Int(Float((refundAmt ?? 0) * 100).rounded())
			self.payrixSDK.doPaymentRefund(refundRequestObj: refundRequest)
		}
	}
}

extension DemoRefundVC : UITableViewDataSource, UITableViewDelegate{
	
	func numberOfSections(in tableView: UITableView) -> Int
	{
		return receiptArray.count + 1
	}
	// MARK: - Table view data source
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		//        if passedTransaction.type == .reverseAuthorization || passedTransaction.type == .refundTransaction
		//        {
		if section > receiptArray.count - 1 || (passedTransaction.type == .reverseAuthorization || passedTransaction.type == .refundTransaction)
		{
			return relatedTransactions.count
		}
		else //if section <= receiptArray.count - 1
		{
			let receiptInSection = receiptArray[section]
			return receiptInSection.count
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		if indexPath.section > receiptArray.count - 1
		{
			return 64
		}
		let receiptInSection = receiptArray[indexPath.section]
		let valueAtIndex = receiptInSection[indexPath.row]
		if valueAtIndex.first?.contains("Signature") ?? false
		{
			return 90//132
		}
		if indexPath.section == receiptArray.count - 1
		{
			return 20//UITableView.automaticDimension
		}
		return 18
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		
		if indexPath.section > receiptArray.count - 1 || (passedTransaction.type == .reverseAuthorization || passedTransaction.type == .refundTransaction)
		{
			let row = indexPath.row
			let transForRow = relatedTransactions[row]
			var cell = UITableViewCell()
			switch transForRow.type?.rawValue
			{
					
				case 4:  // Reverse-Auth
					historyDetailRowHeight = 64.0
					cell = tableView.dequeueReusableCell(withIdentifier: "StandardCell", for: indexPath)
					var useAmt:Double = Double(transForRow.total ?? 00)
					useAmt = useAmt / 100.00
					let useAmtStr = String(format: "%.2f", useAmt)
					
					
					let reverseAuthProcessed = "Reverse-Auth Processed"
					cell.textLabel?.text = "\(reverseAuthProcessed) ($ \(useAmtStr))"//"Reverse-Auth Processed ($ \(useAmtStr))"
					cell.detailTextLabel?.text = "ID: \(transForRow.id ?? "...")"
					
				case 5:  // Refund
					historyDetailRowHeight = 113.0
					let useCell = tableView.dequeueReusableCell(withIdentifier: "RefundCell", for: indexPath) as! HistDetailRefundCell
					var useRefundAmt:Double = Double(transForRow.total ?? 00)
					useRefundAmt = useRefundAmt / 100.00
					useCell.lblRefundAmt.text = String(format: "%.2f", useRefundAmt)
					useCell.lblRefundDate.text = processDateTimeStringFor(transaction: transForRow)
					useCell.lblRefundID.text = transForRow.id
					return useCell
					
				default:
					historyDetailRowHeight = 64.0
					cell = tableView.dequeueReusableCell(withIdentifier: "StandardCell", for: indexPath)
					var useAmt:Double = Double(transForRow.total ?? 00)
					useAmt = useAmt / 100.00
					let useAmtStr = String(format: "%.2f", useAmt)
					
					let txnTypeTitleString =  "Transaction Type"
					cell.textLabel?.text = "\(txnTypeTitleString): \(transForRow.type?.rawValue ?? 00) - \(useAmtStr)"//"Transaction Type: \(transForRow.type?.rawValue ?? 00) - \(useAmtStr)"
					cell.detailTextLabel?.text = "\("ID"): \(transForRow.id ?? "...")"//"ID: \(transForRow.id ?? "...")"
			}
			return cell
			
		}
		let receiptInSection = receiptArray[indexPath.section]
		let valueAtIndex = receiptInSection[indexPath.row]
		
		if valueAtIndex.count == 1
		{
			let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "DefaultTableCell")!
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
			cell.textLabel?.numberOfLines = 0
			cell.selectionStyle = .none
			return cell
		}
		else if valueAtIndex.first?.contains("Signature") ?? false
		{
			//added signature view
			let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "DefaultTableCell")!
			cell.textLabel?.text = "Signature"
			return cell
		}
		else
		{
			let cell : TitleDetailCell = tableView.dequeueReusableCell(withIdentifier: "TitleDetailCell") as! TitleDetailCell
			cell.labelTitle?.text = valueAtIndex.first
			cell.labelDetail?.text = nil
			if valueAtIndex.count == 2
			{
				cell.labelDetail?.text = valueAtIndex.last
			}
			cell.selectionStyle = .none
			return cell
		}
	}
	
	func convertaDateToString(date : Date?) -> String
	{
		if let date = date
		{
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MM/dd/yy, hh:mm a"
			let dateString = dateFormatter.string(from: date)
			return dateString
		}
		return ""
	}
	
	func getStatus(status : Int) -> String
	{
		
		//        case pending = 0
		//        case approved = 1
		//        case failed = 2
		//        case captured = 3
		//        case settled = 4
		//        case returned = 5
		switch status
		{
			case 0:
				return "Pending"
			case 1:
				return "Approved"
			case 2:
				return "Failed"
			case 3:
				return "Captured"
			case 4:
				return "Settled"
			case 5:
				return "Returned"
			default:
				return "Unknown: "
		}
	}
	
	func getType(type : Int) -> String
	{
		//        case saleTransaction = 1
		//        case authTransaction = 2
		//        case captureTransaction = 3
		//        case reverseAuthorization = 4
		//        case refundTransaction = 5
		//        case echeckSaleTransaction = 7
		//        case eCheckRefundTransaction = 8
		//        case echeckPreSaleTransaction = 9
		//        case echeckPreRefundTransaction = 10
		//        case echeckRedepositTransaction = 11
		//        case echeckAccountVerificationTransaction = 12
		switch type
		{
			case 1:
				return "Sale"
			case 2:
				return "Auth"
			case 3:
				return "Capture"
			case 4:
				return "Reverse"
			case 5:
				return "Refund"
			case 7:
				return "eCheck Sale"
			case 8:
				return "eCheck Refund"
			case 9:
				return "eCheck PreSale"
			case 11:
				return "eCheck PreRefund"
			case 12:
				return "eCheck Account Verification"
			default:
				return "Unknown: "
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
	}
	
	/**
	 **processDateTimeStringFor**
	 
	 This method handles the Transaction date into a string.
	 - Parameters:
	 - transaction: The passed Txn
	 - Returns:
	 - Date formatted as a String
	 */
	
	func processDateTimeStringFor(transaction: PayCoreTxn) -> String
	{
		if let date = transaction.created
		{
			return date.dateTimeString()
		}
		else
		{
			return "Unknown"
		}
	}
	
	
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
	{
		return 1
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
	{
		if section > 1
		{
			return nil
		}
		let headerView : UIView = UIView(frame: CGRect.zero)
		let seperatorFrame = CGRect(x: 30, y: 0, width: UIScreen.main.bounds.size.width - 60, height: 1)
		
		let viewSeparator = UIView(frame: seperatorFrame)
		viewSeparator.backgroundColor = UIColor.lightGray
		headerView.addSubview(viewSeparator)
		return headerView
	}
}

