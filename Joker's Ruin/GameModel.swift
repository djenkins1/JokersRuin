//
//  GameModel.swift
//  Joker's Ruin
//
//  Created by Dilan Jenkins on 7/19/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//

import Foundation

class GameModel
{
	private(set) var player : Player
	
	private(set) var opponent : Player
	
	private(set) var middleDeck : Deck
	
	private(set) var middleCard : Card
	
	let bonusPointsForColor = 4
	
	init?( objDict : Dictionary<String,String> )
	{
		for key in SaveConstants.allValues
		{
			if objDict[ key.rawValue ] == nil
			{
				print( "\(key.rawValue) is missing" )
				return nil
			}
		}
		
		player = Player( color : CardColor( rawValue: objDict[SaveConstants.playerColor.rawValue]! )! )
		if let playerDeck = Deck( fromSerial: objDict[ SaveConstants.playerDeck.rawValue]! )
		{
			player.changeDeck( playerDeck )
		}
		else
		{
			print( "Player deck bad" )
			return nil
		}
		
		if let playerHand = Deck( fromSerial: objDict[ SaveConstants.playerHand.rawValue]! )
		{
			player.changeHand( playerHand )
		}
		else
		{
			print( "Player hand bad" )
			return nil
		}
		
		opponent = Player( color: CardColor( rawValue: objDict[SaveConstants.opponentColor.rawValue]! )! )
		if let otherDeck = Deck( fromSerial: objDict[ SaveConstants.opponentDeck.rawValue]! )
		{
			opponent.changeDeck( otherDeck )
		}
		else
		{
			print( "Opponent deck bad" )
			return nil
		}
		
		if let opponentHand = Deck( fromSerial: objDict[ SaveConstants.opponentHand.rawValue]! )
		{
			opponent.changeHand( opponentHand )
		}
		else
		{
			print( "Opponent hand bad" )
			return nil
		}
		

		player.changeScore( Int( objDict[ SaveConstants.playerScore.rawValue]! )! )
		opponent.changeScore( Int( objDict[ SaveConstants.opponentScore.rawValue]! )! )
		
		if let deck = Deck(fromSerial: objDict[ SaveConstants.middleDeck.rawValue ]!)
		{
			middleDeck = deck
		}
		else
		{
			print( "Middle deck bad" )
			return nil
		}
		
		if let card = Card(cardSerial: objDict[ SaveConstants.middleCard.rawValue ]! )
		{
			middleCard = card
		}
		else
		{
			print( "Middle card bad" )
			return nil
		}
		
	}
	
	init()
	{
		middleDeck = Deck()
		middleDeck.shuffle( 6 )
		player = Player( color : .Red )
		opponent = Player( color : .Black )
		
		var myPlayers = [ player, opponent ]
		var cardsToDeal = 15 * myPlayers.count
		while cardsToDeal > 0
		{
			cardsToDeal -= 1
			myPlayers[ 0 ].myDeck.appendCard( middleDeck.getTopCard()! )
			myPlayers.append( myPlayers.removeFirst() )
		}
		
		middleDeck.appendCard( Card(suit: .Joker, rank: .Joker) )
		middleDeck.shuffle( 2 )
		
		//if the joker is at the top of the deck, shuffle the deck again
		if middleDeck.peekAt( 0 )!.isJoker
		{
			middleDeck.shuffle()
			//if the joker is still at the top of the deck, put it on the bottom of the deck
			if middleDeck.peekAt( 0 )!.isJoker
			{
				middleDeck.appendCard( middleDeck.getTopCard()! )
			}
		}
		
		let cardsInHand = 5
		for _ in 1...cardsInHand
		{
			myPlayers[ 0 ].drawCard()
			myPlayers[ 1 ].drawCard()
		}
		
		middleCard = middleDeck.getTopCard()!
		
		//TESTING:
		/*
		print( "Testing Cards" )
		let handSerialized = "SA J H7 D3 CJ"
		print( "Before: \(handSerialized)" )
		if let testDeck = Deck( fromSerial: handSerialized )
		{
			testDeck.printDeck()
			print( "Serialized Deck: \(testDeck.getSerialString())" )
		}
		else
		{
			print( "Problem with deck" )
		}
		print( "" )
		*/
	}
	
