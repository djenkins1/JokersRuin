//
//  GameViewController.swift
//  Joker's Ruin
//
//  Created by Dilan Jenkins on 7/18/16.
//  Copyright (c) 2016 Dilan Jenkins. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
    override func viewDidLoad()
	{
        super.viewDidLoad()
		changeState( .Menu )
    }
	
	//changes the games state to the state provided and presents the associated scene
	func changeState( toState : GameState )
	{
		if let scene = sceneFromState( toState )
		{
			clearView()
			let transition = SKTransition.fadeWithDuration( 1.0)
			let skView = view as! SKView!
			
			skView.showsFPS = true
			skView.showsNodeCount = true
			
			/* Sprite Kit applies additional optimizations to improve rendering performance */
			skView.ignoresSiblingOrder = true
			
			/* Set the scale mode to scale to fit the window */
			scene.scaleMode = .Fill//.AspectFit
			scene.myController = self
			skView.presentScene( scene, transition: transition )
		}
		else
		{
			print( "Could not change state" )
		}
	}
	
	func sceneFromState( state : GameState ) -> MyScene?
	{
		let sizeBox = CGSize( width: 768, height: 1024 )
		switch( state )
		{
		case .Menu:
			return MenuScene( size: sizeBox )
		case .Play:
			return GameScene( size: sizeBox )
		case .Help:
			return nil
		case .Credits:
			return nil
		case .NewGame:
			return nil
		case .Continue:
			let scene = GameScene( size: sizeBox )
			if let savedModel = SaveHandler.readModel().first
			{
				if let model = GameModel(objDict: savedModel )
				{
					scene.model = model
					return scene
				}
				else
				{
					print( "Could not load model" )
				}
			}
			return nil
		}
	}

	func clearView()
	{
		if let view = view
		{
			for sub in view.subviews
			{
				sub.removeFromSuperview()
			}
		}
	}
	
    override func shouldAutorotate() -> Bool
	{
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
	{
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
		{
            return .AllButUpsideDown
        }
		else
		{
            return .All
        }
    }

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool
	{
        return true
    }
}

enum GameState : Int
{
	case Play
	case Credits
	case Help
	case NewGame
	case Menu
	case Continue
}