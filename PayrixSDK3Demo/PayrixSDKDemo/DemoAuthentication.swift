//
//  DemoAuthentication.swift
//  PayrixSDKDemo
//
//  Created by Steve Sykes on 7/22/20.
//  Copyright © 2020 Payrix. All rights reserved.
//

import UIKit
import PayrixSDK

class DemoAuthentication: UIViewController, UITextFieldDelegate, PayrixSDKDelegate
{
  @IBOutlet weak var txtUserID: UITextField!
  @IBOutlet weak var txtUserPwd: UITextField!
  @IBOutlet weak var lblResults: UITextView!
  
  @IBOutlet weak var btnBack: UIButton!
  @IBOutlet weak var btnAuthenticate: UIButton!
  
  let sharedUtils = SharedUtilities.init()
    var payMerchants : [PayMerchant] = []
  
  /**
  * Step 1: Instantiate the PayCoreMaster instance.  This class handles authentication.
  */
  let payrixSDK = PayrixSDKMaster.sharedInstance
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    
    /*
    * Step 2:
    * a. Set the host URL
    * b. Set Demo - Sandbox mode
    */
    
    let isSandBox =  sharedUtils.getSandBoxOn()!
    let theEnv =  sharedUtils.getEnvSelection()!
    
    payrixSDK.doSetPayrixPlatform(platform: theEnv, demoSandbox: isSandBox, deviceManfg: nil)
        
    sharedUtils.setDemoMode(modeKey: isSandBox)
      if sharedUtils.getIsMerchantSelected()
      {
          let logMsg = "Authentication Successful: \n" + "- Merchant ID: " + sharedUtils.getMerchantID()! + "\n- Merchant DBA: " + sharedUtils.getMerchantDBA()!
          updateLog(newMessage: logMsg)
          sharedUtils.setIsMerchantSelected(selected: false)
      }
      else
      {
          lblResults.text = ""

          txtUserID.text = ""
          txtUserPwd.text = ""
      }
    
    txtUserID.delegate = self
    txtUserPwd.delegate = self
  }
  
  @IBAction func goBack(_ sender: Any)
  {
    self.dismiss(animated: true, completion: nil)
  }
  

  /**
  **goAuthenticate**
  (Step 3)
  * This method listens for the Authenticate button to be tapped
  * The method verifies that valid input was entered and the proceeds
  * to authenticate with the gateway platform (Payrix).
  * The response from the gateway is via the Callback: didReceiveLoginResponse
  
  - Parameters:
    - sender: This represents the button object
  */
  @IBAction func goAuthenticate(_ sender: Any)
  {
    if doCheckValidInput()
    {
      lblResults.text = "Starting Authentication..."
      payrixSDK.delegate = self
      payrixSDK.doValidateCredentials(userID: txtUserID.text ?? "", password: txtUserPwd.text ?? "")
    }
  }
  
  
  public func didReceiveLoginResults(loginSuccess: Bool!, theSessionKey: String?, theMerchants: [AnyObject]?, theMessage: String!)
  {
    if loginSuccess
    {
      sharedUtils.setSessionKey(sessionKey: theSessionKey!)
        var payMerchant = PayMerchant.sharedInstance
        if let useMerchants = theMerchants as? [PayMerchant]
        {
            if useMerchants.count > 1
            {
                self.payMerchants = useMerchants
                self.performSegue(withIdentifier: "SegToMerchants", sender: nil)
            }
            else
            {
                payMerchant = useMerchants[0]
                // Save Merchant Info
                sharedUtils.setMerchantID(merchantKey: payMerchant.merchantID!)
                sharedUtils.setMerchantDBA(merchantDBA: payMerchant.merchantDBA!)
                let logMsg = "Authentication Successful: \n" + "- Merchant ID: " + payMerchant.merchantID! + "\n- Merchant DBA: " + payMerchant.merchantDBA!
                updateLog(newMessage: logMsg)
            }
        }
      hideKeyboard()
    }
    else
    {
      let useError = "Error: " + theMessage;
      sharedUtils.showMessage(theController: self, theTitle: "Authentication", theMessage: useError)
      
      let logMsg = "Authentication Error: \n" + theMessage
      updateLog(newMessage: logMsg)
    }
  }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let segID = segue.identifier else { return }
        if segID == "SegToMerchants"
        {
            // Prep for Authentication Processing
            let merchantLists : DemoMerchantsList = segue.destination as! DemoMerchantsList
            merchantLists.payMerchants = payMerchants
        }
    }
  
  /**
  **updateLog**
  * This method updates the UI Log of authentication events
  - Parameters:
    - newMessage: The String message to be displayed
  */
  private func updateLog(newMessage: String)
  {
    var currentLog = lblResults.text
    currentLog = currentLog! + "\n" + newMessage
    lblResults.text = currentLog
  }
  
  private func doCheckValidInput() -> Bool
  {
    if (txtUserID.text == nil || txtUserID.text == "") || (txtUserPwd.text == nil || txtUserPwd.text == "")
    {
      return false
    }
    else
    {
      return true
    }
  }
  
  
  /**
  **textFieldShouldReturn**
  * This method handles jumping between UI fields when tapping the Next key.
  - Parameters:
    - textField: The current textfield selected
  - Returns:
    - Bool returns False to ignore normal key processing
  */
  func textFieldShouldReturn(_ textField: UITextField) -> Bool
  {
     // Try to find next responder
     if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField
     {
        nextField.becomeFirstResponder()
     }
     else
     {
        // Not found, so remove keyboard.
        textField.resignFirstResponder()
     }
     // Do not add a line break
    
    if textField.tag == 102
    {
      goAuthenticate(self)
    }
     return false
  }
  
  
  func hideKeyboard()
  {
    view.endEditing(true)
  }
}
