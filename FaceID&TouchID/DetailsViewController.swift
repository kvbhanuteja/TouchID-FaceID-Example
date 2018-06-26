//
//  DetailsViewController.swift
//  FaceID&TouchID
//
//  Created by Bhanuteja on 25/06/18.
//  Copyright © 2018 Bhanuteja. All rights reserved.
//

import UIKit
protocol DetailsViewControllerDelegate:class {
    func saveText(notes:String,index:Int)
}
class DetailsViewController: UIViewController {
   
    @IBOutlet weak var textView: UITextView!
    var noteData = ""
    var noteIndex = 0
    weak var delegate :DetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit notes"
        textView.text = noteData
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveText))
        self.navigationItem.rightBarButtonItem = saveButton
        // Do any additional setup after loading the view.
    }
    
    
    @objc func saveText(){
      delegate?.saveText(notes: textView.text,index: noteIndex)
        self.navigationController?.popToRootViewController(animated: true)
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
