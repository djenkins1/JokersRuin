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
//	shuffle deck should be a bit more random
//	should prevent the joker from ending up on the top of middle deck, in that case place it at a new index in the middle deck
//
//	should have win battle/lose battle/draw battle animations(i.e indicate which player won the battle)
//	need to make game over text easier to read somehow
//		maybe place it lower in the between the middle and the players cards
//	should also have some animation for winning/losing game
//	Teleport/Movement Animations for opponents hand cards and choosing
//		along side should remove opponent deck card as well when opponent has no more cards in deck
//	maybe for more strategy allow player/opponentAI to use card on top of deck as choice(player cannot see what it is)
//		deck card would have indexInHand equal to totalCards in hand
//	special animation for who wins the joker
//
//	(SPRITE)should recolor the joker to be green so as to not be ambiguos for bonus points
//	Music
//	Sound Effects
//	App Icon
//
//	Menu with buttons for a new game, continue, help, credits
//		newGame will go to screen with options, i.e Computer/Human opponent, AI level if computer opponent
//		help screen will explain the rules, and maybe have a practice game tutorial
//	Continue Game support(only for single player against AI):
//		should remove the save once the current game is over
//		should save the games state after every turn
//			will only need to save the model
//		(DONE WITH SERIALIZING, just need contents from File and TextFormatter glue)have to be able to load in everything
//			hands(serializableDone in Deck object)
//			decks(serializableDone in Deck object)
//			middleCard/middleDeck(serializableDone in Card/Deck)
//			scores(easily serializable on account of being an int)
//			colors(can just use rawValue)
//	Multiplayer game support using Game Center
//	see cards.txt for other things todo
*/
import SpriteKit
import AVFoundation

class GameScene: SKScene
{
	//list of game objects currently in the scene
	var gameObjects = [GameObj]()
	
	//the last time that the frames were drawn, i.e update method was called
	var lastTime : CFTimeInterval = 0
	
	//the last value for the FPS in update
	private(set) var lastFPS : Int = 0
	
	//whether the update function is paused or not
	var pauseUpdate = false
	
	//whether the current game level is won/lost or is still being played
	var doneScreen = false
	
	//a list of objects that are queued to be added to the gameObjects array
	var objCreateQueue = [GameObj]()
	
	var myController : GameViewController!
	
	//a list of object class names, and how many instances of said class have been created
	var objectsCreated = [ String : Int ]()
	
	//a list of object class names, and how many instances of said class have been destroyed
	var objectsDestroyed = [ String : Int ]()
	
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
	
	let currentAI = EasyAI()
	
	var shouldWait = false
	
	var deckLabel : SKLabelNode!
	
	var playerScoreLabel : SKLabelNode!
	
