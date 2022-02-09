//
//  ApplicationSelectionVC.swift
//  PayrixSDKDemo
//
//  Created by PRAKASH on 4/22/21.
//  Copyright © 2021 Payrix. All rights reserved.
//

import UIKit
//After selecting the app this delegate will work for passing selected app to DemoTransaction class
protocol AppSelectedDelegate
{
    func selected(app : [String : Int])
}

class ApplicationSelectionVC: UIViewController
{
    //delegate to select app
    var delegateAppSelection : AppSelectedDelegate!
    
    //get the list of applications in the dictionary
    var appsSelectionArray : [[String : Int]] = []

    //Selected index for application, to pass it on SDK
    var selectedApplication : [String : Int] = [:]
    //Tableview to show the list of Applications, where user can select the desired application
    @IBOutlet weak var tableViewApplication: UITableView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //clear seperator for empty cell
        tableViewApplication.tableFooterView = UIView()
    }
    

    @IBAction func goBack(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionPassSelectedApp(_ sender: Any)
    {
        if !self.selectedApplication.isEmpty
        {
            self.dismiss(animated: true)
            {
                self.delegateAppSelection.selected(app: self.selectedApplication)
            }
            
        }
    }
    
}

extension ApplicationSelectionVC : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return appsSelectionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let keyValue = appsSelectionArray[indexPath.row]
        cell.textLabel?.text = keyValue.keys.first ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        selectedApplication = appsSelectionArray[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}
