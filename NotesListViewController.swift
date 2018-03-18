//
//  NotesListViewController.swift
//  DBXNotes
//
//  Created by Tarun Mukesh Kinger on 17/03/18.
//  Copyright © 2018 Tarun Mukesh Kinger. All rights reserved.
//

import UIKit
import SwiftyDropbox

let kNoteDetailSegueIdentifier = "noteDetailSegue"
let kNoteListCellIdentifier = "NoteListCell"
let kNavBarColor = UIColor.init(red: 255/255, green: 211/255, blue: 83/255, alpha: 1.0)

class NotesListViewController: UIViewController  {
    
    @IBOutlet weak var noteListTableView: UITableView!
    
    var activityIndicator: UIActivityIndicatorView!
    var notesDictionary = NSMutableDictionary()
    var selectedFileName = ""
    var refreshControl: UIRefreshControl!
    let client = DropboxClientsManager.authorizedClient

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonTapped))
        self.navigationController?.isNavigationBarHidden = false

        self.title = "Notes"
        self.navigationController?.navigationBar.backgroundColor = kNavBarColor
        self.navigationController?.navigationBar.tintColor = UIColor.red

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.getNotesFromDropbox), for: UIControlEvents.valueChanged)
        noteListTableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addActivityView()
        self.selectedFileName = ""
        self.getNotesFromDropbox()
    }
    
    func addActivityView() {
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.center = self.noteListTableView.center
        activityView.hidesWhenStopped = true
        self.activityIndicator = activityView
        self.noteListTableView.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
    }
    
    func removeActivityView() {
        if self.activityIndicator != nil && self.activityIndicator.isAnimating {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
    
    //Fetch all notes from DropBox
    @objc func getNotesFromDropbox() {
        
        client?.files.listFolder(path: "").response{ (objList, error) in
            if let resultList = objList {
                
                //Create a for loop for getting all the entities individually
                for entry in resultList.entries {
                    
                    //Check if file have metadata or not
                    if let fileMetadata = entry as? Files.FileMetadata {
                        
                        //Check file type by extention .txt
                        if self.isNoteType(filename: fileMetadata.name) == true {
                            self.notesDictionary.setValue(fileMetadata.serverModified, forKey: fileMetadata.name)
                        } else {
                            //If file have not metadata it mean it is a folder.
                        }
                    }
                }
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.removeActivityView()
            self.noteListTableView.reloadData()
        }
    }
    
    //MARK: check for file type
    func isNoteType(filename:String) -> Bool {
        let lastPathComponent = NSURL(fileURLWithPath: filename).pathExtension
        return lastPathComponent == "txt"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kNoteDetailSegueIdentifier {
            let noteDetailViewController = segue.destination as? NoteDetailViewController
            noteDetailViewController?.selectedFileName = selectedFileName
        }
    }
    
    //add button action
    @objc func addTapped() {
        performSegue(withIdentifier: kNoteDetailSegueIdentifier, sender: self)
    }
    
    //logout button action
    @objc func logoutButtonTapped() {
        DropboxClientsManager.unlinkClients()
        self.navigationController?.popViewController(animated: true)
    }
}

//table delegate and datasource methods
extension NotesListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesDictionary.count
    }
    
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let noteListCell = tableView.dequeueReusableCell(withIdentifier: kNoteListCellIdentifier) as! NotesListCell

        let fileName = notesDictionary.allKeys[indexPath.row] as? String
        noteListCell.fileNameLabel?.text = fileName
        noteListCell.updatedDateLabel?.text = Utility.formatUpdatedDate(dateValue: notesDictionary[fileName!] as! Date)

        return noteListCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFileName = (notesDictionary.allKeys[indexPath.row] as? String)!
        performSegue(withIdentifier: kNoteDetailSegueIdentifier, sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            deleteNoteAtIndexPath(indexPath: indexPath)
        }
    }
    
    //delete action on table cell swipe
    func deleteNoteAtIndexPath(indexPath: IndexPath) {
        let fileName = notesDictionary.allKeys[indexPath.row] as? String
        notesDictionary.removeObject(forKey: fileName!)
        
        client?.files.deleteV2(path: "/" + fileName!)
        self.noteListTableView.reloadData()
    }
}

//Note list table cell
class NotesListCell: UITableViewCell  {
    @IBOutlet weak var fileNameLabel : UILabel?
    @IBOutlet weak var updatedDateLabel : UILabel?
}


