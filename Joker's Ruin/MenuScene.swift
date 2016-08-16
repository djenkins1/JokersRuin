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
		makeMuteButton()
	}
	
	private func makeButtons()
	{
		var startY : CGFloat = 100
		let padScale : CGFloat = 1.5
		var lastAddedButton = addButton( ButtonFactory.createCenteredButton( "Joker's Ruin", buttonType: .TitleButton , yPos: startY ) )
		startY += lastAddedButton.frame.height * padScale
		
		let buttonKeys = [ ( "New Game" , GameState.NewGame.rawValue ),
		                   ( "Continue" , GameState.Continue.rawValue ),
		                   ( "Help" , GameState.Help.rawValue ),
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
	
	private func makeMuteButton()
	{
		let muteButton = GameObj( spriteName: myController.muteSpriteFromStatus(), xStart: 32, yStart: UIScreen.mainScreen().bounds.height - 64 )
		muteButton.withTouchObserver( MuteButtonHandler( scene: self ) )
		muteButton.sprite.xScale = 2.0
		muteButton.sprite.yScale = 2.0
		muteButton.sprite.anchorPoint = CGPoint( x: 0.0, y: 0.5 )
		addGameObject( muteButton )
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

class MuteButtonHandler : TouchEventObserver
{
	let menuScene : MenuScene
	
	init( scene : MenuScene )
	{
		menuScene = scene
	}
	
	func notifyTouched(location: CGPoint, obj: GameObj)
	{
		menuScene.myController.toggleMute()
		let newSprite = menuScene.myController.muteSpriteFromStatus()
		obj.setSprite( newSprite )
	}
}