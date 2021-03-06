//
//  Cards.swift
//  Joker's Ruin
//
//  Created by Dilan Jenkins on 7/18/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//

import Foundation
import SpriteKit

class Player
{
	private(set) var myDeck : Deck
	
	private(set) var myHand : Deck
	
	var myScore : Int
	
	private(set) var myColor : CardColor
	
	init( color : CardColor )
	{
		myDeck = Deck( withCards : [Card]() )
		myHand = Deck( withCards : [Card]() )
		myScore = 0
		myColor = color
	}
	
	func drawCard() -> Bool
	{
		if let newCard = myDeck.getTopCard()
		{
			myHand.appendCard( newCard )
			return true
		}
		
		return false
	}
	
	//sets myColor to the color provided and returns itself to allow for chaining
	func withColor( color : CardColor ) -> Player
	{
		myColor = color
		return self
	}
	
	func changeDeck( deck : Deck )
	{
		myDeck = deck
	}
	
	func changeHand( hand : Deck )
	{
		myHand = hand
	}
	
	func changeScore( score : Int )
	{
		myScore = score
	}
	
}

class Deck
{
	private var myCards = [Card]()
	
	var lastCard : Card?
	{
		return myCards.last
	}
	
	var totalCards : Int
	{
		return myCards.count
	}
	
	var bestCardIndex : Int
	{
		var toReturn = 0
		for i in 1..<myCards.count
		{
			let currentBest = myCards[ toReturn ]
			let currentCard = myCards[ i ]
			if ( currentCard.betterScore( currentBest ) )
			{
				toReturn = i
			}
		}
		
		return toReturn
	}
	
	var worstCardIndex : Int
	{
		var toReturn = 0
		for i in 1..<myCards.count
		{
			let currentWorst = myCards[ toReturn ]
			let currentCard = myCards[ i ]
			if ( currentWorst.betterScore( currentCard ) )
			{
				toReturn = i
			}
		}
		
		return toReturn
	}
	
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
	
	init( withCards : [Card] )
	{
		myCards = withCards
	}
	
	init?( fromSerial: String )
	{
		let cards = fromSerial.componentsSeparatedByString(" ")
		if cards.isEmpty
		{
			return nil
		}
		
		myCards = [Card]()
		for cardSerial in cards
		{
			if let card = Card( cardSerial: cardSerial )
			{
				myCards.append( card )
			}
			else
			{
				print( "Bad card: \(cardSerial)" )
				return nil
			}
		}
	}
	
	func empty() -> Bool
	{
		return myCards.isEmpty
	}
	
	func removeAt( index: Int ) -> Card?
	{
		if ( index < 0 || index >= myCards.count )
		{
			return nil
		}
		
		return myCards.removeAtIndex( index )
	}
	
	func peekAt( index : Int ) -> Card?
	{
		if ( index >= myCards.count )
		{
			return nil
		}
		return myCards[ index ]
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
	
	func shuffle( totalTimes : Int = 1 )
	{
		for _ in 1...totalTimes
		{
			shuffleOnce()
		}
	}
	
	private func shuffleOnce()
	{
		var shuffled = [Card]()
		shuffled.reserveCapacity( myCards.count )
		while myCards.count > 0
		{
			let indexOfCard = Int( arc4random_uniform( UInt32(myCards.count ) ) )
			
			let indexToPlace = ( shuffled.isEmpty ? 0 : Int( arc4random_uniform( UInt32(shuffled.count ) ) ) )
			shuffled.insert( myCards.removeAtIndex( indexOfCard ), atIndex: indexToPlace )
		}
		
		myCards = shuffled
	}
	
	func getSerialString() -> String
	{
		var cardArray = [String]()
		for card in myCards
		{
			cardArray.append( card.getSerialString() )
		}
		
		return cardArray.joinWithSeparator(" ")
	}
	
	func printDeck()
	{
		for card in myCards
		{
			print( card.getSpriteString() )
		}
	}
	
	func removeJoker()
	{
		var index = -1
		for card in myCards
		{
			index += 1
			if card.isJoker
			{
				break
			}
		}
		
		if index < totalCards
		{
			myCards.removeAtIndex( index )
		}
	}
	
	func putJokerAtIndex( newIndex: Int )
	{
		if newIndex >= totalCards
		{
			return
		}
		
		removeJoker()
		myCards.insert( Card.getJoker(), atIndex: newIndex )
	}
}

class Card
{
	let suit : Suits
	let rank : Ranks
	
	var isJoker : Bool
	{
		return ( suit == .Joker || rank == .Joker )
	}
	
	var color : CardColor
	{
		return Suits.getColorOf( suit )
	}
	
	init( suit : Suits , rank : Ranks )
	{
		self.suit = suit
		self.rank = rank
	}
	
	convenience init?( cardSerial : String )
	{
		if cardSerial.characters.count == 0
		{
			return nil
		}
		
		if let suit = Suits.suitFromLetter( cardSerial[ 0 ] )
		{
			if suit == .Joker
			{
				self.init( suit: suit, rank: .Joker )
				return
			}
			
			if let rank = Ranks( rawValue: cardSerial.substringFromIndex( cardSerial.startIndex.advancedBy( 1 ) ) )
			{
				self.init( suit: suit, rank: rank )
				return
			}
		}
		
		return nil
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
	
	static func getJoker() -> Card
	{
		return Card( suit: .Joker, rank: .Joker )
	}
	
	func getSerialString() -> String
	{
		return "\(suit.letterFromSuit())\(rank.rawValue)"
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
	
	func letterFromSuit() -> String
	{
		switch( self )
		{
		case .Spades:
			return "S"
		case .Hearts:
			return "H"
		case .Diamonds:
			return "D"
		case .Clubs:
			return "C"
		case .Joker:
			return "J"
		}
	}
	
	static func suitFromLetter( suitLetter : String ) -> Suits?
	{
		let charString : String = suitLetter[ 0 ]
		switch( charString  )
		{
		case "S":
			return .Spades
		case "C":
			return .Clubs
		case "D":
			return .Diamonds
		case "H":
			return .Hearts
		case "J":
			return .Joker
		default:
			return nil
		}
	}
}

enum CardColor : String
{
	case Red
	case Black
	case Joker
	
	static func colorCode( myColor : CardColor ) -> UIColor
	{
		switch( myColor )
		{
		case .Red:
			return UIColor.redColor()
		case .Black:
			return UIColor.blackColor()
		case .Joker:
			return UIColor.greenColor()
			
		}
	}
	
	func oppositeColor() -> CardColor
	{
		switch( self )
		{
		case .Red:
			return .Black
		case .Black:
			return .Red
		case .Joker:
			return self
		}
	}
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

extension String
{
	
	subscript (i: Int) -> Character
	{
		return self[self.startIndex.advancedBy(i)]
	}
	
	subscript (i: Int) -> String
	{
		return String(self[i] as Character)
	}
}