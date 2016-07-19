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
	
	init( card : Card, xStart : CGFloat, yStart: CGFloat )
	{
		myCard = card
		super.init(spriteName: card.getSpriteString(), xStart: xStart, yStart: yStart )
	}
	
	func changeToCard( card : Card )
	{
		myCard = card
		setSprite( myCard.getSpriteString() )
	}
}