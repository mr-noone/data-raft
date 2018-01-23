//
//  ContactsViewController.swift
//  Example
//
//  Created by Aleksey Zgurskiy on 23.01.2018.
//  Copyright © 2018 Graviti Mobail. All rights reserved.
//

import UIKit
import CoreData
import DataRaft

fileprivate let newSegue = "NewSegue"
fileprivate let editSegue = "EditSegue"

class ContactsViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var fetchedResultsController: NSFetchedResultsController<Contact>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstDescriptor = NSSortDescriptor(key: #keyPath(Contact.firstName), ascending: true)
        let secondDescriptor = NSSortDescriptor(key: #keyPath(Contact.lastName), ascending: true)
        let request = NSFetchRequest<Contact>(entityName: Contact.entityName)
        request.sortDescriptors = [firstDescriptor, secondDescriptor]
        
        let context = AppDelegate.shared.db.main()
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == editSegue {
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
            let data = fetchedResultsController.object(at: indexPath)
            
            let destination = segue.destination as! NewContactViewController
            destination.objectID = data.objectID
        }
    }
    
    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = fetchedResultsController.object(at: indexPath)
        
        var nameComponents = [String]()
        if let firstName = data.firstName {
            nameComponents.append(firstName)
        }
        
        if let lastName = data.lastName {
            nameComponents.append(lastName)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = nameComponents.joined(separator: " ")
        cell.detailTextLabel?.text = data.phone
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { action, indexPath in
            AppDelegate.shared.db.performOnPrivate { context in
                let objectID = self.fetchedResultsController.object(at: indexPath).objectID
                let data = context.object(with: objectID)
                context.delete(data)
                
                do {
                    try context.saveToStore()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
        
        return [deleteAction]
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
