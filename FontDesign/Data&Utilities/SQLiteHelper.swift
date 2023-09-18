//
//  SQLiteHelper.swift
//  FontDesign
//
//  Created by Netra Technosys on 24/11/21.
//

import Foundation
import UIKit
import SQLite3

class SQLiteHelper {
    
    init() {
        self.db = self.openDatabase()
        self.createTable()
    }
    
    let dbPath : String = "FontData.db"
    var db: OpaquePointer?
    
    func openDatabase() -> OpaquePointer? {
        
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(dbPath)
        print(fileUrl)
        
        self.db = nil
        if sqlite3_open(fileUrl.path, &self.db) != SQLITE_OK {
            print("error opening database")
            return nil
        } else {
            print("Successfully opened connection to database at\(dbPath)")
            return self.db
        }
    }
    
    func createTable() {
        let createTblQuery = "CREATE TABLE IF NOT EXISTS FontDetails(alphabet_index TEXT, alphabet TEXT, image TEXT);"
        
        var createTblStatment : OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, createTblQuery, -1, &createTblStatment, nil) == SQLITE_OK {
            if sqlite3_step(createTblStatment) == SQLITE_DONE {
                print("Font table create Successfully")
            } else {
                print("Font table can not be created")
            }
        } else {
            print("Create table statment could not be prepared.")
        }
        sqlite3_finalize(createTblStatment)
    }
    
    func insertDataToDb(index: String, image: String, alphbet: String) {
        
        let data = self.showDataTodb()
        if let data = data {
            for i in data {
                if i.index == index {
                    self.updateToDb(index: index, alphabet: alphbet, image: image)
                    return
                }
            }
        }
        
        let insertQuery = "INSERT INTO FontDetails(alphabet_index,alphabet,image) VALUES (?,?,?)"
        var insertTblStatment : OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertQuery, -1, &insertTblStatment, nil ) == SQLITE_OK {
            sqlite3_bind_text(insertTblStatment, 1, (index as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertTblStatment, 2, (alphbet as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertTblStatment, 3, (image as NSString).utf8String, -1, nil)
            //[UInt8](nsData as Data)
            //imageData.map{ String(format: "%02x", $0) }.joined()
            if sqlite3_step(insertTblStatment) == SQLITE_DONE {
                print("SuccesFully inserted data")
            } else {
                print("Could not inserted row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertTblStatment)
    }
    
    func showDataTodb() -> [FontData]? {
        let selectQueryStr = "SELECT * FROM FontDetails;"
        var queryStatment :OpaquePointer? = nil
        var std : [FontData] = []
        if sqlite3_prepare_v2(db, selectQueryStr, -1, &queryStatment, nil) == SQLITE_OK {
            
            while sqlite3_step(queryStatment) == SQLITE_ROW {
                let index = String(describing: String(cString: sqlite3_column_text(queryStatment, 0)))
                let alphabet = String(describing: String(cString: sqlite3_column_text(queryStatment,1)))
                let image = String(describing: String(cString: sqlite3_column_text(queryStatment,2)))
                
                let dic : NSMutableDictionary = NSMutableDictionary()
                dic.setValue(index, forKey: "font_index")
                dic.setValue(alphabet, forKey: "alphabet")
                dic.setValue(image, forKey: "font_image")
                std.append(FontData(dic: dic))
            }
            
        } else {
            print("error to show data")
        }
        
        sqlite3_finalize(queryStatment)
        return std
    }
    
    
    
    func updateToDb(index: String, alphabet: String, image: String) {
        let updateQuery = "UPDATE FontDetails SET alphabet = '\(alphabet)',image = '\(image)' WHERE alphabet_index = '\(index)';"
        var updateStatment : OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, updateQuery, -1, &updateStatment, nil) == SQLITE_OK {
            
            sqlite3_bind_text(updateStatment, 1, (index as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatment, 2, (alphabet as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatment, 3, (image as NSString).utf8String, -1, nil)
            
            if sqlite3_step(updateStatment) == SQLITE_DONE {
                print("SuccesFully updated data")
            } else {
                print("Could not inserted row.")
            }
        } else {
            print("UPDATE Statment could not be prepared.")
        }
        sqlite3_finalize(updateStatment)
    }
    
    func delteDataFromDb(alphabet: String) {
        let deleteQueryStr = "DELETE FROM FontDetails WHERE alphabet_index = ?;"
        var deleteStatment : OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, deleteQueryStr, -1, &deleteStatment, nil) == SQLITE_OK {
            sqlite3_bind_text(deleteStatment, 1, (alphabet as NSString).utf8String, -1, nil)
            if sqlite3_step(deleteStatment) == SQLITE_DONE {
                print("successfully Deleted Row ")
            } else {
                print("failed to delete database")
            }
        } else {
            print("delete Statment could not be prepared.")
        }
        sqlite3_finalize(deleteStatment)
    }
    
}
