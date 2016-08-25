//
//  GameScene.swift
//  Joker's Ruin
//
//  Created by Dilan Jenkins on 7/19/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//
//
/*
//----------
//TODO:
//----------
//	has weird positioning of cards(deckCards) on ipad
//	should test positioning of credits/new game scene on smaller/bigger iphones other than 5s
//	also should test tutorial on bigger/smaller iphones
//
//	(SPRITE)should recolor the joker to be green so as to not be ambiguos for bonus points
//	(SPRITE)App Icon
//	if there is a saved game to continue, should ask the user if they wish to still do a new game and overwrite the old one
//	should also have some animation for winning/losing game
//		fireworks going off for winning
//		cards spinning and falling from top of the screen for losing/draw
//	beef up the hard ai to take color of card into account
//
//	(SCRAP)decide: brand new game is not saved until after the first battle, should this be different?
//		decision: No point saving until the first battle has finished
//	(SCRAP)special animation for who wins the joker
//		maybe animate the joker card spinning, would have to remove animation when put back in middle as new card
//		i.e if the player wins then some kind of joker sprite laughing should show up on screen
//	(SCRAP)maybe for more strategy allow player/opponentAI to use card on top of deck as choice(player cannot see what it is)
//		deck card would have indexInHand equal to totalCards in hand
//
------
(Version2)
------
//	Coins won from games:
//		maybe have score be coins, the total score at end is added to coin purse
//		for every (100/1000) coins, get a gem
//		can use gems to buy specialty things like:
//		customizable card backgrounds
//		unlock more music
//	finish up NewGameScene by adding a toggle button for computer/human
//	Multiplayer game support using Game Center
//		will probably have to refactor some of the GameScene code to make it easier for multiplayer
//			biggest difference in multiplayer: asynchronous choice of card for opponent
//			both players poll the model in order to update the view
//		will also need to disable saving/deletion of model when playing multiplayer game
//			maybe move save code into model function and then call said function with if statement inside to determine if multiplayer
//		will have to do something if one player disconnects, maybe use victory popup text to tell the player
//
*/
import SpriteKit
import AVFoundation

class GameScene : MyScene
{		
	//whether the current game level is won/lost or is still being played
	var doneScreen = false
	
	var model = GameModel()
	
	var playerCards = [CardObj]()
	
	var middleCard : CardObj!
	
	var playerDeckCard : CardObj!
	
	var opponentDeckCard : CardObj!
	
	var opponentCards = [CardObj]()
	
	var placeHolder : GameObj!
	
	var placeHolder2 : GameObj!
	
	var playerChosenCard : CardObj?
	
	var opponentChosenCard : CardObj?
	
	let playerCardPosY = UIScreen.mainScreen().bounds.height * 0.1
	
	let opponentCardPosY = UIScreen.mainScreen().bounds.height * 0.7
	
	var shouldWait = false
	
	var deckLabel : SKLabelNode!
	
	var playerScoreLabel : SKLabelNode!
	
	var opponentScoreLabel : SKLabelNode!
	
	var tutorialHandled : TutorialHandler?
	
	override func didMoveToView(view: SKView)
	{
		/* Setup your scene here */
		/*
		let myLabel = SKLabelNode(fontNamed:"Chalkduster")
		myLabel.text = "Hello, World!"
		myLabel.fontSize = 45
		myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
		self.addChild(myLabel)
		*/
		
		let screenBound = UIScreen.mainScreen().bounds
		createBackground()
		
		let middleCardY = 0.425 * screenBound.height
		middleCard = CardObj( card : model.middleCard , xStart: getCardPosition( model.player.myHand.totalCards - 3 ), yStart: middleCardY , showFace: true )
		middleCard.sprite.zPosition = 50
		placeHolder2 = GameObj( spriteName: "cardPlace" , xStart: getCardPosition( model.player.myHand.totalCards - 1 ), yStart: middleCardY )
		placeHolder = GameObj( spriteName: "cardPlace" , xStart: getCardPosition( model.player.myHand.totalCards - 5 ), yStart: middleCardY )
		placeHolder.withTouchObserver( PlaceHolderTouchObserver( scene: self ) )
		addGameObject( middleCard )
		addGameObject( placeHolder2 )
		addGameObject( placeHolder )
		addGameObject( addDeckCard( model.player.myHand.totalCards, yPos : middleCardY ) )
		addPlayerCardsToView()
		addOpponentCardsToView()
		tutorialHandled?.firstScene( self )
	}
	
