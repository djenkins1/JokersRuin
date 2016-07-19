//
//  Cards.swift
//  Joker's Ruin
//
//  Created by Dilan Jenkins on 7/18/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//

import Foundation

class Deck
{
	private var myCards = [Card]()
	
	init()
	{
		let suits : [Suits] = [ .Clubs, .Diamonds, .Hearts, .Spades ]
		let ranks : [Ranks] = [ .Ace, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine, .Ten, .Jack, .Queen, .King ]
		for suit in suits
		{
			for rank in ranks
			{
				myCards.append( Card( suit : suit, rank : rank ) )
			}
		}
	}
	
	func empty() -> Bool
	{
		return myCards.isEmpty
	}
	
	//adds the card provided to the bottom of the deck
	func appendCard( card : Card )
	{
		myCards.append( card )
	}
	
	//removes and returns the card that is on the top of the deck
	func getTopCard() -> Card?
	{
		if ( empty() )
		{
			return nil
		}
		
		return myCards.removeFirst()
	}
	
	func shuffle()
	{
		//TODO:
	}
	
	func printDeck()
	{
		for card in myCards
		{
			print( card.getSpriteString() )
		}
	}
}

class Card
{
	let suit : Suits
	let rank : Ranks
	
	init( suit : Suits , rank : Ranks )
	{
		self.suit = suit
		self.rank = rank
	}
	
	func getSpriteString() -> String
	{
		return "card\(suit.rawValue)\(rank.rawValue)"
	}
	
	func getScore() -> Int
	{
		return Ranks.getScore( self.rank )
	}
	
	//returns true if both cards have the same score
	func equalScore( other : Card ) -> Bool
	{
		return ( self.getScore() == other.getScore() )
	}
	
	//returns true if this card is better than the other card( or equal)
	func betterScore( other : Card ) -> Bool
	{
		return ( self.getScore() >= other.getScore() )
	}
}

enum Suits : String
{
	case Spades
	case Hearts
	case Clubs
	case Diamonds
	case Joker
	
	static func getColorOf( suit : Suits ) -> CardColor
	{
		switch( suit )
		{
		case .Spades:
			return .Black
		case .Clubs:
			return .Black
		case .Diamonds:
			return .Red
		case .Hearts:
			return .Red
		case .Joker:
			return .Joker
		}
	}
}

enum CardColor
{
	case Red
	case Black
	case Joker
}

enum Ranks : String
{
	case Ace = "A"
	case Two = "2"
	case Three = "3"
	case Four = "4"
	case Five = "5"
	case Six = "6"
	case Seven = "7"
	case Eight = "8"
	case Nine = "9"
	case Ten = "10"
	case Jack = "J"
	case Queen = "Q"
	case King = "K"
	case Joker = ""
	
	static func getScore( rank : Ranks ) -> Int
	{
		switch( rank )
		{
		case .Two:
			return 2
		case .Three:
			return 3
		case .Four:
			return 4
		case .Five:
			return 5
		case .Six:
			return 6
		case .Seven:
			return 7
		case .Eight:
			return 8
		case .Nine:
			return 9
		case .Ten:
			return 10
		case .Jack:
			return 11
		case .Queen:
			return 12
		case .King:
			return 13
		case .Ace:
			return 14
		case .Joker:
			return 15
		}
	}
}