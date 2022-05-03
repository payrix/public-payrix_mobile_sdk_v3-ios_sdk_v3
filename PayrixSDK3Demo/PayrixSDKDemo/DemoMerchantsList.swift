//
//  DemoMerchantsList.swift
//  PayrixSDKDemo
//
//  Created by PRAKASH KOtwal on 23/03/2022.
//  Copyright © 2022 Payrix. All rights reserved.
//

import UIKit
import PayrixSDK
class DemoMerchantsList: UIViewController
{

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableMerchants: UITableView!
    var payMerchants : [PayMerchant] = []
    var filteredPayMerchants : [PayMerchant] = []
    var selectedPayMerchant : PayMerchant!
    
    let sharedUtils = SharedUtilities.init()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        filteredPayMerchants = payMerchants
        tableMerchants.reloadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func goBack(_ sender: Any)
    {
        if selectedPayMerchant != nil
        {
            self.sharedUtils.setIsMerchantSelected(selected: true)
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            sharedUtils.showMessage(theController: self, theTitle: "Please Select Merchant", theMessage: "")
        }
    }
}

extension DemoMerchantsList : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filteredPayMerchants.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MerchantCell", for: indexPath)
        let merchantRow = indexPath.row
        let merchant = filteredPayMerchants[merchantRow]
        cell.textLabel?.text = "Merchant DBA: \(merchant.merchantDBA ?? "")" + "\n" + "Merchant ID: \(merchant.merchantID ?? "")"
        if selectedPayMerchant == merchant
        {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let merchantRow = indexPath.row
        selectedPayMerchant = filteredPayMerchants[merchantRow]
        // Save Merchant Info
        sharedUtils.setMerchantID(merchantKey: selectedPayMerchant.merchantID!)
        sharedUtils.setMerchantDBA(merchantDBA: selectedPayMerchant.merchantDBA!)
        tableView.deselectRow(at: indexPath, animated: true)
        self.tableMerchants.reloadData()
    }
}

extension DemoMerchantsList : UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        filteredPayMerchants = searchText.isEmpty ? payMerchants : payMerchants.filter {
            $0.merchantID!.lowercased().contains(searchText.lowercased()) || $0.merchantDBA!.lowercased().contains(searchText.lowercased())
        }
        self.tableMerchants.reloadData()
    }
}
