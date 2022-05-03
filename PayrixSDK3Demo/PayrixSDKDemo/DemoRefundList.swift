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
    let sharedUtils = SharedUtilities.init()
    //list of txns that can be shown on tablview
    var txnLists : [PayCoreTxn] = []
    //selectedTxn to pass to detailview
    var selectedTxn : PayCoreTxn!
    
    var payrixSDK = PayrixSDKMaster.sharedInstance
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let txnRequest = TxnDataRequest.sharedInstance
        txnRequest.requestType  =   3//type 3 is for Retrieve Refund Ready Txns
        txnRequest.payrixMerchantID =   sharedUtils.getMerchantID() ?? ""
        payrixSDK.delegate = self
        payrixSDK.doTransactionDataRequest(txnRequestObj: txnRequest)
        tableView.tableFooterView = UIView()
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
        }
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
    func didReceiveTxnResults(success: Bool!, responseCode: Int!, txnMsg: String!, txnResponse: AnyObject?)
    {
        if success,
           let payTxn = txnResponse as? TxnDataResponse,
           let payCoreTxns = payTxn.payrixTxns
        {
            self.txnLists   =   payCoreTxns.sorted( by: { $0.authDate ?? 0 >  $1.authDate ?? 0} )
            self.tableView.reloadData()
        }
        self.activityIndicator.stopAnimating()
    }
}
