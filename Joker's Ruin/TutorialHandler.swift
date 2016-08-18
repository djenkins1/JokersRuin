//
//  TutorialHandler.swift
//  Joker's Ruin
//
//  Created by Dilan Jenkins on 8/17/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//

import Foundation
import SpriteKit

//TODO:	NEED TO PUT JOKER AS SECOND CARD IN MIDDLE DECK
//		also make paused when in box until not in box
//		also need to actually show box/inBox text
//		should the savehandler be used on the tutorial?
//	Tutorial:
//		(text shown as win text is shown)
//		tap on a card(tapping on card in hand triggers next text to be shown)
//		tap on the white outline
//		(TEXT NOT SHOWN)the opponent does the same
//	(AFTER BATTLE)(BIGBOX=BlankCard)
//		the higher card of the two sides wins
//		the point value of the middle card is added to the score
//		if the middle card matches your color you get bonus points for winning it
//		your score shows up in your color at the bottom of the screen
//	(BACK TO GAME)
//		choose a card(Joker in middle)
//	(AFTER BATTLE)(BIGBOX=BlankCard)
//		Winning the joker card will cut your points in half
//		So you should play your lowest card when the joker is in the middle
//	(BACK TO GAME)
//		choose a card(keeps showing until game over)
//	(AFTER BATTLE)(BIGBOX=BlankCard)
//		the game ends when there are 4 cards remaining in your hand
//		the point values of the 4 cards are added to your score
//		you gain bonus points for cards with your color
//		whoever has the most points at the end wins the game
//	(BACK TO MENU)

class TutorialHandler
{
	var currentIndex = 0
	
	var currentRepeats = 0
	
	let allStages = TutorialStage.allStages()
	
	var textLabel : SKLabelNode?
	
	//called when the scene is ready for the tutorial text to display
	func firstScene( scene : GameScene )
	{
		showText( scene )
	}
	
	func handleBattleOver( scene : GameScene )
	{
		//goto the next stage
		nextStage( scene )
	}
	
	func handleGameOver( scene : GameScene )
	{
		//go to the next stage
		nextStage( scene )
	}
	
	func handleCardPress( scene : GameScene )
	{
		//if the current stage is the first stage(at index 0) then go to next stage
		//otherwise ignore
		if currentIndex == 0
		{
			nextStage( scene )
		}
	}
	
	func handleTap( scene : GameScene )
	{
		//if the current stage is a box stage, advance to the next stage
		//otherwise ignore the tap
		if allStages[ currentIndex ].inBox
		{
			print( allStages[ currentIndex ].stageText )
			nextStage( scene )
		}
	}
	
	//advance to the next stage and handle changes to the view
	func nextStage( scene : GameScene )
	{
		if currentIndex + 1 >= allStages.count
		{
			scene.myController.changeState( .Menu )
			return
		}
		
		let currentStage = allStages[ currentIndex ]
		
		//if the current stage has been repeated enough, continue to next stage
		//otherwise, add to total repeats done and continue with current stage
		if currentStage.doRepeats == currentRepeats
		{
			currentRepeats = 0
			currentIndex += 1
			showText( scene )
		}
		else
		{
			currentRepeats += 1
			showText( scene )
		}
	}
	
	private func showText( scene : GameScene )
	{
		let currentStage = allStages[ currentIndex ]
		if currentStage.inBox
		{
			//if the stage has inBox = true then draw a box if it is not already drawn and remove any text if there was any
			textLabel?.removeFromParent()
		}
		else
		{
			//otherwise if the inBox = false then remove the box if it was there AND remove any text
			textLabel?.removeFromParent()
			textLabel = scene.showBottomText( currentStage.stageText, fontSize: 40 )
		}
	}
}

class TutorialStage
{
	let stageText : String
	
	let inBox : Bool
	
	private(set) var doRepeats : Int
	
	init( text : String, inBox : Bool = false )
	{
		self.stageText = text
		self.inBox = inBox
		doRepeats = 0
	}
	
	 convenience init( text : String, doRepeats : Int )
	{
		self.init( text: text )
		self.doRepeats = doRepeats
	}
	
	static func allStages() -> [TutorialStage]
	{
		let cardsDrawn = 3
		return [
			TutorialStage( text: "Tap on a card" ),
			TutorialStage( text: "Tap on the white outline" ),
			BoxStage( text: "The higher card of the two sides wins"  ),
			BoxStage( text: "The point value of the middle card is added to the winner's score" ),
			BoxStage( text: "If the middle card matches your color you get bonus points for winning it"  ),
			BoxStage( text: "Your score shows up in your color at the bottom of the screen"  ),
			TutorialStage( text: "Choose a card" ),
			BoxStage( text: "Winning the joker card will cut your points in half"  ),
			BoxStage( text: "You should play your lowest card when the joker is in the middle" ),
			TutorialStage( text: "Choose a card", doRepeats: GameModel().player.myDeck.totalCards - ( cardsDrawn - 1 ) ),
			BoxStage( text: "The game ends when there are 4 cards remaining in your hand"  ),
			BoxStage( text: "The point values of the 4 cards are added to your score"  ),
			BoxStage( text: "You gain bonus points for cards left in your hand with your color"),
			BoxStage( text: "Whoever has the most points at the end wins the game"  )
		]
	}
}

class BoxStage : TutorialStage
{
	init( text: String )
	{
		super.init( text: text, inBox: true )
	}
}
