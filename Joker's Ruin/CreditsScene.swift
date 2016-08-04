//
//  CreditsScene.swift
//  Joker's Ruin
//
//  Created by Dilan Jenkins on 8/2/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//

import Foundation
import SpriteKit

class CreditsScene : MyScene
{
	var creditsList = Array<Dictionary<String,String>>()
	
	private(set) var creditIndex = 0
	
	var cardSprite : CardObj!
	
	var contributorLabel : SKLabelNode!
	
	var contributionLabel : SKLabelNode!
	
	override func didMoveToView(view: SKView)
	{
		createBackground()
		creditsList = SaveHandler.readCredits()
		populateView()
		changeCreditInfo( 0 )
		scheduleCardTimer()
	}
	
	private func populateView()
	{
		var startY : CGFloat = 100
		let padScale : CGFloat = 1.8
		let lastAddedButton = addButton( ButtonFactory.createCenteredButton( "Credits", buttonType: .TitleButton , yPos: startY ) )
		startY += lastAddedButton.frame.height * padScale
		startY = convertPointY( startY )
		
		cardSprite = CardObj( card: Card( suit: .Hearts, rank: .Queen ), xStart: self.view!.frame.width * 0.5, yStart: startY, showFace: true )
		cardSprite.withTouchObserver( CreditsCardTouched( scene : self ) )
		cardSprite.sprite.anchorPoint = CGPoint( x: 0.5, y: 0.5)
		cardSprite.sprite.xScale = 2.0
		cardSprite.sprite.yScale = 2.0
		addGameObject( cardSprite )
		
		contributorLabel = addMakeLabel( "Contributor", xPos: cardSprite.sprite.position.x, yPos: cardSprite.sprite.position.y - ( cardSprite.sprite.frame.height * 0.65 ), fontSize: 32, convertPoint: false )
		contributionLabel = addMakeLabel( "Contribution" , xPos: cardSprite.sprite.position.x, yPos: contributorLabel.position.y - contributorLabel.frame.height , fontSize: 32, convertPoint: false )
		
	}
	
	func scheduleCardTimer()
	{
		NSTimer.scheduledTimerWithTimeInterval( 4.0 , target: self, selector: #selector(self.nextCard), userInfo: nil, repeats: false)
	}
	
	//changes the view to show the next credit item
	func nextCard()
	{
		let fadeOut = SKAction.fadeOutWithDuration( 0.75 )
		let fadeIn = SKAction.fadeInWithDuration( 0.75 )
		let action = SKAction.sequence( [ fadeOut, fadeIn ] )
		contributorLabel.runAction( action )
		contributionLabel.runAction( action )
		cardSprite.sprite.runAction( fadeOut, completion:
			{
				if self.creditIndex + 1 >= self.creditsList.count
				{
					self.myController.changeState( .Menu )
					return
				}
				
				self.changeCreditInfo( self.creditIndex + 1 )
				self.cardSprite.sprite.runAction( fadeIn, completion:
					{
						self.scheduleCardTimer()
				})
		})
	}

	//when a credits button is clicked on in credits view, show the web page link associated with that button
	func gotoCreditsPage( urlString : String? )
	{
		if let url = urlString
		{
			UIApplication.sharedApplication().openURL(NSURL(string: url)!)
		}
	}
	
	func changeCreditInfo( newIndex : Int )
	{
		creditIndex = newIndex
		if let card = Card( cardSerial: creditsList[ creditIndex ][ "card" ]! )
		{
			cardSprite.changeToCard( card )
		}
		else
		{
			print( "BAD CARD" )
			return
		}
		
		contributorLabel.text = creditsList[ creditIndex ][ "author" ]
		contributionLabel.text = creditsList[ creditIndex ][ "title" ]
	}
	
	func cardTouched()
	{
		//get the current index and use that to find the url
		//open up the browser with the url
		gotoCreditsPage( creditsList[ creditIndex ][ "link" ] )
	}
}


class CreditsCardTouched : TouchEventObserver
{
	let scene : CreditsScene
	
	init( scene : CreditsScene )
	{
		self.scene = scene
	}
	
	func notifyTouched(location: CGPoint, obj: GameObj)
	{
		scene.cardTouched()
	}
}