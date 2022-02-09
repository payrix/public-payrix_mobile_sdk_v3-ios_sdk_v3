//
//  DemoLogListTableViewController.swift
//  PayrixSDKDemo
//
//  Created by Steve Sykes on 2/15/21.
//  Copyright © 2021 Payrix. All rights reserved.
//

import UIKit

class DemoLogList: UITableViewController {

  
  var fileList:[String] = [String]()
  let sharedUtils = SharedUtilities.init()
  var passedLogFileName = ""
  var passedLogFileURL: URL? = nil
  
  override func viewDidLoad()
  {
    super.viewDidLoad()

  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    
    let unsortedList = sharedUtils.doGetLogFileList()
    
    fileList = unsortedList.sorted()
  }
  
  
  
  @IBAction func goBack(_ sender: Any)
  {
    self.dismiss(animated: true, completion: nil)
  }
  
  
  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int
  {
      // #warning Incomplete implementation, return the number of sections
    if fileList.count >= 1
    {
      return 1
    }
    else
    {
      return 0
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return fileList.count
  }

  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    // Log_Sale-Request_01-16-21-130124

    let cell = tableView.dequeueReusableCell(withIdentifier: "logCell", for: indexPath)
    let fileRow = indexPath.row
    
    cell.textLabel?.text = fileList[fileRow]
    
    return cell
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
  {
    let selectedCell = tableView.cellForRow(at: indexPath)
    
    if let useLogFile = selectedCell?.textLabel?.text
    {
      let fileMgr = FileManager.default
      let documentDirectoryUrl = try! fileMgr.url (for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
      let fullPath = documentDirectoryUrl.appendingPathComponent("DemoLogFile")
      
      passedLogFileURL = fullPath.appendingPathComponent(useLogFile)
      passedLogFileName = useLogFile
      performSegue(withIdentifier: "SegToLogDetails", sender: self)
    }
    return
  }
    
 override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            showAlertToDeleteFile(indexPath: indexPath)
        }
        else
        {
            print("editing style not delete")
        }
    }
    
    func showAlertToDeleteFile(indexPath : IndexPath)
    {
        let alertC = UIAlertController(title: "Are you Sure?", message: "You Want to delete the file.", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
            self.deleteFileAt(indexPath: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertC.addAction(deleteAction)
        alertC.addAction(cancelAction)
        present(alertC, animated: true, completion: nil)
    }
    
    func deleteFileAt(indexPath : IndexPath)
    {
    
        let fileNameToDelete = fileList[indexPath.row]
        var filePath = ""
        // Fine documents directory on device
         let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        if dirs.count > 0 {
            let dir = dirs[0] //documents directory
            filePath = dir.appendingFormat("/DemoLogFile/" + fileNameToDelete)
            print("Local path = \(filePath)")
         
        } else {
            print("Could not find local directory to store file")
            return
        }
        do {
             let fileManager = FileManager.default
            
            // Check if file exists
            if fileManager.fileExists(atPath: filePath) {
                // Delete file
                try fileManager.removeItem(atPath: filePath)
                fileList.remove(at: indexPath.row)
                if fileList.count   ==  0
                {
                    tableView.reloadData()
                }
                else
                {
                    tableView.deleteRows(at: [indexPath], with: .left)
                }
            } else {
                print("File does not exist")
            }
         
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    guard let segID = segue.identifier else { return }
    if segID == "SegToLogDetails"
    {
      // Jump to History Details passing the Transaction Information
      let demoLogDetails = segue.destination as! DemoLogDetails
      demoLogDetails.passedLogFileName = self.passedLogFileName
      demoLogDetails.passedLogFileURL = self.passedLogFileURL
      demoLogDetails.delegate = self
    }
  }
  

  /*
  // Override to support conditional editing of the table view.
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      // Return false if you do not want the specified item to be editable.
      return true
  }
  */

  /*
  // Override to support editing the table view.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
          // Delete the row from the data source
          tableView.deleteRows(at: [indexPath], with: .fade)
      } else if editingStyle == .insert {
          // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
      }
  }
  */

  /*
  // Override to support rearranging the table view.
  override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

  }
  */

  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
      // Return false if you do not want the item to be re-orderable.
      return true
  }
  */

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // Get the new view controller using segue.destination.
      // Pass the selected object to the new view controller.
  }
  */

}