	func getSerialFormat() -> Dictionary<String, String>
	{
		var toReturn = [String : String]()
		toReturn[ SaveConstants.playerHand.rawValue ] = player.myHand.getSerialString()
		toReturn[ SaveConstants.playerDeck.rawValue ] = player.myDeck.getSerialString()
		toReturn[ SaveConstants.playerScore.rawValue ] = "\(player.myScore)"
		toReturn[ SaveConstants.playerColor.rawValue ] = player.myColor.rawValue
		toReturn[ SaveConstants.opponentDeck.rawValue ] = opponent.myDeck.getSerialString()
		toReturn[ SaveConstants.opponentHand.rawValue ] = opponent.myHand.getSerialString()
		toReturn[ SaveConstants.opponentScore.rawValue ] = "\(opponent.myScore)"
		toReturn[ SaveConstants.opponentColor.rawValue ] = opponent.myColor.rawValue
		toReturn[ SaveConstants.middleCard.rawValue ] = middleCard.getSerialString()
		toReturn[ SaveConstants.middleDeck.rawValue ] = middleDeck.getSerialString()
		
		return toReturn
	}
	
	func debugPrint()
	{
		print( "Player's Hand" )
		player.myHand.printDeck()
		print( "Player's deck count: \(player.myDeck.totalCards)" )
		
		print( "\n" )
		print( "Opponent's Hand" )
		opponent.myHand.printDeck()
		print( "Opponent's deck count: \(opponent.myDeck.totalCards)" )
		
		print( "Middle card: \(middleCard.getSpriteString() )" )
		print( "Middle Deck count: \(middleDeck.totalCards)" )
	}
	
	func debugScore()
	{
		print( "Player Score: \(player.myScore)" )
		print( "Opponent Score: \(opponent.myScore)" )
		print( "" )
	}
	
	//returns true if the player won the battle or false if opponent won
	//returns nil in the event of a draw
	func battle( playerCard : Card, opponentCard : Card ) -> Bool?
	{
		var toReturn : Bool? = nil
		if ( playerCard.equalScore( opponentCard ) )
		{
			handleBattle( player, loser: opponent, isDraw: true )
			toReturn = nil
		}
		else if ( playerCard.betterScore( opponentCard ) )
		{
			toReturn = true
			handleBattle( player, loser: opponent, isDraw: false )
		}
		else
		{
			toReturn = false
			handleBattle( opponent, loser: player, isDraw: false )
		}
		
		middleCard = middleDeck.getTopCard()!
		return toReturn
	}
	
	private func handleBattle( winner : Player, loser : Player,  isDraw : Bool )
	{
		if ( middleCard.isJoker )
		{
			winner.myScore = winner.myScore / 2
			if ( isDraw )
			{
				loser.myScore = loser.myScore / 2
			}
			
			return
		}
		
		winner.myScore += totalScoreFromCard( middleCard )
		if ( isDraw )
		{
			loser.myScore += totalScoreFromCard( middleCard )
		}
		else
		{
			if ( winner.myColor == middleCard.color )
			{
				winner.myScore += bonusPointsForColor
			}
		}
	}
	
	func totalScoreFromCard( card : Card ) -> Int
	{
		return card.getScore() / 2
	}
	
	private func finalScore( player : Player )
	{
		for i in 0..<player.myHand.totalCards
		{
			if let card = player.myHand.peekAt( i )
			{
				player.myScore += totalScoreFromCard( card )
				if ( card.color == player.myColor )
				{
					player.myScore += bonusPointsForColor
				}
			}
			
		}
	}
	
	func calculateFinalScores()
	{
		finalScore( player )
		finalScore( opponent )
	}
	
	func isGameOver() -> Bool
	{
		let maxCardsInHand = 5
		let playerHandMinusOne = ( player.myDeck.empty() && player.myHand.totalCards == (maxCardsInHand - 1) )
		let opponentHandMinusOne = ( opponent.myDeck.empty() && opponent.myHand.totalCards == (maxCardsInHand - 1) )
		return  playerHandMinusOne || opponentHandMinusOne
	}
	
	func gameWinState() -> WinState?
	{
		if !isGameOver()
		{
			return nil
		}
		
		if ( player.myScore == opponent.myScore )
		{
			return .PlayerDraw
		}
		
		return ( player.myScore > opponent.myScore ? .PlayerWon : .PlayerLost )
	}
}

enum WinState : String
{
	case PlayerWon = "Won"
	case PlayerLost = "Lost"
	case PlayerDraw = "Tied"
}

enum SaveConstants : String
{
	static let allValues = [playerHand, opponentHand, playerDeck, opponentDeck, playerScore, opponentScore, playerColor, opponentColor, middleCard, middleDeck ]
	
	case playerHand
	case opponentHand
	case playerDeck
	case opponentDeck
	case playerScore
	case opponentScore
	case playerColor
	case opponentColor
	case middleCard
	case middleDeck
}