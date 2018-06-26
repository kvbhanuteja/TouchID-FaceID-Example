//
//  ViewController.swift
//  FaceID&TouchID
//
//  Created by Bhanuteja on 25/06/18.
//  Copyright © 2018 Bhanuteja. All rights reserved.
//

import UIKit
import LocalAuthentication



class ViewController: UIViewController,UITextFieldDelegate,DetailsViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var saveAction :UIAlertAction?
    var notesArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.title = "Add notes"
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func authAction(_ sender: Any) {
        self.showAlert(message:"Added a note")
    }
    
    func showAlert(message:String){
        let controller = UIAlertController(title: "FaceID & TouchID", message: message, preferredStyle: .alert)
        saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) in
            self.notesArray.append(controller.textFields![0].text!)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        controller.addAction(saveAction!)
        controller.addTextField { (textField) in
            textField.placeholder = "Enter a note to add"
            textField.delegate = self
        }
        saveAction?.isEnabled = false
        self.present(controller, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text
        if let rangeInText = Range(range,in:text!){
        let currentText = text?.replacingCharacters(in: rangeInText, with: string)
            self.saveAction?.isEnabled = (currentText?.count)! > 3
        }
        return true
    }
}
extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell")
        cell?.textLabel?.text = notesArray[indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Constant.sharedInstance.accessGained {
            DispatchQueue.main.async {
                self.moveToDetailViewController(index: indexPath.row)
            }
        }else{
        DispatchQueue.main.async {
            self.authenticationWithTouchID(index: indexPath.row)
        }
        }
    }
    func saveText(notes:String,index:Int) {
        self.notesArray[index] = notes
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
extension ViewController {
    
    func authenticationWithTouchID(index:Int) {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
        
        var authError: NSError?
        let reasonString = "To access the secure data"
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    Constant.sharedInstance.accessGained = true
                    DispatchQueue.main.async {
                        self.moveToDetailViewController(index: index)
                    }
                } else {
                    //TODO: User did not authenticate successfully, look at error and take appropriate action
                    guard let error = evaluateError else {
                        return
                    }
                    
                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    
                    //TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
                    
                }
            }
        } else {
            
            guard let error = authError else {
                return
            }
            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
        }
    }
    
    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            
        default:
            message = ""
        }
        
        return message
    }
    
    func moveToDetailViewController(index:Int) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController
        controller?.noteData = self.notesArray[index]
        controller?.noteIndex = index
        controller?.delegate = self
        self.navigationController?.pushViewController(controller!, animated: true)
    }
}