	private func addPlayerCardsToView()
	{
		playerCards = addCardsToView( model.player.myHand, facingTop : true, yPos : playerCardPosY )
		for card in playerCards
		{
			card.withTouchObserver( TutorialCardTouchObserver( scene: self ) )
		}
		playerDeckCard = addDeckCard( model.player.myHand.totalCards, yPos: playerCardPosY  )
		let fontSize : CGFloat = 40
		deckLabel = addMakeLabel( "\(model.player.myDeck.totalCards)" , xPos : playerDeckCard.sprite.position.x , yPos : playerCardPosY + ( fontSize * 3 ), fontSize: fontSize )
		makeScoreLabel( true )
		addGameObject( playerDeckCard )
	}
	
	func makeScoreLabel( forPlayer : Bool )
	{
		let fontSize : CGFloat = 40
		let xPos = playerCards[ 0 ].sprite.position.x + ( fontSize * 2.0 )
		if ( forPlayer )
		{
			playerScoreLabel = addMakeLabel( "Score: \(model.player.myScore)" , xPos : xPos , yPos : playerCardPosY - fontSize, fontSize: fontSize, convertPoint: false )
			playerScoreLabel.fontColor = CardColor.colorCode( model.player.myColor )
		}
		else
		{
			opponentScoreLabel = addMakeLabel( "Score: \(model.opponent.myScore)" , xPos : xPos , yPos : opponentCards[0].sprite.position.y + (fontSize * 6), fontSize: fontSize, convertPoint: false )
			opponentScoreLabel.fontColor = CardColor.colorCode( model.opponent.myColor )
		}
	}
	
	private func addCardsToView( deckFrom : Deck, facingTop : Bool, yPos : CGFloat ) -> [CardObj]
	{
		var allCards = [CardObj]()
		
		for i in 0..<deckFrom.totalCards
		{
			if let card = deckFrom.peekAt( i )
			{
				let xPos = getCardPosition( i )
				let cardView = CardObj( card: card, xStart: xPos , yStart: yPos, showFace: facingTop )
				cardView.sprite.zPosition += CGFloat( i )
				if facingTop
				{
					cardView.placeInHand = i
				}
				allCards.append( cardView )
				addGameObject( cardView )
			}
		}
		
		return allCards
	}
	
	private func addDeckCard( totalCards : Int, yPos : CGFloat ) -> CardObj
	{
		let cardSize = CardObj( card: Card.getJoker() , xStart : 0, yStart: 0, showFace: true ).sprite.frame.width
		let xPos = getCardPosition( totalCards ) + ( cardSize * 0.4 )
		return CardObj( card: Card( suit: .Joker, rank: .Joker ), xStart: xPos , yStart: yPos, showFace: false )
	}
	
	private func getCardPosition( index: Int ) -> CGFloat
	{
		let leftMostX = UIScreen.mainScreen().bounds.width * 0.05
		let cardSize = CardObj( card: Card.getJoker() , xStart : 0, yStart: 0, showFace: true ).sprite.frame.width
		return ( CGFloat( index ) * ( cardSize * 0.25 ) ) + leftMostX
	}
	
	private func addOpponentCardsToView()
	{
		opponentCards = addCardsToView( model.opponent.myHand, facingTop : false, yPos : opponentCardPosY )
		opponentDeckCard = addDeckCard( model.player.myHand.totalCards, yPos: opponentCardPosY  )
		addGameObject( opponentDeckCard )
		makeScoreLabel( false )
	}
	
