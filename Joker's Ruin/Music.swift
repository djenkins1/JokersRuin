//
//  Music.swift
//  Joker's Ruin
//
//  Created by Dilan Jenkins on 8/1/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//

import Foundation
import AVFoundation

class Music
{
	private(set) var name : String
	
	private(set) var type : String
	
	init( name : String, type : String )
	{
		self.name = name
		self.type = type
	}
	
	static func musicList() -> Array<Music>
	{
		var toReturn = [Music]()
		toReturn.append( Music( name: "PD_awesomeness" , type: "mp3" ) )
		toReturn.append( Music( name: "PD_Dark Alleys" , type: "mp3" ) )
		toReturn.append( Music( name: "PD_Magic" , type: "mp3" ) )
		toReturn.append( Music( name: "PD_Robotic City" , type: "mp3" ) )
		toReturn.append( Music( name: "PD_tempo" , type: "mp3" ) )
		return toReturn
	}
	
	static func randomMusicList() -> [Music]
	{
		var first = musicList()
		var toReturn = [Music]()
		while first.count > 0
		{
			let indexToTake = Int(arc4random_uniform( UInt32(first.count) ))
			toReturn.append( first.removeAtIndex( indexToTake ) )
		}
		
		return toReturn
	}
	
	func getItem() -> AVPlayerItem
	{
		let urlPath = NSBundle.mainBundle().pathForResource( self.name , ofType: self.type )
		let fileURL = NSURL(fileURLWithPath:urlPath!)
		return AVPlayerItem(URL:fileURL)
	}
}