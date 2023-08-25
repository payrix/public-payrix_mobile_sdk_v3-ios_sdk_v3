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
  var payDevices : [PayDevice] = []
  
  var scanTimer: Timer!
  var secondsCount : Int = 0
  /**
   * Instantiate PayCardRDRMgr  (Step 1)
   * This is the 1st step of the Bluetooth scanning process.
   * PayCard handles communication with the Bluetooth reader device.
   */
  let payrixOTA = PayrixOTA.sharedInstance
  let payrixSDK = PayrixSDKMaster.sharedInstance
  
  var deviceDetails : [String : Any] = [:]
  
  //    let deviceControllerBBPOS = DeviceControllerBBPOS.sharedInstance
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var deviceListTable: UITableView!
  
  @IBOutlet weak var lblDeviceStatus: UILabel!
  
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
    
    self.lblDeviceStatus.text = "Searching for Readers"
  }
  /**
   Setting up PayrixOTA
   Adding the delegate methods so that we can get events triggered from PayrixOTA class
   Start activity indicator till payrixOTA disconnect any other connected devices
   */
  func setUpOTA()
  {
    activityIndicator.startAnimating()
    payrixOTA.doOTADisconnectAnyDevice()
    //Uncomment below line to get logs from BBPOS as well as the PayrixOTA
//    payrixOTA.setDebugLog(enable: true)
    payrixOTA.delegate = self
    //till app is not getting list of devices we need to clan the tableview so that user wont click on previous set of devices what may be disconnected
    self.payDevices.removeAll()
    self.deviceListTable.reloadData()
  }
  /**
   Scanning for all devices what are nearby
   */
  func scanForReaders()
  {
    self.deviceListTable.isHidden = true
    self.lblDeviceStatus.isHidden = false
    self.lblDeviceStatus.text = "Searching for Readers"
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5)
    {
      self.payrixOTA.doOTAScanForReaders()
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
    
    scanTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(doCountSeconds), userInfo: nil, repeats: true)
  }
  
  /**
   **scanTimeExpired**
   This method is triggered when the with each seconds elapsed and we can make code by counting seconds
   
   */
  @objc func doCountSeconds()
  {
    secondsCount += 1
    updateInfoMessage()
  }
  
  func updateInfoMessage()
  {
    var infoMessage = "Searching for Readers"
    if secondsCount > 19
    {
      infoMessage =  "No Readers Located. Tap Refresh in upper right to search again"
      scanTimer.invalidate()
      secondsCount = 0
      activityIndicator.stopAnimating()
      payrixSDK.doStopBTScan()
    }
    else if secondsCount > 9
    {
      infoMessage =  "Please confirm that Card Readers are on, charged and in range"
    }
    lblDeviceStatus.text = infoMessage
  }
  
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    secondsCount = 0
    setUpOTA()
  }
  
  @IBAction func goback(_ sender: Any)
  {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func doReloadDevices(_ sender: Any)
  {
    secondsCount = 0
    setUpOTA()
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
    return payDevices.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
    let device : PayDevice = payDevices[indexPath.row]
    cell.textLabel?.text = device.deviceSerial
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
  {
    activityIndicator.startAnimating()
    deviceListTable.isUserInteractionEnabled = false
    
    let aDevice = payDevices[indexPath.row]
    payrixOTA.doOTAConnectReader(payDeviceObj: aDevice)
    
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
  
  func didReceiveOTADisconnectResults(success: Bool!)
  {
    print("disconnected")
    self.scanForReaders()
  }
  
  
  
  func didReceiveOTAScanResults(success: Bool!, scanMsg: String!, payDevices: [AnyObject]?)
  {
    if success
    {
      if let useDevices = payDevices
      {
        let rdrDevices = useDevices as! [PayDevice]
        
        
        self.payDevices.removeAll()
        for aDevice in rdrDevices
        {
          self.payDevices.append(aDevice)
        }
        self.lblDeviceStatus.isHidden = true
        self.deviceListTable.isHidden = false
        self.deviceListTable.isUserInteractionEnabled = true
        self.scanTimer.invalidate()
        
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
