//
//  SharedUtilities.swift
//  PayrixSDKDemo
//
//  Created by Steve Sykes on 7/22/20.
//  Copyright © 2020 Payrix. All rights reserved.
//

import UIKit
import PayrixSDK

class SharedUtilities: NSObject
{
  // Singleton for SharedUtilities
  public static let sharedInstance = SharedUtilities()
  override init() {}
  
  let merchantIDKey:String = "merchantID"
  let merchantDBAKey = "merchantDBA"
  let lastUsedTaxRateKey = "lastUsedTaxRate"

  // Sign In Keys
  let userNameDefaultsKey = "UserName"
  let sessionKeyDefaultsKey = "Session"
  
  // App SDK Environment Keys
  let envSelectionKey = "SDKENVSELECTION"
  let envSandboxOnKey = "SDKSANDBOXONSWITCH"

  // Default URLs
  public let pwlAPIHostName = "api.payrix.com"
  public let pwlForgotPasswordURL = "https://portal.payrix.com"

  // The Demo Mode Key
  let demoModeKey = "com.Payrix.DemoMode"

  // BT Device Key
  let btDeviceKey = "CurrentBTReader"
  let btManufacturerKey = "CurrentBTManfg"
  
  let userDefaults = UserDefaults.standard
  
  // CC Type image map
  static let ccTypeNames = [CCType.AmericanExpress : "Amex",
                            CCType.Discover : "Discover",
                            CCType.MasterCard : "Master Card",
                            CCType.Visa : "Visa"]

  static let ccTypeImages = [CCType.AmericanExpress : "Amex",
                             CCType.Discover : "Discover",
                             CCType.MasterCard : "MasterCard",
                             CCType.Visa : "Visa"]

  // Regex expressions to match CC type by CC number
  static let ccTypeRegex = [CCType.AmericanExpress : "^3[47][0-9]",
                             CCType.Discover : "^6[0-9]",
                             CCType.MasterCard : "^(5[1-5][0-9])|^(2[2-7][0-9])",
                             CCType.Visa : "^4[0-9]"]

  // How many digits required for each CC type?
  static let ccTypeDigits = [CCType.AmericanExpress : 15,
                             CCType.Discover : 16,
                             CCType.MasterCard : 16,
                             CCType.Visa : 16]
  static let ccDigitsDefault = 16
  
  // Credit Card types
  public enum CCType: Int {
      case AmericanExpress = 1
      case Visa = 2
      case MasterCard = 3
      case DinersClub = 4
      case Discover = 5
  }
  
  public func setSessionKey(sessionKey: String)
  {
    userDefaults.set(sessionKey, forKey: sessionKeyDefaultsKey)
  }
  
  public func getSessionKey() -> String?
  {
    let foundValue = userDefaults.string(forKey: sessionKeyDefaultsKey)
    return foundValue
  }
  
  public func setEnvSelection(selEnv: String)
  {
    userDefaults.set(selEnv, forKey: envSelectionKey)
  }
  
  public func getEnvSelection() -> String!
  {
    let foundValue = userDefaults.string(forKey: envSelectionKey) ?? "api.payrix.com"
    return foundValue
  }
  
  
  public func setSandBoxOn(selSandBox: Bool)
  {
    userDefaults.set(selSandBox, forKey: envSandboxOnKey)
  }
  
  public func getSandBoxOn() -> Bool!
  {
    let foundValue = userDefaults.bool(forKey: envSandboxOnKey)
    return foundValue
  }
  
  public func setDemoMode(modeKey: Bool)
  {
    userDefaults.set(modeKey, forKey: demoModeKey)
  }
  
  public func getDemoMode() -> Bool?
  {
    let foundValue = userDefaults.bool(forKey: demoModeKey)
    return foundValue
  }
  
  public func setMerchantID(merchantKey: String)
  {
    userDefaults.set(merchantKey, forKey: merchantIDKey)
  }
  
