//
//  CardObj.swift
//  Joker's Ruin
//
//  Created by Dilan Jenkins on 7/19/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//

import Foundation
import SpriteKit

class CardObj : GameObj
{
	private(set) var myCard : Card
	
	private(set) var myFlip : Bool
	
	var placeInHand = -1
	
	init( card : Card, xStart : CGFloat, yStart: CGFloat, isFlipped : Bool )
	{
		myCard = card
		myFlip = isFlipped
		let spriteName = ( myFlip ? card.getSpriteString() : CardObj.getCardBackSprite() )
		super.init(spriteName: spriteName, xStart: xStart, yStart: yStart )
		sprite.zPosition += 1
	}
	
	func changeToCard( card : Card )
	{
		myCard = card
	}
	
	override func touchEvent(location: CGPoint)
	{
		super.touchEvent( location )
		if ( myScene != nil )
		{
			myScene.clickCard( placeInHand )
		}
	}
	
	private func updateSprite()
	{
		if ( myFlip )
		{
			setSprite( myCard.getSpriteString() )
		}
		else
		{
			setSprite( CardObj.getCardBackSprite() )
		}
	}
	
	func flipCard( toFront : Bool )
	{
		myFlip = toFront
		updateSprite()
	}
	
	static func getCardBackSprite() -> String
	{
		return "cardBack_blue5"
	}
}