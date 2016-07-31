//
//  SaveHandler.swift
//  Joker's Ruin
//
//  Created by Dilan Jenkins on 7/30/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//

import Foundation

class SaveHandler
{
	//attempts to write the string provided to the file in the documents directory with the name and type provided
	static func writeDocFile( fileName : String, fileType: String, strToWrite : String )
	{
		let filePath = getDocumentsDirectory().stringByAppendingPathComponent("\(fileName).\(fileType)")
		
		do
		{
			try strToWrite.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
		}
		catch let error as NSError
		{
			// failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
			print(error.description)
		}
	}
	
	//returns true if the file with the name and type provided exists in the documents directory or false otherwise
	static func docFileExists( fileName : String , fileType: String ) -> Bool
	{
		let filePath = getDocumentsDirectory().stringByAppendingPathComponent("\(fileName).\(fileType)")
		let manager = NSFileManager.defaultManager()
		return manager.fileExistsAtPath( filePath )
	}
	
	//reads the contents of the file in the documents directory with the file name and type provided
	//returns the contents of the file or an empty string
	static func readDocFile( fileName : String, fileType: String ) -> String
	{
		let filePath = getDocumentsDirectory().stringByAppendingPathComponent("\(fileName).\(fileType)")
		var toReturn = ""
		do
		{
			toReturn = try NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding) as String
		}
		catch let error as NSError
		{
			print(error.description)
		}
		
		return toReturn
	}
	
	//returns the directory path for where documents for this app can be saved
	static func getDocumentsDirectory() -> NSString
	{
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}
	
	//reads the credits data from the credits file and returns a dictionary of it
	static func readCredits() -> Array<Dictionary<String,String>>
	{
		var toReturn = [[String: String]]()
		if let filepath = NSBundle.mainBundle().pathForResource("Credits", ofType: "txt")
		{
			do
			{
				let contents = try NSString(contentsOfFile: filepath, usedEncoding: nil) as String
				toReturn = Process( input: contents ).getObjects()
			}
			catch
			{
				// contents could not be loaded
				print( "Could not load contents")
			}
		}
		else
		{
			print( "File not found" )
		}
		return toReturn
	}
}