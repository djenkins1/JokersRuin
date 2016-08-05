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
	
	var colorChoiceCards = [CardObj]()
	
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
				lastAddedButton.addTarget( self, action: #selector( self.touchButtonAI(_:)) , forControlEvents: .TouchUpInside)
				yStart += lastAddedButton.frame.height * padScalar
			}
			
			lastAddedButton = addButton( ButtonFactory.createCenteredButton( "Choose Color", buttonType: .TitleButton, yPos: yStart ) )
			yStart += lastAddedButton.frame.height * ( padScalar - 0.18 )
			
			let cardY = yStart - ( ( padScalar - 1 ) * yStart )
			colorChoiceCards.append( makeCardChoice( .Diamonds, leftCard: true, yStart: cardY ) )
			colorChoiceCards.append( makeCardChoice( .Spades, leftCard: false, yStart: cardY) )
			updateViewFromModel()
			
			yStart += colorChoiceCards.first!.sprite.frame.height * ( padScalar * 0.5 )

			lastAddedButton = addButton( ButtonFactory.createCenteredButton( "Play", buttonType: .MenuButton , yPos: yStart) )
			lastAddedButton.addTarget( self, action: #selector( self.pressPlay ) , forControlEvents: .TouchUpInside)
			
			
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
	
	private func updateViewFromModel()
	{
		chooseColor( myModel.player.myColor )
		chooseAI( myModel.currentAI.getChoiceAI() )
	}
	
	func pressPlay()
	{
		myController.newGameFromModel( myModel )
	}
	
	private func makeCardChoice( cardSuit : Suits, leftCard : Bool, yStart : CGFloat ) -> CardObj
	{
		let padding : CGFloat = 8
		let cardSprite : CardObj
		if leftCard
		{
			cardSprite = CardObj( card: Card( suit: cardSuit, rank: .King ), xStart: ( self.view!.frame.width * 0.5 ) - padding, yStart: yStart, showFace: true )
			cardSprite.sprite.anchorPoint = CGPoint( x: 1.0, y: 0.5 )
		}
		else
		{
			cardSprite = CardObj( card: Card( suit: cardSuit, rank: .King ), xStart: ( self.view!.frame.width * 0.5 ) + padding, yStart: yStart, showFace: true )
			cardSprite.sprite.anchorPoint = CGPoint( x: 0.0, y: 0.5 )
		}
		
		cardSprite.withTouchObserver( NewGameCardTouched( scene : self ) )
		addGameObject( cardSprite )
		return cardSprite
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
		for card in colorChoiceCards
		{
			if card.myCard.color == color
			{
				card.sprite.alpha = 1.0
			}
			else
			{
				card.sprite.alpha = 0.6
			}
		}
		
		myModel.player.withColor( color )
		myModel.opponent.withColor( color.oppositeColor() )
	}
	
	
	func chooseAI( choice : ChoiceAI )
	{
		for button in aiButtons
		{
			let ai = ChoiceAI( rawValue:  button.currentTitle! )
			ButtonFactory.makeButtonDifferent( button ,revertToSame: !(choice == ai) )
		}
		
		myModel.currentAI = choice.getMyAI()
	}
	
	func touchButtonAI( sender : AnyObject! )
	{
		if sender is UIButton
		{
			let buttonChoice = ( sender as! UIButton ).currentTitle!
			if let ai = ChoiceAI( rawValue: buttonChoice )
			{
				chooseAI( ai )
			}
			else
			{
				print( "Bad choice: \(buttonChoice)" )
			}
		}
		else
		{
			print( "Sender is not a button for ai choice" )
		}
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
