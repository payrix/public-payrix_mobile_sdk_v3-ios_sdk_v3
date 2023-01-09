//
//  DemoScanBT.swift
//  PayrixSDKDemo
//
//  Created by Steve Sykes on 7/22/20.
//  Copyright © 2020 Payrix. All rights reserved.
//

import UIKit
import PayrixSDK

class DemoScanBT: UIViewController, PayrixSDKDelegate
{

  @IBOutlet weak var btnBack: UIButton!
  @IBOutlet weak var btnScan: UIButton!
  @IBOutlet weak var lblScanLog: UITextView!
  @IBOutlet weak var lblSelectedReader: UILabel!
  @IBOutlet weak var tblReaders: UITableView!
  
  var deviceCounter = 0
  var scanTimer: Timer!
//  var setOfDevices = Set<String>()
  var readerDevices : [PayDevice] = []
  var selectedReader : PayDevice!
  
  let sharedUtils = SharedUtilities.init()
  var payDevice = PayDevice.sharedInstance
  
  /**
  * Instantiate PayCardRDRMgr  (Step 1)
  * This is the 1st step of the Bluetooth scanning process.
  * PayCard handles communication with the Bluetooth reader device.
  */
  let payrixSDK = PayrixSDKMaster.sharedInstance
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    /*
    * Start PayrixSDK  (Step 2)
    * This step establishes the necessary connections for Callback processing and
    * initializes key PayrixSDK parameters.
    */
        
    payrixSDK.delegate = self
    let isSandBox =  sharedUtils.getSandBoxOn()!
    let theEnv =  sharedUtils.getEnvSelection()!
    payrixSDK.doSetPayrixPlatform(platform: theEnv, demoSandbox: isSandBox, deviceManfg: nil)
  }
  
  @IBAction func goConnect(_ sender: Any)
  {
    if let reader = selectedReader
    {
      payrixSDK.doConnectBTReader(payDeviceObj: reader)
    }
    else
    {
      let useMsg = lblScanLog.text + "No Reader Selected"
      updateLog(newMessage: useMsg)
      lblScanLog.text = useMsg + "\n"
    }
    
  }
  
  @IBAction func goBack(_ sender: Any)
  {
    self.dismiss(animated: true, completion: nil)
  }
  
  /**
  **goScan**
  (Step 3)
  The PayCardReader class handles BT related activities.
  Here the method: scanForReaders is invoked to start the BT scanning (search) process
  for eligible BT Card Readers.
  The results are returned in either Callback: didFindRDRDevices, didReceiveBTScanTimeOut, or didReceiveCardReaderError.
  
  - Parameters:
    - sender: This represents the button object
  */
  @IBAction func goScan(_ sender: Any)
  {
    lblScanLog.text = "Scanning... \n"
    payrixSDK.delegate = self
    payrixSDK.doScanForBTReaders()
    // startScanTimer()
  }
  
  
  /**
  * didReceiveScanResults (Step 4)
   Is the callback for PayCard scanForReaders.
   The located BT card reader devices are returned in this callback.
  
   In this demo app the found device are displayed in the UI log and the first item in the
   list is saved for use in the transaction processing step.
  
   - Parameters:
      - rdrDevices: An array of Strings with the device names
      - btUUIDs: a dictionary (Key-Value pair) Bluetooth UUIDs of the devices
      - manfgNames: a dictionary (Key-Value pair) device manufacturers
  */
  public func didReceiveScanResults(scanSuccess: Bool!, scanMsg: String!, payDevices: [AnyObject]?)
  {
    var useMsg: String = lblScanLog.text
    if scanSuccess
    {
      if let useDevices = payDevices
      {
        let rdrDevices = useDevices as! [PayDevice]
        self.readerDevices = rdrDevices
        self.tblReaders.reloadData()
        
        for aDevice in rdrDevices
        {
          let useMsg = lblScanLog.text + "BT Scanner Located: " + aDevice.deviceSerial!
          updateLog(newMessage: useMsg)
          lblScanLog.text = useMsg + "\n"
        }
        
        
      }
      else
      {
        
        useMsg = useMsg + "No Devices found."
        lblScanLog.text = useMsg + "\n"
      }
    }
    else
    {
      useMsg = useMsg + "The automatic connection of the Card Reader was unsuccessful."
      lblScanLog.text = useMsg + "\n"
    }
    
//    if let useDevices = payDevices
//    {
//      let rdrDevices = useDevices as! [PayDevice]
//
//      for aDevice in rdrDevices
//      {
//        if setOfDevices.contains(aDevice.deviceSerial ?? "")
//        {
//          // Do Nothing; Previously Found
//        }
//        else
//        {
//          setOfDevices.insert(aDevice.deviceSerial ?? "")
//          let useMsg = "BT Scanner Located: " + aDevice.deviceSerial!
//          updateLog(newMessage: useMsg)
//
//          if deviceCounter == 0
//          {
//            payDevice = aDevice
//            sharedUtils.setBTReader(btReaderKey: aDevice.deviceSerial ?? "")
//            sharedUtils.setBTManfg(btManfgKey: aDevice.deviceManfg ?? "")
//            lblSelectedReader.text = aDevice.deviceSerial ?? ""
//          }
//        }
//        deviceCounter = deviceCounter + 1
//      }
//    }
  }
  
  /**
   **didReceiveBTConnectResults**
   (Step 6a)
   This is the callback for the BT Connect request.  Once the device is connected the transaction can be processed.
   */
  public func didReceiveBTConnectResults(connectSuccess: Bool!, theDevice: String!)
  {
    var useMsg: String = lblScanLog.text
    // Handle Successful Connection
    if connectSuccess
    {
      useMsg = useMsg + "Connected to: \(selectedReader.deviceSerial!)"
      lblScanLog.text = useMsg + "\n"
    }
    else
    {
      var useMsg: String = lblScanLog.text
      useMsg = useMsg + "BT CONNECTION FAILED: Device: " + theDevice
      lblScanLog.text = useMsg + "\n"
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
    var useMsg: String = lblScanLog.text
    
    useMsg = useMsg + "\n\n" + "Scan Complete: " + String(deviceCounter) + " devices located"
    print(useMsg)
    lblScanLog.text = useMsg + "\n"
  }
  
  /**
  **updateLog**
  * This method updates the UI Log of authentication events
  - Parameters:
    - newMessage: The String message to be displayed
  */
  private func updateLog(newMessage: String)
  {
    var currentLog = lblScanLog.text
    currentLog = currentLog! + "\n" + newMessage
    print(currentLog!)
    lblScanLog.text = currentLog! + "\n"
  }
}


extension DemoScanBT : UITableViewDataSource, UITableViewDelegate
{
  func numberOfSections(in tableView: UITableView) -> Int
  {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return readerDevices.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
    let reader = readerDevices[indexPath.row]
    cell.textLabel?.text = "Reader: \(reader.deviceSerial ?? "")"
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
  {
    let aDevice = readerDevices[indexPath.row]
    selectedReader = aDevice
    sharedUtils.setBTReader(btReaderKey: aDevice.deviceSerial ?? "")
    sharedUtils.setBTManfg(btManfgKey: aDevice.deviceManfg ?? "")
    lblSelectedReader.text = aDevice.deviceSerial ?? ""
  }
}

