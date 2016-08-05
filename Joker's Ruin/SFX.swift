//
//  SFX.swift
//  Joker's Ruin
//
//  Created by Dilan Jenkins on 8/5/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//

import Foundation

enum SFX : String
{
	case WinBattle = "winBattle.wav"
	
	case LoseBattle = "loseBattle.wav"
	
	case DrawBattle = "drawBattle.wav"
	
	case WinJoker = "winJoker.wav"
	
	case WinGame = "winGame.wav"
	
	case TieGame = "tieGame.wav"
	
	case LoseGame = "loseGame.wav"
	
	case HighCard = "highCard.wav"
	
	case NewCard = "newCard.wav"
	
	func getFileName() -> String
	{
		return self.rawValue
	}
}