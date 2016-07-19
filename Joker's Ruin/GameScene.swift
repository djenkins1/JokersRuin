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
//	finish shuffle deck function in Deck
//	distribute the cards between both players and dealer(middle)
//	show top(3-5) cards in hand for player
//	show back face of opponents hand
//	show back face draw deck for both players(should be to right of player, i.e upper left for opponent)
//	show top card of middle
//	show back face of middle deck
//	should probably show remaining cards in middle deck
//	keep track of score(need to calculate)
//	keep track of colors of both players
//	make sure all game logic is in the model( i.e cards view just reflects the model)
//	tapping on card should initiate comparison
//
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
	
	var deck : Deck!
	
	var card : CardObj!
	
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
		
		createBackground()
		
		deck = Deck()
		deck.appendCard( Card( suit : .Joker, rank: .Joker ) )
		deck.printDeck()
		
		card = CardObj( card: deck.getTopCard()!, xStart: CGRectGetMidX(self.frame), yStart: CGRectGetMidY(self.frame) )
		addGameObject( card )
		NSTimer.scheduledTimerWithTimeInterval( 1.0 , target: self, selector: #selector(self.changeToNextCard), userInfo: nil, repeats: true )
	}
	
	func changeToNextCard()
	{
		if let newCard = deck.getTopCard()
		{
			card.changeToCard( newCard )
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
		
		/*
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
		*/
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
	
	func addMakeLabel( message : String, xPos : CGFloat, yPos : CGFloat, fontSize : CGFloat ) -> SKLabelNode
	{
		let myFont = "Thonburi"//"Verdana"//"Thonburi"
		let otherLabel = SKLabelNode(fontNamed: myFont )
		otherLabel.text = message
		otherLabel.fontSize = fontSize
		otherLabel.position = CGPoint(x: xPos , y: yPos )
		otherLabel.zPosition = 100
		otherLabel.fontColor = UIColor.blackColor()
		self.addChild(otherLabel)
		return otherLabel
	}
	
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
	
	//adds the object to the queue for creation
	func queueGameObject( obj : GameObj ) -> GameObj
	{
		self.objCreateQueue.append( obj )
		return obj
	}
	
	//creates the background image for the scene
	func createBackground()
	{
		let sprite = SKSpriteNode( imageNamed: "newBackLandscape" )
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
