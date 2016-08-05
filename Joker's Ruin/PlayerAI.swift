//
//  PlayerAI.swift
//  Joker's Ruin
//
//  Created by Dilan Jenkins on 7/20/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//

import Foundation

protocol PlayerAI
{
	func chooseCard( player : Player, middleCard : Card ) -> Int
	
	func getChoiceAI() -> ChoiceAI
}

class EasyAI : PlayerAI
{
	func chooseCard( player : Player, middleCard : Card ) -> Int
	{
		//easy AI will pick a random card from their hand
		return Int( arc4random_uniform( UInt32( player.myHand.totalCards ) ) )
	}
	
	func getChoiceAI() -> ChoiceAI
	{
		return .Easy
	}
}

class MediumAI : PlayerAI
{
	func chooseCard( player : Player, middleCard : Card ) -> Int
	{
		//this AI will always pick their highest card no matter what
		return player.myHand.bestCardIndex
	}
	
	func getChoiceAI() -> ChoiceAI
	{
		return .Medium
	}
}

class HardAI : PlayerAI
{
	func chooseCard( player : Player, middleCard : Card ) -> Int
	{
		//play the lowest card in the hand if the middle card is a joker
		//	or play the highest card otherwise
		if middleCard.isJoker
		{
			return player.myHand.worstCardIndex
		}
		
		return player.myHand.bestCardIndex
	}
	
	func getChoiceAI() -> ChoiceAI
	{
		return .Hard
	}
}

enum ChoiceAI : String
{
	case Easy
	
	case Medium
	
	case Hard
	
	static func getAI( strValue : String ) -> PlayerAI?
	{
		switch( strValue )
		{
		case Easy.rawValue:
			return EasyAI()
		case Medium.rawValue:
			return MediumAI()
		case Hard.rawValue:
			return HardAI()
		default:
			return nil
		}
	}
	
	func getMyAI() -> PlayerAI
	{
		switch( self )
		{
		case .Easy:
			return EasyAI()
		case .Medium:
			return MediumAI()
		case .Hard:
			return HardAI()
		}
	}
	
	static func allComputerAI() -> [ChoiceAI]
	{
		return [ .Easy, .Medium, .Hard ]
	}
}