//
//  Utility.swift
//  DBXNotes
//
//  Created by Tarun Mukesh Kinger on 18/03/18.
//  Copyright © 2018 Tarun Mukesh Kinger. All rights reserved.
//

import UIKit

open class Utility: NSObject {
    
    //convert the date to string format
    static func formatUpdatedDate(dateValue:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy hh:mm:a"
        return formatter.string(from:dateValue)
    }
}
