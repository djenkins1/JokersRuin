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
}

class EasyAI : PlayerAI
{
	func chooseCard( player : Player, middleCard : Card ) -> Int
	{
		//easy AI will always pick their highest card no matter what
		return player.myHand.bestCardIndex
	}
}