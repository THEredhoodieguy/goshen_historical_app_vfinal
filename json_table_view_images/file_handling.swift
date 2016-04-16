//
//  file_handling.swift
//  goshen_historical_app_v1
//
//  Created by Matthew Wesley Pletcher on 3/15/16.
//  Copyright © 2016 Matthew Pletcher. All rights reserved.
//

import Foundation

func read_from_file() -> String {
    var output_str = ""
    
    
    //Location to write to. Persistant location across multiple boots
    let destinationPath: String! = NSHomeDirectory() + "data.txt"
    
    let filemgr = NSFileManager.defaultManager()
	
    if filemgr.fileExistsAtPath(destinationPath) {
        print("File exists")
        do {
            //Set file to output
            output_str = try String(contentsOfFile: destinationPath, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print("Error: \(error)")
        }
        
    }
    
    else {
        print("File does not exist")
    }
    return(output_str)
    
}

func write_to_file(input_str: String) -> Void {
	let text = input_str
	
	let path = NSHomeDirectory() + "data.txt"
		
	//writing
	do {
		try text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
	}
	catch {
		/* error handling here */
	}
}

func file_exists() -> Bool {
	let filemgr = NSFileManager.defaultManager()
	let destinationPath: String! = NSHomeDirectory() + "text.txt"
	
	return(filemgr.fileExistsAtPath(destinationPath))
}
