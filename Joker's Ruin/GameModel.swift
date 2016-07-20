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
		
		let cardsInHand = 5
		for _ in 1...cardsInHand
		{
			myPlayers[ 0 ].drawCard()
			myPlayers[ 1 ].drawCard()
		}
		
		middleCard = middleDeck.getTopCard()!
		
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
		player.drawCard()
		opponent.drawCard()
		
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
}