	private func animateBattle( playerWon : Bool? )
	{
		let padding : CGFloat = 200
		let totalSecs = 1.0
		let action : SKAction
		if let result = playerWon
		{
			let newPosY : CGFloat = ( result ? 0 : UIScreen.mainScreen().bounds.height + padding )
			action = SKAction.moveToY( newPosY, duration: totalSecs )
		}
		else
		{
			let newPosX = -padding
			action = SKAction.moveToX( newPosX , duration: totalSecs )
		}
		
		if middleCard != nil
		{
			let oldPos = middleCard.sprite.position
			middleCard.sprite.runAction( action, completion:
				{
					self.middleCard.changeToCard( self.model.middleCard )
					self.middleCard.sprite.alpha = 0.0
					self.middleCard.sprite.position = oldPos
					self.middleCard.sprite.runAction( SKAction.fadeAlphaTo( 1.0, duration: totalSecs ) )
					self.updateScoreLabels( playerWon )
					self.tutorialHandled?.handleBattleOver( self )
			})
		}
	}
	
	private func fadeScore( label : SKLabelNode, newScore : Int  )
	{
		let action = SKAction.fadeOutWithDuration( 0.5 )
		label.runAction( action,  completion:
			{
				label.text = "Score: \(newScore)"
				label.runAction( SKAction.fadeInWithDuration( 0.5 ) )
		})
	}
	
	private func updateScoreLabels( playerWon : Bool? )
	{
		if let result = playerWon
		{
			let score = ( result ? model.player.myScore : model.opponent.myScore )
			let label = ( result ? playerScoreLabel : opponentScoreLabel )
			fadeScore( label, newScore : score )
		}
		else
		{
			fadeScore( playerScoreLabel, newScore : model.player.myScore )
			fadeScore( opponentScoreLabel, newScore: model.opponent.myScore )
		}
	}
	
	private func playBattleSounds( result : Bool?, isJoker : Bool )
	{
		let sound : SFX
		if let isWon = result
		{
			if isJoker && isWon
			{
				sound = .WinJoker
			}
			else
			{
				sound = ( isWon ? .WinBattle : .LoseBattle )
			}
		}
		else
		{
			sound = .DrawBattle
		}
		
		playSoundEffect( sound )
	}
	
	func bothSidesChosen()
	{
		if playerChosenCard != nil && opponentChosenCard != nil
		{
			let isJoker = model.middleCard.isJoker
			let battleResult = model.battle( playerChosenCard!.myCard , opponentCard:  opponentChosenCard!.myCard )
			animateBattle( battleResult )
			playerChosenCard!.makeDead()
			opponentChosenCard!.makeDead()
			playerChosenCard = nil
			opponentChosenCard = nil
			shouldWait = false
			
			if model.isGameOver()
			{
				flipOpponentCards()
				model.calculateFinalScores()
				updateScoreLabels( nil )
				shouldWait = true
				if let state = model.gameWinState()
				{
					SaveHandler.clearModel()
					playGameOverSound( state )
					doneScreen = true
					if tutorialHandled == nil
					{
						showGameOver( state )
					}
				}
			}
			else
			{
				SaveHandler.writeModel( model, isTutorial: tutorialHandled != nil )
				playBattleSounds( battleResult, isJoker: isJoker )
			}
		}
	}
	
	private func showGameOver( state: WinState )
	{

		let fontSize : CGFloat = 50
		let otherSize : CGFloat = 40
		showBottomText( "You \(state.rawValue)", fontSize: fontSize )
		let tapLabel = addMakeLabel( "Tap to Continue" , xPos: CGRectGetMidX(self.frame), yPos: CGRectGetMidY(self.frame) - ( fontSize * 4 ),fontSize: otherSize, convertPoint: false )
		
		let fadeOut = SKAction.fadeOutWithDuration(1.0)
		let fadeIn = SKAction.fadeInWithDuration( 1.0 )
		let sequence = SKAction.sequence([fadeOut, fadeIn])
		let repeatForever = SKAction.repeatActionForever( sequence )
		tapLabel.runAction( repeatForever )
	}
	
