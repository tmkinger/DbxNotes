//
//  NoteDetailViewController.swift
//  DBXNotes
//
//  Created by Tarun Mukesh Kinger on 17/03/18.
//  Copyright © 2018 Tarun Mukesh Kinger. All rights reserved.
//

import UIKit
import SwiftyDropbox

let kLastUpdated = "Last updated: "
let kNoteSynced = "Note Synced with Dropbox"

class NoteDetailViewController: UIViewController  {

    @IBOutlet weak var noteDetail: UITextView!
    @IBOutlet weak var updatedDate: UILabel!
    @IBOutlet weak var fileName: UITextField!
    
    var activityIndicator: UIActivityIndicatorView!
    var selectedFileName = ""
    var notesDictionary = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        if selectedFileName != "" {
            addActivityView()
            self.downloadSelectedNote()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.selectedFileName = ""
    }
    
    //configure UI of the view and nav bar
    func configureUI() {
        self.updatedDate.text = ""
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.backgroundColor = kNavBarColor
        self.navigationController?.navigationBar.tintColor = UIColor.red
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveAndSyncNote))
        setupUI()
    }
    
    //set up UI elements based on selectedFileName
    func setupUI() {
        if selectedFileName != "" {
            self.fileName.isHidden = true
            self.updatedDate.isHidden = false
            self.title = selectedFileName
        } else {
            self.title = "New Note"
            self.fileName.isHidden = false
            self.updatedDate.isHidden = true
        }
    }
    
    func addActivityView() {
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.center = self.view.center
        activityView.hidesWhenStopped = true
        self.activityIndicator = activityView
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
    }
    
    func removeActivityView() {
        if self.activityIndicator != nil && self.activityIndicator.isAnimating {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
    
    //download selected note to documents directory
    func downloadSelectedNote() {
        // Download to URL
        let client = DropboxClientsManager.authorizedClient
        let fileManager = FileManager.default
        let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destURL = directoryURL.appendingPathComponent(selectedFileName)
        let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return destURL
        }
        client?.files.download(path: "/" + selectedFileName, overwrite: true, destination: destination)
            .response { response, error in
                if let (metadata, _) = response {
                    print(metadata)
                    self.updatedDate.text = kLastUpdated + Utility.formatUpdatedDate(dateValue: metadata.serverModified)
                    self.loadNote()
                } else if let error = error {
                    print(error)
                }
        }
    }
    
    //load note data from file to textview
    func loadNote() {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let path = dir.appendingPathComponent(selectedFileName)
            
            do {
                self.noteDetail.text = try String(contentsOf: path, encoding: String.Encoding.utf8)
                removeActivityView()
            }
            catch {/* error handling here */
                print("Error! - This file doesn't contain any text.")
            }
        } else {
            print("Error! - This file doesn't exist.")
        }
    }
    
    //save note and sync to dropbox
    @objc func saveAndSyncNote() {
        if selectedFileName == "" {
            if fileName.text?.trimmingCharacters(in: .whitespaces) == "" {
                showToast(message: "Filename can't be empty")
                fileName.text = ""
            } else {
                selectedFileName = fileName.text! + ".txt"
                self.syncNote()
            }
        }
    }
    
    //sync note to dropbox
    func syncNote() {
        let client = DropboxClientsManager.authorizedClient
        let fileData = self.noteDetail.text.data(using: String.Encoding.utf8, allowLossyConversion: false)
        client?.files.upload(path: "/" + selectedFileName, mode: .overwrite, autorename: false, clientModified:nil, mute: false, propertyGroups: nil, input: fileData!)
        setupUI()
        self.showToast(message: kNoteSynced)
        self.updatedDate.text = kLastUpdated + Utility.formatUpdatedDate(dateValue: Date())
    }
    
    //displays a toast message to the user
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 100, y: self.view.frame.size.height-100, width: 250, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
