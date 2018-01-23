//
//  NewContactViewController.swift
//  Example
//
//  Created by Aleksey Zgurskiy on 23.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import UIKit
import CoreData
import DataRaft

class NewContactViewController: UITableViewController {
    var objectID: NSManagedObjectID?
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var doneItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let objectID = objectID {
            navigationItem.title = "Edit contact"
            AppDelegate.shared.db.performOnMain { context in
                guard let contact = context.object(with: objectID) as? Contact else {
                    return
                }
                
                self.firstNameTextField.text = contact.firstName
                self.lastNameTextField.text = contact.lastName
                self.phoneTextField.text = contact.phone
            }
        } else {
            navigationItem.title = "New contact"
        }
    }
    
    @IBAction func textFieldDidChanged(_ sender: UITextField) {
        doneItem.isEnabled = firstNameTextField.text!.count > 0 &&
            lastNameTextField.text!.count > 0 &&
            phoneTextField.text!.count > 0
    }
    
    @IBAction func cancelTouch(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneTouch(_ sender: UIBarButtonItem) {
        AppDelegate.shared.db.performAndWaitOnPrivate { context in
            let contact: Contact
            if let objectID = self.objectID {
                contact = context.object(with: objectID) as! Contact
            } else {
                contact = context.new()
            }
            
            contact.firstName = self.firstNameTextField.text
            contact.lastName = self.lastNameTextField.text
            contact.phone = self.phoneTextField.text
            
            do {
                try context.saveToStore()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        navigationController?.popViewController(animated: true)
    }
}
