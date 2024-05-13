//
//  DemoRefundVC.swift
//  PayrixSDKDemo
//
//  Created by PRAKASH on 5/16/21.
//  Copyright © 2021 Payrix. All rights reserved.
//

import UIKit
import PayrixSDK

class DemoRefundList: UIViewController {
	//show activity indicator till loading from webview
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	//list of txn datas
	@IBOutlet weak var tableView: UITableView!
	//list of txns that can be shown on tablview
	var txnLists : [PayCoreTxn] = []
	//selectedTxn to pass to detailview
	var selectedTxn : PayCoreTxn!
	
	var payrixSDK = PayrixSDKMaster.sharedInstance
	//set this key to true or false to use TxnSessionKey for transactions
	var useTxnSessionKey : Bool!
	var merchantId : String!
	var txnSessionKey : String?
	var paySessionKey : String?
	
	private var currentPage : Int = 1
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		doVerifyTxnKeyType()
		tableView.tableFooterView = UIView()
	}
	
	func doVerifyTxnKeyType()
	{
		let theTxnRequest = TxnDataRequest.init()
		theTxnRequest.pagination = 20
		theTxnRequest.currentPage = currentPage
		theTxnRequest.payrixMerchantID = merchantId
		theTxnRequest.useTxnSessionKey = useTxnSessionKey
		theTxnRequest.payrixSandoxDemoMode = true
		theTxnRequest.requestType = 2
		payrixSDK.delegate = self
		print("txn session key: \(txnSessionKey)")
		if useTxnSessionKey {
			guard let txnSessionKey = txnSessionKey
			else
			{
				print("No Txn SessionKey Found")
				showMessage(inMessage: "No Txn SessionKey Found")
				return
			}
			print("Txn SessionKey Found")
			theTxnRequest.paySessionKey = nil
			theTxnRequest.payTxnSessionKey = txnSessionKey
			// Call the method to retrieve the transactions
			payrixSDK.doTransactionDataRequest(txnRequestObj: theTxnRequest)
		}
		else if let paySessionKey = paySessionKey
		{
			print("Pay SessionKey Found")
			theTxnRequest.payTxnSessionKey = nil
			theTxnRequest.paySessionKey = paySessionKey
			// Call the method to retrieve the transactions
			payrixSDK.doTransactionDataRequest(txnRequestObj: theTxnRequest)
		}
		else
		{
			showMessage(inMessage: "PaySession Key or TxnSession Key is empty")
			print("PaySession Key or TxnSession Key is empty")
		}
	}
	
	
	@IBAction func doGetMoreTxns(_ sender: Any)
	{
		currentPage += 1
		doVerifyTxnKeyType()
		
	}
	
	@IBAction func goBack(_ sender: Any)
	{
		self.dismiss(animated: true, completion: nil)
	}
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		// Get the new view controller using segue.destination.
		// Pass the selected object to the new view controller.
		if segue.identifier ==  "SegToRefund"
		{
			let destination = segue.destination as! DemoRefundVC
			let refundRes = RefundResponse.sharedInstance
			refundRes.originalTxn = selectedTxn
			destination.refundResponse = refundRes
			destination.passedTransaction = selectedTxn
			
			destination.txnSessionKey = txnSessionKey
			destination.useTxnSessionKey = useTxnSessionKey
			destination.paySessionKey = paySessionKey
			destination.merchantId  = merchantId
			
		}
	}
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

extension DemoRefundList : UITableViewDataSource, UITableViewDelegate{
	
	
	// MARK: - Table view data source
	
	func numberOfSections(in tableView: UITableView) -> Int
	{
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return txnLists.count
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		let model = txnLists[indexPath.row]
		let name = (model.first ?? "") + (model.last ?? "")
		cell.textLabel?.text    = name
		cell.detailTextLabel?.text  =   "Amount: $\(self.centToDollar(amount: model.total ?? 0))\nDate: \(self.convertaDateToString(date: model.created))"
		return cell
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		self.selectedTxn = txnLists[indexPath.row]
		self.performSegue(withIdentifier: "SegToRefund", sender: self)
		tableView.deselectRow(at: indexPath, animated: true)
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
	
	func centToDollar(amount : Int) -> String
	{
		let valueInFloat = Float(amount)/100
		let stringValue = String(format: "%.2f", valueInFloat)
		return stringValue
	}
}

extension DemoRefundList : PayrixSDKDelegate{
	func didReceiveTxnDataResults(success: Bool!, responseCode: Int!, txnMsg: String!, txnResponse: AnyObject?) {
		if success,
			 let payTxn = txnResponse as? TxnDataResponse,
			 let payCoreTxns = payTxn.payrixTxns
		{
			let newTxns : [PayCoreTxn]  =   payCoreTxns.sorted( by: { $0.authDate ?? 0 >  $1.authDate ?? 0} )
			self.txnLists.append(contentsOf: newTxns)
			self.tableView.reloadData()
		}
		else
		{
			self.showMessage(inMessage: txnMsg)
		}
		self.activityIndicator.stopAnimating()
	}	
}