	var opponentScoreLabel : SKLabelNode!
	
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
		middleCard = CardObj( card : model.middleCard , xStart: getCardPosition( model.player.myHand.totalCards - 3 ), yStart: middleCardY , isFlipped: true )
		placeHolder2 = GameObj( spriteName: "cardPlace" , xStart: getCardPosition( model.player.myHand.totalCards - 1 ), yStart: middleCardY )
		placeHolder = GameObj( spriteName: "cardPlace" , xStart: getCardPosition( model.player.myHand.totalCards - 5 ), yStart: middleCardY )
		placeHolder.withTouchObserver( PlaceHolderTouchObserver( scene: self ) )
		addGameObject( middleCard )
		addGameObject( placeHolder2 )
		addGameObject( placeHolder )
		addGameObject( addDeckCard( model.player.myHand.totalCards, yPos : middleCardY ) )
		addPlayerCardsToView()
		addOpponentCardsToView()
	}
	
	private func addPlayerCardsToView()
	{
		playerCards = addCardsToView( model.player.myHand, facingTop : true, yPos : playerCardPosY )
		playerDeckCard = addDeckCard( model.player.myHand.totalCards, yPos: playerCardPosY  )
		//func addMakeLabel( message : String, xPos : CGFloat, yPos : CGFloat, fontSize : CGFloat, convertPoint : Bool = true ) -> SKLabelNode
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
				let cardView = CardObj( card: card, xStart: xPos , yStart: yPos, isFlipped: facingTop )
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
		let cardSize = CardObj( card: Card.getJoker() , xStart : 0, yStart: 0, isFlipped: true ).sprite.frame.width
		let xPos = getCardPosition( totalCards ) + ( cardSize * 0.4 )
		return CardObj( card: Card( suit: .Joker, rank: .Joker ), xStart: xPos , yStart: yPos, isFlipped: false )
	}
	
	private func getCardPosition( index: Int ) -> CGFloat
	{
		let leftMostX = UIScreen.mainScreen().bounds.width * 0.05
		let cardSize = CardObj( card: Card.getJoker() , xStart : 0, yStart: 0, isFlipped: true ).sprite.frame.width
		return ( CGFloat( index ) * ( cardSize * 0.25 ) ) + leftMostX
	}
	
	func convert( point: CGPoint ) -> CGPoint
	{
		return self.view!.convertPoint(CGPoint(x: point.x, y: self.view!.frame.height - point.y), toScene:self)
	}
	
	private func addOpponentCardsToView()
	{
		opponentCards = addCardsToView( model.opponent.myHand, facingTop : false, yPos : opponentCardPosY )
		opponentDeckCard = addDeckCard( model.player.myHand.totalCards, yPos: opponentCardPosY  )
		addGameObject( opponentDeckCard )
		makeScoreLabel( false )
	}
	
	private func updateScoreLabels()
	{
		playerScoreLabel.text = "Score: \(model.player.myScore)"
		opponentScoreLabel.text = "Score: \(model.opponent.myScore)"
	}
	
	func bothSidesChosen()
	{
		if playerChosenCard != nil && opponentChosenCard != nil
		{
			model.battle( playerChosenCard!.myCard , opponentCard:  opponentChosenCard!.myCard )
			updateScoreLabels()
			playerChosenCard!.makeDead()
			opponentChosenCard!.makeDead()
			middleCard.changeToCard( model.middleCard )
			playerChosenCard = nil
			opponentChosenCard = nil
			shouldWait = false
			
			if model.isGameOver()
			{
				model.calculateFinalScores()
				updateScoreLabels()
				shouldWait = true
				if let state = model.gameWinState()
				{
					//CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
					let fontSize : CGFloat = 50
					let otherSize : CGFloat = 40
					addMakeLabel( "You \(state.rawValue)", xPos: CGRectGetMidX(self.frame), yPos: CGRectGetMidY(self.frame),fontSize: fontSize, convertPoint: false )
					addMakeLabel( "Tap to Continue" , xPos: CGRectGetMidX(self.frame), yPos: CGRectGetMidY(self.frame) - fontSize,fontSize: otherSize, convertPoint: false )
				}
			}
		}
	}
	
	/* Called before each frame is rendered */
	override func update(currentTime: CFTimeInterval)
	{
		//get the difference in time from last time
		let deltaTime = currentTime - lastTime
		let currentFPS = Int( floor( 1 / deltaTime ) )
		lastTime = currentTime
	
		if ( pauseUpdate )
		{
			return
		}
		
		var newList = [GameObj]()
		for obj in gameObjects
		{
			if ( obj.isDead )
			{
				removeGameObject( obj )
				continue
			}
			
			obj.updateEvent( self, currentFPS: currentFPS )
			newList.append( obj )
		}

		gameObjects.removeAll()
		gameObjects = newList
		
		for obj in objCreateQueue
		{
			addGameObject( obj )
			objCreateQueue.removeFirst()
		}

		lastFPS = currentFPS
		lastTime = currentTime
	}
	
	/* Called when a touch begins */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
	{
        /*
        for touch in touches
		{
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
		*/
		
		
		for touch in touches
		{
			let location = touch.locationInNode(self)
			for obj in gameObjects
			{
				if obj.sprite.frame.contains( location )
				{
					obj.touchEvent( location )
				}
			}
		}
    }
	
	/*
	/* called when a touch moves */
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
	{
		for touch in touches
		{
			if ( objectTouched == nil )
			{
				break
			}
			
			if ( objectTouched.isDead )
			{
				objectTouched = nil
				break
			}
			
			let location = touch.locationInNode(self)
			objectTouched.dragEvent( location )
		}
	}
	*/
	
	/*
	/* Called when a touch ends, i.e user lifts finger */
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
	{
		for touch in touches
		{
			if ( objectTouched == nil )
			{
				break
			}
			
			if ( objectTouched.isDead )
			{
				objectTouched = nil
				break
			}
			
			let location = touch.locationInNode(self)
			objectTouched.stopDragEvent( location )
			objectTouched = nil
		}
	}
	*/
	
	/*
	func pauseAndShowMessage( message : String, subMessage : String = "" ) -> [SKLabelNode]
	{
		var toReturn = [SKLabelNode]()
		if ( pauseUpdate )
		{
			return toReturn
		}
		
		pauseUpdate = true
		var myLabel = addMakeLabel( message, xPos : CGRectGetMidX(self.frame), yPos : CGRectGetMidY(self.frame), fontSize: 45 )
		toReturn.append( myLabel )
		if ( subMessage != "" )
		{
			myLabel = addMakeLabel( subMessage, xPos : CGRectGetMidX(self.frame), yPos : CGRectGetMidY(self.frame) - myLabel.fontSize, fontSize: 30 )
			toReturn.append( myLabel )
		}
		myLabel = addMakeLabel( "Tap to Continue", xPos : CGRectGetMidX(self.frame), yPos : myLabel.position.y - myLabel.fontSize, fontSize: 30 )
		toReturn.append( myLabel )
		
		return toReturn
	}
	
	*/
	
	func addMakeLabel( message : String, xPos : CGFloat, yPos : CGFloat, fontSize : CGFloat, convertPoint : Bool = true ) -> SKLabelNode
	{
		let myFont = "Thonburi"//"Verdana"//"Thonburi"
		let otherLabel = SKLabelNode(fontNamed: myFont )
		otherLabel.text = message
		otherLabel.fontSize = fontSize
		let prePoint = CGPoint(x: xPos , y: yPos )
		otherLabel.position = ( convertPoint ? convert( prePoint ) : prePoint )
		otherLabel.zPosition = 100
		otherLabel.fontColor = UIColor.blackColor()
		self.addChild(otherLabel)
		return otherLabel
	}
	
	/*
	func addMakeSprite( spriteName : String, xPos : CGFloat, yPos : CGFloat ) -> SKSpriteNode
	{
		let sprite = SKSpriteNode( imageNamed: spriteName )
		sprite.position = CGPoint( x: xPos, y: yPos )
		sprite.anchorPoint = CGPoint( x: 0.0, y: 0.0 )
		sprite.zPosition = 100
		self.addChild( sprite )
		return sprite
	}
	*/
	
	func playSoundEffect( fileName : String )
	{
		/*
		if ( myController != nil && myController.isMuted )
		{
			return
		}
		runAction(SKAction.playSoundFileNamed( fileName , waitForCompletion: false))
		*/
	}
	
	//removes the game object from the list of game objects and from the scene
	final func removeGameObject( obj : GameObj )
	{
		let objClass = obj.className()
		if ( objectsDestroyed[ objClass ] != nil )
		{
			objectsDestroyed[  objClass ]! += 1
		}
		else
		{
			objectsDestroyed[ objClass ] = 1
		}
		
		obj.deleteEvent( self )
		self.removeChildrenInArray( [ obj.sprite ])
	}
	
	//adds the object and its sprite to the game view data, returns obj for chaining
	final func addGameObject( obj : GameObj ) -> GameObj
	{
		let objClass = obj.className()
		if ( objectsCreated[ objClass ] != nil )
		{
			objectsCreated[  objClass ]! += 1
		}
		else
		{
			objectsCreated[ objClass ] = 1
		}
		
		self.gameObjects.append( obj.createEvent( self ) )
		self.addChild( obj.sprite )
		return obj
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
			self.playerChosenCard = CardObj( card: card, xStart: 0, yStart: 0, isFlipped: true )
			self.playerChosenCard!.sprite.position = self.placeHolder.sprite.position
			self.playerChosenCard!.shouldConvertPosition = false
			self.playerChosenCard!.sprite.alpha = 0.0
			self.playerChosenCard!.sprite.runAction( SKAction.fadeInWithDuration( 1.0 ) )
			self.playerChosenCard!.sprite.zPosition = chosen.sprite.zPosition
			self.model.player.myHand.removeAt( chosen.placeInHand )
			self.queueGameObject( self.playerChosenCard! )
			self.repositionCards()
		})
	}
	
	func chooseOpponentCard( chosenIndex : Int )
	{
		if let chosenCard = model.opponent.myHand.removeAt( chosenIndex )
		{
			let card = chosenCard
			self.opponentChosenCard = CardObj( card: card, xStart: 0, yStart: 0, isFlipped: true )
			self.opponentChosenCard!.sprite.position = self.placeHolder2.sprite.position
			self.opponentChosenCard!.shouldConvertPosition = false
			self.opponentChosenCard!.sprite.alpha = 0.0
			self.opponentChosenCard!.sprite.runAction( SKAction.fadeInWithDuration( 1.0 ) )
			self.opponentChosenCard!.sprite.zPosition = 20
			self.queueGameObject( opponentChosenCard! )
			if !model.opponent.drawCard()
			{
				let cardToRemove = opponentCards.removeLast()
				cardToRemove.makeDead()
			}
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
			chooseOpponentCard( currentAI.chooseCard( model.opponent, middleCard: model.middleCard ) )
			NSTimer.scheduledTimerWithTimeInterval( 2.0 , target: self, selector: #selector(self.bothSidesChosen), userInfo: nil, repeats: false)
		}
		else
		{
			print( "Card not chosen" )
		}
		
	}
	
	func repositionCards()
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
			let newCard = CardObj( card: model.player.myHand.lastCard! , xStart: getCardPosition( newIndex ), yStart: playerCardPosY, isFlipped: true )
			newCard.placeInHand = newIndex
			newCard.sprite.zPosition += CGFloat( newIndex )
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
	
	//adds the object to the queue for creation
	func queueGameObject( obj : GameObj ) -> GameObj
	{
		self.objCreateQueue.append( obj )
		return obj
	}
	
	//creates the background image for the scene
	func createBackground()
	{
		let sprite = SKSpriteNode( imageNamed: "newBackPortrait" )
        sprite.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
		sprite.size.height = frame.height
		sprite.size.width = frame.width
		sprite.zPosition = 1
		self.addChild( sprite )
	}
	
	func pairIsInArray( array : Array<(Int,Int)> , indexOne: Int, indexTwo: Int ) -> Bool
	{
		for element in array
		{
			if ( element.0 == indexOne && element.1 == indexTwo )
			{
				return true
			}
			
			if ( element.0 == indexTwo && element.1 == indexOne )
			{
				return true
			}
		}
		
		return false
	}
	
	//returns all GameObj instances currently in the scene of the type provided
	//does not return any objects of a subclass
	func allObjectsOfType( ofType : GameObj.Type ) -> Array<GameObj>
	{
		var toReturn = [GameObj]()
		for obj in gameObjects
		{
			if object_getClass( obj ) == ofType
			{
				toReturn.append( obj )
			}
		}
		
		return toReturn
	}
	
	//returns the hypotenuse distance between the two points provided
	static func distanceBetween( x : CGFloat, y: CGFloat, otherX : CGFloat, otherY: CGFloat ) -> Float
	{
		return hypotf(Float( x - otherX), Float( y - otherY ) )
	}
	
	func addButton( button : UIButton ) -> UIButton
	{
		if ( view != nil )
		{
			self.view!.addSubview( button )
		}
		else
		{
			print( "Could not add button" )
		}
		
		return button
	}
	
	static func gcd( a : Int, _ b : Int ) -> Int
	{
		if b == 0
		{
			return a
		}
		return gcd( b, a % b )
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

