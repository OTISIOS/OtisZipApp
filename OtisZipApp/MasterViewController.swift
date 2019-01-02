//
//  MasterViewController.swift
//  OtisZipApp
//
//  Created by srinivas on 31/07/18.
//  Copyright © 2018 Otis. All rights reserved.
//

import UIKit
import SafariServices

struct Item {
    var title:String?
    var Filepath:URL?
}

class MasterViewController: UITableViewController {
    @IBOutlet var label: UILabel!
    var detailViewController: DetailViewController? = nil
    var objects = [Item]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // for background color        
        navigationItem.title = "Otis Zip"
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

    }
    @IBAction func viewLicencePage(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LicenceViewController")
        self.navigationController!.pushViewController(vc, animated: true)


    }
    
    @objc func update() {
        fetchDocumentDirecrory()
        self.tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        fetchDocumentDirecrory()
        self.tableView.rowHeight = 54.0
    }
    
    func fetchDocumentDirecrory() {
        objects.removeAll()
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            
            // if you want to filter the directory contents you can do like this:
            let zipFiles = directoryContents.filter{ $0.pathExtension == "zip" }
            for zipfile in zipFiles {
                let zipFilesname =  zipfile.deletingPathExtension().lastPathComponent
                let item = Item(title: zipFilesname, Filepath: zipfile)
                objects.append(item)
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        if(objects.count == 0) {
            self.tableView.tableFooterView = label
        }else {
            self.tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] 
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let object = objects[indexPath.row]
        cell.textLabel!.text = object.title
        cell.imageView?.image = UIImage.init(named: "Icon-40.png")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
             let deleteItem = objects[indexPath.row]
            if(FileManager.default.fileExists(atPath: (deleteItem.Filepath?.relativePath)!)){
                do {
                    try FileManager.default.removeItem(at: (deleteItem.Filepath!));
                }catch {
                
                }
                }
                objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if(objects.count == 0) {
                self.tableView.tableFooterView = label
            }else {
                self.tableView.tableFooterView = UIView.init(frame: CGRect.zero)
            }
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
}

