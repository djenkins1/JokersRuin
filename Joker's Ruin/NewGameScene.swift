//
//  NewGameScene.swift
//  Joker's Ruin
//
//  Created by Dilan Jenkins on 8/3/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//

import Foundation
import SpriteKit

class NewGameScene : MyScene
{
	let myModel = GameModel()
	
	var aiButtons = [UIButton]()
	
	override func didMoveToView(view: SKView)
	{
		createBackground()
		showView( true )
	}
	
	private func showView( isOpponentAI : Bool )
	{
		myController.clearView()
		if isOpponentAI
		{
			var yStart : CGFloat = 100
			let padScalar : CGFloat = 1.25
			var lastAddedButton = addButton( ButtonFactory.createCenteredButton( "New Game", buttonType: .TitleButton , yPos: yStart) )
			yStart += lastAddedButton.frame.height * padScalar
			aiButtons = showChoicesAI( yStart  )
			for button in aiButtons
			{
				lastAddedButton = addButton( button )
				//TODO: selected choice shows up differently similar to Grove Hero
				//add press event to each button that goes to function that determines choice, then call cycle function to change appearance
				//	have basis for this below in class NewGameCardTouched
				yStart += lastAddedButton.frame.height * padScalar
			}
			
			lastAddedButton = addButton( ButtonFactory.createCenteredButton( "Choose Color", buttonType: .TitleButton, yPos: yStart ) )
			yStart += lastAddedButton.frame.height * padScalar
			
			//TODO: choices for color, either red/black. Card shows up similar to credits( show either King of Spades or King of Diamonds)
			//	just have two cards next to each other with some padding, nonChosen card has opacity < 1.0
			//		add press event listener to each card, one event listener for black and one for red
			
			
			
			//TODO: menu button at bottom center that shows other choice for opponent, i.e computer shows if human and vice versa
		}
		else
		{
			//TODO LATER: initiates game center splash screen
			//	does not allow for choice of color, pick colors randomly for each player
			print( "Multiplayer feature missing" )
			myController.changeState( .Menu )
			return
		}
	}
	
	private func showChoicesAI( yPos : CGFloat ) -> [UIButton]
	{
		var toReturn = [UIButton]()
		let allChoices = ChoiceAI.allComputerAI()
		let buttonType = ButtonType.MenuButton
		var yStart = yPos
		let padScalar : CGFloat = 1.25
		
		var index = -1
		for choice in allChoices
		{
			index += 1
			toReturn.append( ButtonFactory.createCenteredButton( choice.rawValue , buttonType: buttonType, yPos: yStart) )
			yStart += toReturn.last!.frame.height * padScalar
		}
		
		return toReturn
	}
	
	func chooseColor( color : CardColor )
	{
		//cycle through all cardObjs in array and change their opacity based on their color
	}
	
	func chooseAI( choice : ChoiceAI )
	{
		for button in aiButtons
		{
			let ai = ChoiceAI( rawValue:  button.currentTitle! )
			if choice == ai
			{
				//TODO: change to selected look
			}
			else
			{
				//TODO: change to non-selected look
			}
		}
		
		myModel.currentAI = choice.getMyAI()
	}
}

class NewGameCardTouched : TouchEventObserver
{
	let scene : NewGameScene
	
	init( scene : NewGameScene )
	{
		self.scene = scene
	}
	
	func notifyTouched(location: CGPoint, obj: GameObj)
	{
		//tell scene that whatever color this card represents has been pressed
		if obj is CardObj
		{
			let color = ( obj as! CardObj ).myCard.color
			scene.chooseColor( color )
		}
	}
}
