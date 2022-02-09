//
//  DeviceListsVC.swift
//  ConfigUpdate2
//
//  Created by Prakash Katwal on 27/10/2021.
//

import UIKit
import CoreBluetooth
import PayrixSDK

class DemoDevices: UIViewController
{

  let sharedUtils = SharedUtilities.init()
    var bbposDevices : [PayDevice] = []
  var payDevice = PayDevice.sharedInstance
    var scanTimer: Timer!
  /**
  * Instantiate PayCardRDRMgr  (Step 1)
  * This is the 1st step of the Bluetooth scanning process.
  * PayCard handles communication with the Bluetooth reader device.
  */
    let payrixOTA = PayrixOTA.sharedInstance
    let payrixSDK = PayrixSDK.sharedInstance
    
    var deviceDetails : [String : Any] = [:]
    
//    let deviceControllerBBPOS = DeviceControllerBBPOS.sharedInstance
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deviceListTable: UITableView!
    
  
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    /*
    * Start PayrixSDK  (Step 2)
    * This step establishes the necessary connections for Callback processing and
    * initializes key PayrixSDK parameters.
    */
        
    payrixOTA.delegate = self
      payrixSDK.delegate = self
      
    let isSandBox =  sharedUtils.getSandBoxOn()!
    let theEnv =  sharedUtils.getEnvSelection()!
    payrixSDK.doSetPayrixPlatform(platform: theEnv, demoSandbox: isSandBox, deviceManfg: nil)
      
      
      
      activityIndicator.startAnimating()
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5)
      {
          self.doScanReaders()
          self.startScanTimer()
      }
  }
    /**
     **startScanTimer**
     
     This method starts the timer for the app to wait for a device scan to complete
     *   The timer is set to 25 seconds
     
     */
    func startScanTimer()
    {
      scanTimer = Timer.scheduledTimer(timeInterval: 25, target: self, selector: #selector(scanTimeExpired), userInfo: nil, repeats: false)
    }
    
    
    /**
     **scanTimeExpired**
     
     This method is triggered when the Scan timer expires.
     The expiration message is displayed
     
     */
    @objc func scanTimeExpired()
    {
      payrixSDK.doStopBTScan()
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        payrixSDK.doDisconnectBTReader()
//        deviceControllerBBPOS.disconnectBTReader()
    }
    
    @IBAction func goback(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doReloadDevices(_ sender: Any)
    {
        doScanReaders()
    }
    
    func doScanReaders()
    {
        payrixOTA.doOTAScanForReaders()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueUpdateBBPos"
        {
            let destination : DemoUpdate = segue.destination as! DemoUpdate
//            destination.connectedDevice  = payDevice
            destination.deviceDetails = deviceDetails
        }
    }
    

}

extension DemoDevices : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return bbposDevices.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let device : PayDevice = bbposDevices[indexPath.row]
        cell.textLabel?.text = device.deviceSerial
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        activityIndicator.startAnimating()
        deviceListTable.isUserInteractionEnabled = false
        
        let aDevice = bbposDevices[indexPath.row]
        payDevice = aDevice
        payrixOTA.doOTAConnectReader(payDeviceObj: payDevice)
        
        deviceListTable.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerLabel = UILabel()
        headerLabel.text = "Select Device"
        headerLabel.textAlignment = .center
        return headerLabel
        
    }
}


extension DemoDevices : OTAUpdateDelegate
{
    func didReceiveRemoteKeyInjectionResult(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!) {
        
    }
    
    func didReceiveRemoteFirmwareUpdate(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!) {
        
    }
    
    func didReceiveRemoteConfigUpdate(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!) {
        
    }
    
    func didReceiveLocalFirmwareUpdate(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!) {
        
    }
    
    func didReceiveLocalConfigUpdate(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!) {
        
    }
    
    func didReceiveTargetVersionResult(success: Bool, otaResult: BBDeviceOTAResult, otaData: [AnyHashable : Any]!) {
        
    }
    
    func didReceiveSetTargetVersionResult(success: Bool, otaResult: BBDeviceOTAResult, otaMessage: String!) {
        
    }
    
    func didReceiveTargetVersionListResult(success: Bool, otaResult: BBDeviceOTAResult, otaList: [Any]!, otaMessage: String!) {
        
    }
    
    func didReceiveOTAProgress(percentProgress: Float) {
        
    }
    
    func didReceiveOTADisconnectResults(success: Bool!) {
        
    }
    
    
    
    func didReceiveOTAScanResults(success: Bool!, scanMsg: String!, payDevices: [AnyObject]?)
    {
        if success
        {
            if let useDevices = payDevices
            {
              let rdrDevices = useDevices as! [PayDevice]
                
                
                self.bbposDevices.removeAll()
                for aDevice in rdrDevices
                {
                    self.bbposDevices.append(aDevice)
                }
                self.deviceListTable.reloadData()
            }
        }
        else
        {
            sharedUtils.showMessage(theController: self, theTitle: "OTAScanResults", theMessage: scanMsg)
        }
        activityIndicator.stopAnimating()
          
    }
    
    func didReceiveOTAConnectResults(success: Bool!, theDevice: String!)
     {
         print("device conneted")
      if success
      {
          payrixSDK.delegate = self
       payrixSDK.doGetDeviceInfo()
      }
      else
      {
          activityIndicator.stopAnimating()
       sharedUtils.showMessage(theController: self, theTitle: "OTAConnectResults", theMessage: "Device not connected.")
      }
     }
}

//extension DemoDevices : DeviceControlBBPOSDelegate
//{
//    func didBTConnect()
//    {
//        print("device connected")
//    }
//
//    func didBTDisconnect()
//    {
//        activityIndicator.stopAnimating()
//        deviceListTable.isUserInteractionEnabled = true
//        sharedUtils.showMessage(theController: self, theTitle: "Device dis connected", theMessage: "")
//    }
//
//    func didBTTimeout()
//    {
//        activityIndicator.stopAnimating()
//        deviceListTable.isUserInteractionEnabled = true
//        sharedUtils.showMessage(theController: self, theTitle: "Device time out.", theMessage: "")
//    }
//
//    func didReturnDeviceData(deviceInfo: [AnyHashable : Any]!)
//    {
//        activityIndicator.stopAnimating()
//        deviceListTable.isUserInteractionEnabled = true
//        deviceDetails = deviceInfo as? [String : AnyObject] ?? [:]
//        print("device details: \(deviceDetails)")
//        self.performSegue(withIdentifier: "segueUpdateBBPos", sender: nil)
//    }
//
//    func didReturnDevError(errorType: Int, errorMessage: String)
//    {
//        activityIndicator.stopAnimating()
//        deviceListTable.isUserInteractionEnabled = true
//        sharedUtils.showMessage(theController: self, theTitle: "Error from Device", theMessage: errorMessage)
//    }
//}

extension DemoDevices : PayrixSDKDelegate
{
    func didReceiveOTADeviceData(deviceInfo: [AnyHashable : Any]!)
    {
        
        activityIndicator.stopAnimating()
        deviceListTable.isUserInteractionEnabled = true
        deviceDetails = deviceInfo as? [String : AnyObject] ?? [:]
        print("device details: \(deviceDetails)")
        self.performSegue(withIdentifier: "segueUpdateBBPos", sender: nil)
    }
}
