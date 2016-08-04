//
//  MenuScene.swift
//  Joker's Ruin
//
//  Created by Dilan Jenkins on 7/30/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//

import Foundation
import SpriteKit

class MenuScene : MyScene
{
	override func didMoveToView(view: SKView)
	{
		createBackground()
		makeButtons()
	}
	
	func makeButtons()
	{
		var startY : CGFloat = 100
		let padScale : CGFloat = 1.5
		var lastAddedButton = addButton( ButtonFactory.createCenteredButton( "Joker's Ruin", buttonType: .TitleButton , yPos: startY ) )
		startY += lastAddedButton.frame.height * padScale
		
		let buttonKeys = [ ( "New Game" , GameState.Play.rawValue ),//change to : GameState.NewGame.rawValue
		                   ( "Continue" , GameState.Continue.rawValue ),
		                   ( "Help" , GameState.NewGame.rawValue ), //change back to: GameState.Help.rawValue
		                   ( "Credits" , GameState.Credits.rawValue ) ]
		
		for ( key, value ) in buttonKeys
		{
			lastAddedButton = addButton( ButtonFactory.createCenteredButton( key, buttonType: .MenuButton , yPos: startY ) )
			lastAddedButton.tag = value
			lastAddedButton.addTarget( self, action: #selector( self.handleButtonPress(_:)) , forControlEvents: .TouchUpInside)
			startY += lastAddedButton.frame.height * padScale
			
			if value == GameState.Continue.rawValue && !SaveHandler.docFileExists( SaveHandler.saveName, fileType: SaveHandler.saveType )
			{
				ButtonFactory.disableButton( lastAddedButton )
			}
		}
	}
	
	func handleButtonPress( sender: AnyObject )
	{
		if sender is UIButton
		{
			let button = ( sender as! UIButton )
			if let state = GameState( rawValue: button.tag )
			{
				myController.changeState( state )
			}
			else
			{
				print( "Button could not be pressed" )
			}
		}
	}
}