	func showBottomText( text : String, fontSize: CGFloat ) -> SKLabelNode
	{
		return addMakeLabel(text , xPos: CGRectGetMidX(self.frame), yPos: CGRectGetMidY(self.frame) - ( fontSize * 3 ),fontSize: fontSize, convertPoint: false )
	}
	
	private func playGameOverSound( state : WinState )
	{
		let sound : SFX
		switch( state )
		{
		case .PlayerDraw:
			sound = .TieGame
		case .PlayerWon:
			sound = .WinGame
		case .PlayerLost:
			sound = .LoseGame
		}
		
		playSoundEffect( sound )
	}
	
	private func flipOpponentCards()
	{
		var index = -1
		for cardObj in opponentCards
		{
			index += 1
			cardObj.changeToCard( model.opponent.myHand.peekAt( index )! )
			cardObj.flipCard( true )
		}
	}
	
	/* Called when a touch begins */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
	{
		if doneScreen && tutorialHandled == nil
		{
			myController.changeState( .Menu )
			return
		}
		
		if shouldWait
		{
			return
		}
		
		super.touchesBegan( touches, withEvent: event )
    }
	
	func clickCard( chosen : Int )
	{
		if ( playerChosenCard != nil || shouldWait )
		{
			return
		}
		
		var index = -1
		for cardObj in playerCards
		{
			index += 1
			if index == chosen
			{
				cardObj.sprite.alpha = 0.8
				placeHolder.setSprite( "cardPlace2" )
			}
			else
			{
				cardObj.sprite.alpha = 1.0
			}
		}
	}
	
	func choosePlayerCard( chosen : CardObj )
	{
		self.placeHolder.setSprite( "cardPlace" )
		self.shouldWait = true
		chosen.sprite.runAction( SKAction.fadeOutWithDuration( 1.0 ), completion: {
			let card = chosen.myCard
			chosen.makeDead()
			self.playerChosenCard = CardObj( card: card, xStart: 0, yStart: 0, showFace: true )
			self.playerChosenCard!.sprite.position = self.placeHolder.sprite.position
			self.playerChosenCard!.shouldConvertPosition = false
			self.playerChosenCard!.sprite.alpha = 0.0
			self.playerChosenCard!.sprite.runAction( SKAction.fadeInWithDuration( 1.0 ) )
			self.playerChosenCard!.sprite.zPosition = chosen.sprite.zPosition
			self.model.player.myHand.removeAt( chosen.placeInHand )
			self.queueGameObject( self.playerChosenCard! )
			self.repositionCards()
			self.playSoundAfterDrawCard()
		})
	}
	
	func chooseOpponentCard( chosenIndex : Int )
	{
		if let chosenCard = model.opponent.myHand.removeAt( chosenIndex )
		{
			let card = chosenCard
			let chosen = opponentCards[ chosenIndex ]

			chosen.sprite.runAction( SKAction.fadeOutWithDuration( 1.0 ), completion: {
				self.opponentChosenCard = CardObj( card: card, xStart: 0, yStart: 0, showFace: true )
				self.opponentChosenCard!.sprite.position = self.placeHolder2.sprite.position
				self.opponentChosenCard!.shouldConvertPosition = false
				self.opponentChosenCard!.sprite.alpha = 0.0
				self.opponentChosenCard!.sprite.runAction( SKAction.fadeInWithDuration( 1.0 ) )
				self.opponentChosenCard!.sprite.zPosition = 20
				self.queueGameObject( self.opponentChosenCard! )
				chosen.makeDead()
				self.repositionCards( false )
			})
		}
		
	}
	
