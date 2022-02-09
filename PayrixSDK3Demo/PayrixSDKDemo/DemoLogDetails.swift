//
//  DemoLogDetails.swift
//  PayrixSDKDemo
//
//  Created by Steve Sykes on 2/16/21.
//  Copyright © 2021 Payrix. All rights reserved.
//

import UIKit

class DemoLogDetails: UIViewController
{

  let sharedUtils = SharedUtilities.init()
  var passedLogFileName = String()
  var passedLogFileURL: URL? = nil
  var delegate:Any!
  
  @IBOutlet weak var lblFileName: UILabel!
  @IBOutlet weak var txtLogData: UITextView!
  
  
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    
    lblFileName.text = passedLogFileName
    
    if let useURL = passedLogFileURL
    {
      let useFileData = sharedUtils.doReadLogFile(fileURL: useURL)
      txtLogData.text = useFileData
    }
    else
    {
      txtLogData.text = "Empty File"
    }
  }
    
  @IBAction func goClose(_ sender: Any)
  {
    self.dismiss(animated: true, completion: nil)
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
