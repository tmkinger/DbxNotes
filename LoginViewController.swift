//
//  LoginViewController.swift
//  DBXNotes
//
//  Created by Tarun Mukesh Kinger on 17/03/18.
//  Copyright © 2018 Tarun Mukesh Kinger. All rights reserved.
//

import UIKit
import SwiftyDropbox

let kNoteListSegueIdentifier = "noteListSegue"
let kTitleContinue = "Continue as "
let kTitleLogin = "Login"

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    var notesArray = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(loginButtonPressed), name: NSNotification.Name(rawValue: kLoggedInNotificationKey), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
        if (DropboxClientsManager.authorizedClient != nil) {
            // Get the current user's account info
            let client = DropboxClientsManager.authorizedClient
            client?.users.getCurrentAccount().response { response, error in
                if let account = response {
                    self.loginButton.setTitle(kTitleContinue + account.name.givenName, for: .normal)
                    self.logoutButton.isHidden = false
                    self.loginButton.isHidden = false
                } else {
                    print(error!)
                }
            }
        } else {
            loginButton.setTitle(kTitleLogin, for: .normal)
            logoutButton.isHidden = true
            loginButton.isHidden = false
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //login button action
    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        if (DropboxClientsManager.authorizedClient != nil) {
            //User is already authorized
            performSegue(withIdentifier: kNoteListSegueIdentifier, sender: self)
        } else {
            //User not authorized
            //So we go for authorizing user first.
            DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: self, openURL: { (url) in
                UIApplication.shared.open(url, options:[:], completionHandler: nil)
                self.performSegue(withIdentifier: kNoteListSegueIdentifier, sender: self)
            })
        }
    }
    
    //logout button action
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        DropboxClientsManager.unlinkClients()
        loginButton.setTitle(kTitleLogin, for: .normal)
        logoutButton.isHidden = true
    }
}

