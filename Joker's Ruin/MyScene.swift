//
//  MyScene.swift
//  Joker's Ruin
//
//  Created by Dilan Jenkins on 7/30/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//

import Foundation
import SpriteKit

//holds various commonalities between the scenes
class MyScene : SKScene
{
	var myController : GameViewController!
	
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
}