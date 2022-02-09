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
  
  var deviceCounter = 0
  var scanTimer: Timer!
  var setOfDevices = Set<String>()
  
  let sharedUtils = SharedUtilities.init()
  var payDevice = PayDevice.sharedInstance
  
  /**
  * Instantiate PayCardRDRMgr  (Step 1)
  * This is the 1st step of the Bluetooth scanning process.
  * PayCard handles communication with the Bluetooth reader device.
  */
  let payrixSDK = PayrixSDK.sharedInstance
  
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
    if let useDevices = payDevices
    {
      let rdrDevices = useDevices as! [PayDevice]
      
      for aDevice in rdrDevices
      {
        if setOfDevices.contains(aDevice.deviceSerial ?? "")
        {
          // Do Nothing; Previously Found
        }
        else
        {
          setOfDevices.insert(aDevice.deviceSerial ?? "")
          let useMsg = "BT Scanner Located: " + aDevice.deviceSerial!
          updateLog(newMessage: useMsg)
          
          if deviceCounter == 0
          {
            payDevice = aDevice
            sharedUtils.setBTReader(btReaderKey: aDevice.deviceSerial ?? "")
            sharedUtils.setBTManfg(btManfgKey: aDevice.deviceManfg ?? "")
            lblSelectedReader.text = aDevice.deviceSerial ?? ""
          }
        }
        deviceCounter = deviceCounter + 1
      }
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
    lblScanLog.text = useMsg
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
    lblScanLog.text = currentLog
  }
}
