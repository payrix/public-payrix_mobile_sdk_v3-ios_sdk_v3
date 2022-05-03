//
//  DemoRefundVC.swift
//  PayrixSDKDemo
//
//  Created by PRAKASH on 5/20/21.
//  Copyright © 2021 Payrix. All rights reserved.
//

import UIKit
import PayrixSDK

class DemoRefundVC: UIViewController {
    let txnList : [String] = ["Amount:", "Card Type:", "Last 4:", "Transaction Type:", "Status:", "Date:", "ID:"]
    let amountList : [String] = ["Sale Amount:", "Tax:", "Total:"]
    let refundList : [String] = ["Refund Amount:", "Refund Date:", "Refund ID:"]
    
    var refundResponse : RefundResponse!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnRefund: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let sharedUtils = SharedUtilities.init()
    var payrixSDK = PayrixSDKMaster.sharedInstance
    
    //second section is for "Sale Amount:", "Tax:", "Total:", these values are only available when the transaction is not a refund from previous class
    var showSecondSection = true
    //thirdsection is showing response after requesting for refund from this class, so initially this is hidden at all and if txn is refund ready and requested after that we are getting success from delegate then only third section can be visisble.
    var showThirdSection = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //        1 = Check if Txn is Refund Eligible;
        //        2 = Reserved;
        //        3 = Reserved;
        //        4 = Reverse Auth / Void;
        //        5 = Refund;
        btnRefund.isHidden  =   true
        if let refundAmount = refundResponse.originalTxn?.refunded, refundAmount > 0
        {
            showSecondSection = false
            showThirdSection = true
            // print("this is refund transaction, so we do not need to call any api to if this can be refunded anymore")
        }
        else
        {
            showSecondSection = true
            showThirdSection = false
            payrixSDK.delegate  =   self
            let refundRequest = RefundRequest.sharedInstance
            refundRequest.paySessionKey = sharedUtils.getSessionKey() ?? ""
            refundRequest.payTxn = refundResponse.originalTxn
            refundRequest.requestType = 1
            payrixSDK.doRefundTransaction(refundRequestObj: refundRequest, gatewayData: nil)
        }
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
          refundRequest.paySessionKey = self.sharedUtils.getSessionKey() ?? ""
          refundRequest.payTxn = self.refundResponse.originalTxn
          refundRequest.requestType = 5
          refundRequest.payrixMerchantID = self.sharedUtils.getMerchantID() ?? ""
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
    
}


extension DemoRefundVC : UITableViewDataSource, UITableViewDelegate{
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if section == 0
        {
            if showSecondSection
            {
                return txnList.count
            }
            else
            {
                return 3
            }
        }
        else if section == 1
        {
            return showSecondSection ? amountList.count : 0
        }
        else
        {
            return showThirdSection ? amountList.count : 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
{
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if indexPath.section == 0
        {
            cell.textLabel?.text    = txnList[indexPath.row]
            //        ["Card Type:", "Card Number:", "Transaction Type:", "Status:", "Date:", "ID:"]
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text  =   ""
                if !showSecondSection
                {
                    cell.textLabel?.text =  "$(-\(self.centToDollar(amount: refundResponse.originalTxn?.refunded ?? 0)))"
                }
                else
                {
                    cell.textLabel?.text = self.centToDollar(amount: refundResponse.originalTxn?.total ?? 0)
                }
            case 1:
                let cardType = PaySharedAttributes.CCType(rawValue: refundResponse.originalTxn?.payment?.method?.rawValue ?? 0)
                cell.detailTextLabel?.text = sharedUtils.getCardName(cardType: cardType!)
            case 2:
                cell.detailTextLabel?.text = refundResponse.originalTxn?.payment?.number ?? ""
            case 3:
                cell.detailTextLabel?.text = getType(type: refundResponse.originalTxn?.type?.rawValue ?? 0)
            case 4:
                cell.detailTextLabel?.text = getStatus(status: refundResponse.originalTxn?.status?.rawValue ?? 0)
            case 5:
                cell.detailTextLabel?.text  =   self.convertaDateToString(date: refundResponse.originalTxn?.created)
            case 6:
                cell.detailTextLabel?.text = refundResponse.originalTxn?.id
            default:
                print("all data are sorted")
            }
        }
        else if indexPath.section == 1 && showSecondSection
        {
            cell.textLabel?.text    = amountList[indexPath.row]
            let totalAmount = refundResponse.originalTxn?.total ?? 0
            let taxAmount = refundResponse.originalTxn?.tax ?? 0
            //            , "Sale Amount:", "Tax:", "Total:"]
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text  =   "$\(self.centToDollar(amount: (totalAmount - taxAmount)))"
            case 1:
                cell.detailTextLabel?.text  =   "$\(self.centToDollar(amount: taxAmount))"
            case 2:
                cell.detailTextLabel?.text  =   "$\(self.centToDollar(amount: totalAmount))"
            default:
                print("all data are sorted")
            }
        }
        else if indexPath.section == 2
        {
            cell.textLabel?.text    = refundList[indexPath.row]
//            ["Refund Amount:", "Refund Date:", "Refund ID:"]
            switch indexPath.row {
            case 0:
                if showSecondSection
                {
                    cell.detailTextLabel?.text  =   "$\(self.centToDollar(amount: refundResponse.refundTxn?.total ?? 0))"
                }
                else
                {
                    cell.detailTextLabel?.text  =   "$\(self.centToDollar(amount: refundResponse.originalTxn?.refunded ?? 0))"
                }
                
            case 1:
                if showSecondSection
                {
                    cell.detailTextLabel?.text  =   self.convertaDateToString(date: refundResponse.refundTxn?.created)
                }
                else
                {
                    cell.detailTextLabel?.text  =   self.convertaDateToString(date: refundResponse.originalTxn?.created)
                }
            case 2:
                if showSecondSection
                {
                    cell.detailTextLabel?.text  =   self.refundResponse.refundTxn?.id ?? ""
                }
                else
                {
                    cell.detailTextLabel?.text  =   self.refundResponse.originalTxn?.id ?? ""
                    
                }
                
            default:
                print("all data are sorted")
            }
        }
        return cell
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
    
}

extension DemoRefundVC : PayrixSDKDelegate
{
    
//    func didReceiveRefundResults(success: Bool!, responseCode: Int!, refundMsg: String!, refundResponse: AnyObject?)
//    {
//      if success
//      {
//        self.btnRefund.isHidden =   false
//        if let refundResponse = refundResponse as? RefundResponse, refundResponse.refundTransactionID != nil
//        {
//            self.btnRefund.isHidden =   true
//            self.showSecondSection = true
//            self.showThirdSection = true
//            self.refundResponse = refundResponse
//            self.tableView.reloadData()
//        }
//      }
//      else
//      {
//
//      }
//
//      self.activityIndicator.stopAnimating()
//    }
}