	func chooseCard()
	{
		var chosen : CardObj? = nil
		for cardObj in playerCards
		{
			if cardObj.sprite.alpha != 1.0
			{
				chosen = cardObj
			}
		}
		
		if chosen != nil
		{
			choosePlayerCard( chosen! )
			chooseOpponentCard( model.currentAI.chooseCard( model.opponent, middleCard: model.middleCard ) )
			NSTimer.scheduledTimerWithTimeInterval( 2.0 , target: self, selector: #selector(self.bothSidesChosen), userInfo: nil, repeats: false)
		}
		else
		{
			print( "Card not chosen" )
		}
		
	}
	
	func repositionCards( isPlayer : Bool = true )
	{
		if isPlayer
		{
			var newIndex = 0
			var newCards = [CardObj]()
			for cardObj in playerCards
			{
				if ( cardObj.isDead )
				{
					continue
				}
				else
				{
					newCards.append( cardObj )
					if cardObj.placeInHand != newIndex
					{
						cardObj.placeInHand = newIndex
						let point = convert( CGPoint( x: getCardPosition( newIndex ), y: 0 ) )
						let action = SKAction.moveToX( point.x, duration: 0.5 )
						cardObj.sprite.runAction( action )
						cardObj.sprite.zPosition -= 1
					}
					newIndex += 1
				}
			}
			
			if self.model.player.drawCard()
			{
				let newCard = CardObj( card: model.player.myHand.lastCard! , xStart: getCardPosition( newIndex ), yStart: playerCardPosY, showFace: true )
				newCard.placeInHand = newIndex
				newCard.sprite.zPosition += CGFloat( newIndex )
				newCard.withTouchObserver( TutorialCardTouchObserver( scene: self ) )
				newCards.append( newCard )
				newCard.sprite.alpha = 0
				let action = SKAction.fadeInWithDuration( 0.8 )
				newCard.sprite.runAction( action )
				queueGameObject( newCard )
				deckLabel.text = "\(model.player.myDeck.totalCards)"
			}
		
			if self.model.player.myDeck.empty() && deckLabel != nil
			{
				deckLabel.removeFromParent()
				deckLabel = nil
				playerDeckCard.makeDead()
				playerDeckCard = nil
			}
		
			if ( model.isGameOver() )
			{
				middleCard.flipCard( false )
			}
		
			playerCards = newCards
		}
		else
		{
			var newIndex = 0
			var newCards = [CardObj]()
			var curIndex = -1
			for cardObj in opponentCards
			{
				curIndex += 1
				if ( cardObj.isDead )
				{
					continue
				}
				else
				{
					newCards.append( cardObj )
					if curIndex != newIndex
					{
						let point = convert( CGPoint( x: getCardPosition( newIndex ), y: 0 ) )
						let action = SKAction.moveToX( point.x, duration: 0.5 )
						cardObj.sprite.runAction( action )
						cardObj.sprite.zPosition -= 1
					}
					newIndex += 1
				}
			}
			
			if self.model.opponent.drawCard()
			{
				let newCard = CardObj( card: model.opponent.myHand.lastCard! , xStart: getCardPosition( newIndex ), yStart: opponentCardPosY, showFace: false )
				newCard.sprite.zPosition += CGFloat( newIndex )
				newCards.append( newCard )
				newCard.sprite.alpha = 0
				let action = SKAction.fadeInWithDuration( 0.8 )
				newCard.sprite.runAction( action )
				queueGameObject( newCard )
			}
			
			if self.model.opponent.myDeck.empty() && opponentDeckCard != nil
			{
				opponentDeckCard.makeDead()
				opponentDeckCard = nil
			}
			
			opponentCards = newCards
		}
	}
	
	//called to play a sound effect when a card is drawn from the player's deck
	//if the new card is higher than the rest of the hand then HighCard sound effect is played
	private func playSoundAfterDrawCard()
	{
		let newCardIsBest = ( model.player.myHand.bestCardIndex == model.player.myHand.totalCards - 1 )
		playSoundEffect( ( newCardIsBest ? SFX.HighCard : SFX.NewCard ) )
	}
}

class PlaceHolderTouchObserver : TouchEventObserver
{
	let myScene : GameScene
	
	init( scene : GameScene )
	{
		myScene = scene
	}
	
	func notifyTouched(location: CGPoint, obj: GameObj)
	{
		myScene.chooseCard()
	}
}

class TutorialCardTouchObserver : TouchEventObserver
{
	let myScene : GameScene
	
	init( scene : GameScene )
	{
		myScene = scene
	}
	
	func notifyTouched(location: CGPoint, obj: GameObj)
	{
		myScene.tutorialHandled?.handleCardPress( myScene )
	}
}