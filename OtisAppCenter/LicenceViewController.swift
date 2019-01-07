//
//  LicenceViewController.swift
//  OtisZipApp
//
//  Created by srinivas on 08/11/18.
//  Copyright © 2018 Otis. All rights reserved.
//

import UIKit
import WebKit

class LicenceViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if  let url = Bundle.main.url(forResource: "MITLicence", withExtension: ".html") {
            let request = URLRequest(url:url)
            self.webView.loadRequest(request)

    }
    

    }

}