  public func getMerchantID() -> String?
  {
    let foundValue = userDefaults.string(forKey: merchantIDKey)
    return foundValue
  }
  
  public func setMerchantDBA(merchantDBA: String)
  {
    userDefaults.set(merchantDBA, forKey: merchantDBAKey)
  }
  
  public func getMerchantDBA() -> String?
  {
    let foundValue = userDefaults.string(forKey: merchantDBAKey)
    return foundValue
  }
  
  public func setBTReader(btReaderKey: String)
  {
    userDefaults.set(btReaderKey, forKey: btDeviceKey)
  }
  
  public func getBTReader() -> String?
  {
    let foundValue = userDefaults.string(forKey: btDeviceKey)
    return foundValue
  }
  
  public func setBTManfg(btManfgKey: String)
  {
    userDefaults.set(btManfgKey, forKey: btManufacturerKey)
  }
  
  public func getBTManfg() -> String?
  {
    let foundValue = userDefaults.string(forKey: btManufacturerKey)
    return foundValue
  }
  
  
  public func doWriteLogFile(fileName: String, fileData: String)
  {
    let fileMgr = FileManager.default
    let documentDirectoryUrl = try! fileMgr.url (for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    let fullPath = documentDirectoryUrl.appendingPathComponent("DemoLogFile")
    
    if !fileMgr.fileExists(atPath: fullPath.absoluteString)
    {
      // Directory does not Exist so create
      do
      {
        try fileMgr.createDirectory(at: fullPath, withIntermediateDirectories: true, attributes: nil)
      }
      catch let err as NSError
      {
        print(err)
      }
    }
    
    let fileUrl = fullPath.appendingPathComponent(fileName).appendingPathExtension("txt")
    print("File path \(fileUrl.path)")
    
    do
    {
      try fileData.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
    }
    catch let err as NSError
    {
      print(err)
    }
  }
  
  
  public func doGetLogFileList() -> [String]
  {
    var theFiles:[String]
        
    let documentDirectoryUrl = try! FileManager.default.url (for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let fullPath = documentDirectoryUrl.appendingPathComponent("DemoLogFile")

    let filePath = fullPath.path
    let fileManager = FileManager.default
    
    do
    {
      try theFiles = fileManager.contentsOfDirectory(atPath: filePath)
    }
    catch let err as NSError
    {
      print(err)
      theFiles = [String]()
    }

    return theFiles
  }
  
  
  public func doReadLogFile(fileURL: URL) -> String
  {
    var readFile = ""
    do
    {
      readFile = try String(contentsOf: fileURL)
    }
    catch let err as NSError
    {
      print(err)
    }
    print (readFile)
    return readFile
  }
  
  
  public func doGenLogString(source: AnyObject!) -> String
  {
    var generatedString = String()
    var mirrorSource: AnyObject = source
    
    if let objType = source as? PayRequest
    {
      mirrorSource = objType
      generatedString = "PAYMENT REQUEST:\n"
    }
    else if let objType = source as? PayResponse
    {
      mirrorSource = objType
      generatedString = "PAYMENT RESPONSE:\n"
    }
    else
    {
        return "No Data"
    }
    
    let mirroredObj = Mirror(reflecting: mirrorSource)
    
    for (index, theAttribute) in mirroredObj.children.enumerated()
    {
      if let theProperty = theAttribute.label
      {
        let valueForAttribute = self.convertValueInString(passedValue: theAttribute.value)
        generatedString = generatedString + "\(index) - \(theProperty): \(valueForAttribute)" + "\n -------------------- \n"
      }
    }
    return generatedString
  }
    
    //this function helps to convert the attribute value in string format
    func convertValueInString(passedValue : Any) -> String{
        if let returnValue = passedValue as? String{
            return returnValue
        }else if let returnValue = passedValue as? Float{
            let numberTwoDecimal = String(format: "%.2f", returnValue)
            return numberTwoDecimal
        }else if let returnValue = passedValue as? Int{
            return NSNumber(integerLiteral: returnValue).stringValue
        }else if let returnValue = passedValue as? PaySharedAttributes.CCType{
            return getCardName(cardType: returnValue)
        }else if let returnValue = passedValue as? [String]{
            return returnValue.joined(separator: ", ")
        }
        return ""
    }
    
    func getCardName(cardType : PaySharedAttributes.CCType) -> String
    {
        if cardType  ==  .AmericanExpress{
            return "AmericanExpress"
        }else if cardType    ==  .Visa{
            return "Visa"
        }else if cardType    ==  .MasterCard{
            return "MasterCard"
        }else if cardType    ==  .DinersClub{
            return "DinersClub"
        }else if cardType    ==  .Discover{
            return "Discover"
        }
        return ""
    }
  
  func bldCCType(cardType:String) -> CCType?
  {
    switch cardType.uppercased()
    {
    case "AMEX":
      return CCType.AmericanExpress
    case "DISCOVER":
      return CCType.Discover
    case "MASTERCARD":
      return CCType.MasterCard
    case "VISA":
      return CCType.Visa
    case "DINERSCLUB":
      return CCType.DinersClub
    default:
      break
    }
    return nil
  }
  
  func convertIndModeToPayrixEntryMode(industryMode: String) -> String
  {
    var retPayrixMode = ""
    switch industryMode
    {
      case PaySharedAttributes.PayIndustryEntryMode.read_Manual_Entry.rawValue:
        retPayrixMode = PaySharedAttributes.PayReaderEntryMode.read_Manual_Entry.rawValue
        
      case PaySharedAttributes.PayIndustryEntryMode.read_MagneticStrip.rawValue:
          retPayrixMode = PaySharedAttributes.PayReaderEntryMode.read_MagneticStrip.rawValue
        
      case PaySharedAttributes.PayIndustryEntryMode.read_EMV_ChipCard.rawValue:
          retPayrixMode = PaySharedAttributes.PayReaderEntryMode.read_EMV_ChipCard.rawValue
      
      case PaySharedAttributes.PayIndustryEntryMode.read_Contactless_EMV.rawValue:
        retPayrixMode = PaySharedAttributes.PayReaderEntryMode.read_Contactless_EMV.rawValue
      
      case PaySharedAttributes.PayIndustryEntryMode.read_Fallback_Magnetic.rawValue:
        retPayrixMode = PaySharedAttributes.PayReaderEntryMode.read_Fallback_Magnetic.rawValue
      
      case PaySharedAttributes.PayIndustryEntryMode.read_MagneticStripFromTrack2.rawValue:
        retPayrixMode = PaySharedAttributes.PayReaderEntryMode.read_Track2.rawValue
      
      case PaySharedAttributes.PayIndustryEntryMode.read_ContactlessMagneticStrip.rawValue:
        retPayrixMode = PaySharedAttributes.PayReaderEntryMode.read_Contactless_EMV.rawValue
      
      default:
        retPayrixMode = industryMode
    }
    return retPayrixMode
  }
  
  public func getURL(theURI: String) -> String
  {
    let isSandBox =  getSandBoxOn()!
    let theEnv = getEnvSelection()!
    var useURL = ""
    if isSandBox
    {
      useURL = "https://test-" + theEnv + theURI
    }
    else
    {
      useURL = "https://" + theEnv + theURI
    }
    return useURL
  }
  
  
  public func showMessage(theController: UIViewController, theTitle: String, theMessage: String)
  {
    let msgAlertController = UIAlertController(title: theTitle, message: theMessage, preferredStyle: UIAlertController.Style.alert)
    let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
    { (alert) in
    }
    msgAlertController.addAction(ok)
    theController.present(msgAlertController, animated: true, completion: nil)
  }
  
  
  public func checkNetworkConnection() -> Bool
  {
    if (Network.reachability?.isReachable) == false
    {
      return false
    }
    else
    {
      return true
    }
  }
  
}

