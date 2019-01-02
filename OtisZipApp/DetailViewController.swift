//
//  DetailViewController.swift
//  OtisZipApp
//
//  Created by srinivas on 31/07/18.
//  Copyright © 2018 Otis. All rights reserved.
//

import UIKit
import SSZipArchive
import WebKit
import MessageUI

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var currentItemIndexLabel: UILabel!
    @IBOutlet var webView: UIWebView!
    @IBOutlet weak var PreButton: UIButton!
    @IBOutlet weak var NextButton: UIButton!
    var items: [String] = []
    var currrentPage = 1;
    var unzippathDir:String? = nil
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                showUI(shouldShow: false)
                self.navigationItem.title = detail.title;
                fetchZipContents(zipPath:(detail.Filepath?.relativePath)!)
            }
        }else {
            detailDescriptionLabel.text = "No records found";
            showUI(shouldShow: true)
            
        }
    }
    func showUI(shouldShow:Bool) {
        self.PreButton.isHidden = shouldShow;
        self.NextButton.isHidden = shouldShow
        self.webView.isHidden = shouldShow
        self.currentItemIndexLabel.isHidden = shouldShow
    }
    func tempUnzipPath() -> String? {
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        path += "/\(UUID().uuidString)"
        let url = URL(fileURLWithPath: path)
        
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return nil
        }
        return url.path
    }
    func fetchZipContents(zipPath:String){
        guard let unzipPath = tempUnzipPath() else {
            return
        }
        self.unzippathDir = unzipPath
        let success: Bool =  SSZipArchive.unzipFile(atPath: zipPath, toDestination: unzipPath, overwrite: true, password: nil, progressHandler: { (image, info, start, end) in
        }) { (file, sucess, error) in
            print(error?.localizedDescription as Any)
        }
        if success != false {
            print("Success unzip")
        } else {
            print("No success unzip")
            
        }
        do {
            items = self.getAllFilesFromPath(path: unzipPath)
        } catch {
            return
        }
        //loading first item
        if items.count > 0 {
            loadResouce()
        }else {
            currrentPage = 0;
            self.NextButton.isEnabled = false;
            self.PreButton.isEnabled = false;
        }
        self.currentItemIndexLabel.text = String(format: "  %d / %d  ",currrentPage,items.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }
    
    @IBAction func openEmailBrowser(_ sender: Any) {
       //
        sendEmail()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var detailItem: Item? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    @IBAction func NextButtonPressed(_ sender: Any) {
        currrentPage = currrentPage + 1 ;
        self.currentItemIndexLabel.text = String(format: "  %d / %d  ",currrentPage,items.count)
        
        loadResouce()
        
    }
    
    @IBAction func PreviousButtionPressed(_ sender: Any) {
        currrentPage = currrentPage - 1 ;
        self.currentItemIndexLabel.text = String(format: "  %d / %d  ",currrentPage,items.count)
        
        loadResouce()
    }
    
    func loadResouce() {
        if(items.count > 0) {
            let itemURL = items[currrentPage-1]
            let imageURL = URL(string:itemURL)
            let documentName = imageURL?.lastPathComponent
            
            detailDescriptionLabel.text = documentName
            let request = URLRequest(url:imageURL!)
            self.webView.loadRequest(request)
            
            //Enable or disable the next and previous arrows
            if (currrentPage == items.count) {
                self.PreButton.isEnabled = true;
                self.NextButton.isEnabled = false;
            }else  if (currrentPage == 1) {
                self.PreButton.isEnabled = false;
                self.NextButton.isEnabled = true;
            }else  {
                self.PreButton.isEnabled = true;
                self.NextButton.isEnabled = true;
            }
        }
    }
    
    func getAllFilesFromPath(path:String) -> [String] {
        var urls = [String]()
        let baseurl: URL = URL(fileURLWithPath: path)
        
        let fileManager = FileManager()
        let en=fileManager.enumerator(atPath: path)
        
        while let element = en?.nextObject() as? String {
            if(en?.fileAttributes?[FileAttributeKey.type] as! FileAttributeType == FileAttributeType.typeRegular){
                //this is a file
                print(element)
                if !element.contains(".DS_Store") {
                    
                    let relativeURL = URL(fileURLWithPath: element, relativeTo: baseurl)
                    let url = relativeURL.absoluteString
                    urls.append(url)
                }
            }
            else if(en?.fileAttributes?[FileAttributeKey.type] as! FileAttributeType == FileAttributeType.typeDirectory){
                //this is a sub-directory
                print("this subdirectory ")
                print(element)
            }
        }
        return urls
    }
    
    
    func sendEmail() {
        
        if(items.count > 0) {

        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            
                mail.setMessageBody("<p>Attached the current viewing image </p>", isHTML: true)
                let itemURL = items[currrentPage-1]
                let imageURL = URL(string:itemURL)
                let documentName = imageURL?.lastPathComponent
                mail.setSubject("OtisZip:"+documentName!)
                detailDescriptionLabel.text = documentName
                if let data = NSData(contentsOf: imageURL!) {
                    mail.addAttachmentData(data as Data, mimeType: "image/jpeg", fileName: documentName!)
                }
                
            
            
            
            present(mail, animated: true)
        } else {
            // show failure alert
        
            let alert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                    
                }}))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
        else {
            let alert = UIAlertController(title: "Could Not Send Email", message: "No Image found", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                    
                }}))
            self.present(alert, animated: true, completion: nil)
        }
    
    }
    
    
}

extension DetailViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}





