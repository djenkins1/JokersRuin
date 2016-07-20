//
//  GameObj.swift
//  Viridia
//
//  Created by Dilan Jenkins on 6/17/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//

import Foundation
import SpriteKit

class GameObj
{
	//an identifier representing this object
	var id : Int!
	
	//the sprite that is drawn by this object
	var sprite : SKSpriteNode
	
	//this is set to true when the object should no longer function and be deleted
	var isDead = false
	
	var myScene : GameScene!
	
	let startHeight : CGFloat
	
	let startWidth : CGFloat
	
	init( spriteName : String, xStart : CGFloat, yStart : CGFloat )
	{
		sprite = SKSpriteNode( imageNamed: spriteName )
		sprite.position = CGPoint( x: xStart, y: yStart )
		sprite.anchorPoint = CGPoint( x: 0.0, y: 0.0 )
		sprite.zPosition = 10
		startHeight = sprite.frame.height
		startWidth = sprite.frame.width
		
		//this should take transparency into account for collisions?
		//	also needs to rewrite collision, see bookmarks for bombz
		//sprite.physicsBody = SKPhysicsBody( texture: sprite.texture! , size: sprite.texture!.size() )
	}
	
	//called when the object is being added to the scene, should return itself
	func createEvent( scene : GameScene ) -> GameObj
	{
		myScene = scene
		sprite.position = myScene.convert( sprite.position )
		return self
	}
	
	//called when the object is being removed from the scene, should return itself
	func deleteEvent( scene : GameScene ) -> GameObj
	{
		makeDead()
		return self
	}
	
	//simply makes the object dead
	//to actually call code when the object is removed from the scene see deleteEvent(:_)
	final func makeDead()
	{
		if ( isDead )
		{
			return
		}
		self.isDead = true
	}
	
	//moves the objects sprite instantly to the coordinates provided
	func jumpTo( x: CGFloat, y: CGFloat )
	{
		self.sprite.position.x = x
		self.sprite.position.y = y
	}
	
	
	//fires when the object is touched
	func touchEvent( location : CGPoint )
	{
		
	}
	
	//fires when the object is no longer being touched
	func stopDragEvent( location: CGPoint )
	{
		
	}
	
	//fires when the object is being dragged by touch
	func dragEvent( location: CGPoint )
	{
		
	}
	
	func setSprite( spriteName : String )
	{
		sprite.texture = SKTexture(imageNamed: spriteName )
	}
	
	//fires when the update function is called in the GameScene
	func updateEvent( scene : GameScene, currentFPS : Int )
	{

	}
	
	func withID( id : Int ) -> GameObj
	{
		self.id = id
		return self
	}
	
	func className() -> String
	{
		return NSStringFromClass(self.dynamicType)
	}
	
}