//
//  DeviceDetailVC.swift
//  ConfigUpdate2
//
//  Created by Prakash Katwal on 27/10/2021.
//

import UIKit
import CoreBluetooth
import PayrixSDK

class DemoDeviceDetailVC: UIViewController {
  @IBOutlet weak var tableDetail: UITableView!
  
  var deviceDetails : [String : Any] = [:]
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    self.title = deviceDetails["serialNumber"] as? String ?? ""
  }
  
  @IBAction func goBack(_ sender: Any)
  {
    self.navigationController?.popViewController(animated: true)
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



extension DemoDeviceDetailVC : UITableViewDataSource, UITableViewDelegate
{
  func numberOfSections(in tableView: UITableView) -> Int
  {
    return 1
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return deviceDetails.keys.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
    let arrayOfKeys = Array(deviceDetails.keys.map{ $0 })
    let deviceKey = arrayOfKeys[indexPath.row]
    cell.textLabel?.text = deviceKey
    cell.detailTextLabel?.text = deviceDetails[deviceKey] as? String ?? ""
    cell.selectionStyle = .none
    return cell
  }
}
