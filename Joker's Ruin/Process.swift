//
//  Process.swift
//  Viridia
//
//  Created by Dilan Jenkins on 5/25/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//

import Foundation

class Process
{
	var input : String
	
	init( input: String )
	{
		self.input = input
	}
	
	func getObjects() -> Array<Dictionary<String,String>>
	{
		return breakDictionary( breakObjects( input ) )
	}
	
	func breakObjects( myInput : String ) -> Array<String>
	{
		var commentMode = false
		var toReturn = [String]()
		var currentString = ""
		for i in myInput.characters
		{
			if ( commentMode )
			{
				if ( i == "^" )
				{
					commentMode = false
				}
				continue
			}
			else if ( i == "^" )
			{
				commentMode = true
				continue
			}
			
			if ( i == "#" )
			{
				toReturn.append( currentString )
				currentString = ""
			}
			else
			{
				currentString.append( i )
			}
		}
		return toReturn
	}
	
	func trimString( toTrim : String ) -> String
	{
		return toTrim.stringByTrimmingCharactersInSet( NSCharacterSet.whitespaceAndNewlineCharacterSet() )
	}
	
	func addTokensToDict( objStr : String ) -> Dictionary<String,String>
	{
		var objDict = [ String : String ]()
		var newString = objStr.stringByReplacingOccurrencesOfString("\n", withString: " ")
		newString = newString.stringByReplacingOccurrencesOfString("\t", withString: " ")
		let tokens = newString.componentsSeparatedByString(" ")
		var seperator = ""
		var currentAttr = ""
		var currentValue = ""
		var index = -1
		for token in tokens
		{
			index = index + 1
			if token == ""
			{
				if ( index != tokens.count - 1 )
				{
					continue
				}
				else
				{
					objDict[ currentAttr ] = currentValue
					break
				}
			}
			
			if token[ token.startIndex ] == Character( "@" )
			{
				if ( currentAttr != "" )
				{
					objDict[ currentAttr ] = currentValue
					currentValue = ""
					seperator = ""
					currentAttr = token.substringFromIndex( token.startIndex.successor() )
				}
				else
				{
					currentAttr = token.substringFromIndex( token.startIndex.successor() )
				}
			}
			else
			{
				currentValue = currentValue + seperator + token
				seperator = " "
			}
		}
		
		return objDict
	}
	
	func breakDictionary( objects: Array<String> ) -> Array<Dictionary<String,String>>
	{
		var toReturn = [[String: String]]()
		for objStr in objects
		{
			toReturn.append( addTokensToDict( objStr ) )
		}
		return toReturn
		
	}
	
	//converts an array of dictionaries back into the save format
	static func convertToString( objects : Array<Dictionary<String,String>> ) -> String
	{
		var toReturn = ""
		for obj in objects
		{
			for ( key, value ) in obj
			{
				toReturn += ( "@\(key)\n\t\(value)\n" )
			}
			
			toReturn += "#\n"
		}
		return toReturn
	}
	
	//returns a dictionary wherein every dictionary in objects array is now referenced in the
	//	returned dictionary by a key that corresponds to the key in the obj named key
	static func extractKeys( objects : Array<Dictionary<String,String>> ) -> Dictionary<String,Dictionary<String,String>>
	{
		var toReturn = Dictionary<String,Dictionary<String,String>>()
		for dict in objects
		{
			if let key = dict[ "key" ]
			{
				print( "key is \(key)" )
				toReturn[ key ] = dict
			}
			else
			{
				print( "Missing key in \(convertToString( [ dict ]))" )
			}
			
		}
		return toReturn
	}
	
}
