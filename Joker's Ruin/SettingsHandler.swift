//
//  SettingsHandler.swift
//  Joker's Ruin
//
//  Created by Dilan Jenkins on 8/21/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//

import Foundation
import SpriteKit

class SettingsHandler
{
	static var singleHandler : SettingsHandler!
	
	let defaults = NSUserDefaults.standardUserDefaults()
	
	let muteKey = "isMuted"
	
	let helpKey = "beenHelped"
	
	//private in order to make this a singleton
	private init()
	{
		//empty because everything relating to initialization is handled already in the declarations
		//keep init here even if empty, as this is a singleton class
	}
	
	//returns the singleton SettingsHandler, creating it if it does not exist
	static func getHandler() -> SettingsHandler
	{
		if singleHandler == nil
		{
			singleHandler = SettingsHandler()
		}
		
		return singleHandler
	}
	
	//updates and saves the mute status to the value provided
	func updateMuteStatus( newValue : Bool )
	{
		defaults.setBool( newValue, forKey: muteKey )
	}
	
	//updates and saves the help status to the value provided
	func updateHelpStatus( newValue: Bool )
	{
		defaults.setBool( newValue, forKey: helpKey )
	}
	
	//returns the mute status if it has been saved, or false by default
	func getMuteStatus() -> Bool
	{
		return defaults.boolForKey( muteKey )
	}
	
	//returns the help status if it has been saved, or false by default
	func getHelpStatus() -> Bool
	{
		return defaults.boolForKey( helpKey )
	}
}