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
	var menuHand = [CardObj]()
	
	var menuDeck : Deck!
	
	var currentIndex = 0
	
	override func didMoveToView(view: SKView)
	{
		createBackground()
		makeButtons()
		makeMuteButton()
		addCards()
		
		NSTimer.scheduledTimerWithTimeInterval(2.0 , target: self, selector: #selector(self.timerHandEvent), userInfo: nil, repeats: false)
	}
	
	func timerHandEvent()
	{
		let card = menuHand[ currentIndex ]
		//if there are no more cards in the deck, replace the card with a joker and get a new deck
		if let newCard = menuDeck.getTopCard()
		{
			animateCardChange( card, newCard: newCard )
		}
		else
		{
			animateCardChange( card, newCard: Card.getJoker() )
			menuDeck = Deck()
		}
		
		currentIndex += 1
		if currentIndex >= menuHand.count
		{
			currentIndex = 0
		}
	}
	
	private func animateCardChange( card: CardObj, newCard: Card )
	{
		let fadeOut = SKAction.fadeOutWithDuration( 0.75 )
		let fadeIn = SKAction.fadeInWithDuration( 0.75 )
		card.sprite.runAction( fadeOut, completion:
			{
				card.changeToCard( newCard )
				card.sprite.runAction( fadeIn, completion:
					{
						NSTimer.scheduledTimerWithTimeInterval( 2.0 , target: self, selector: #selector(self.timerHandEvent), userInfo: nil, repeats: false)
				})
		})
	}
	
	private func makeButtons()
	{
		var startY : CGFloat = 100
		let padScale : CGFloat = 1.5
		var lastAddedButton = addButton( ButtonFactory.createCenteredButton( "Joker's Ruin", buttonType: .TitleButton , yPos: startY ) )
		startY += lastAddedButton.frame.height * padScale
		
		//if the player has finished the tutorial, new game will take them actually do a new game, otherwise the tutorial is shown if it has not been completed
		let newGameValue = ( SettingsHandler.getHandler().getHelpStatus() ? GameState.NewGame.rawValue : GameState.Help.rawValue )
		
		let buttonKeys = [ ( "New Game" , newGameValue ),
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
	
	private func addCards()
	{
		menuDeck = Deck()
		menuDeck.shuffle( 5 )
		let hand = Deck(withCards: [ menuDeck.getTopCard()!, menuDeck.getTopCard()!, menuDeck.getTopCard()!, menuDeck.getTopCard()!, Card.getJoker() ] )
		menuHand = layoutCards( hand )
	}
	
	private func layoutCards( hand: Deck ) -> [CardObj]
	{
		var allCards = [CardObj]()
		let totalCards = hand.totalCards
		for index in 0..<totalCards
		{
			let card = hand.getTopCard()!
			let xPadding = CGFloat( 0.07 * CGFloat( index ) )
			let newCard = addGameObject( CardObj( card: card, xStart: (0.25 + xPadding) * view!.bounds.width, yStart: 0.15 * view!.bounds.height, showFace: true ) )
			newCard.sprite.runAction(SKAction.rotateByAngle(CGFloat( M_PI ) / CGFloat( 8 + index ), duration: 0.0))
			newCard.sprite.zPosition += CGFloat( index )
			allCards.append( (newCard as! CardObj) )
		}
		
		return allCards
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