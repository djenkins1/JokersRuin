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

enum ChoiceAI : String
{
	case Easy
	
	case Medium
	
	static func getAI( strValue : String ) -> PlayerAI?
	{
		switch( strValue )
		{
		case Easy.rawValue:
			return EasyAI()
		case Medium.rawValue:
			return MediumAI()
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
		}
	}
	
	static func allComputerAI() -> [ChoiceAI]
	{
		return [ .Easy, .Medium ]
	}
}