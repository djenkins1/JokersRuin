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

		let skView = view as! SKView!
		let scene = GameScene(size: CGSize( width: 768, height: 1024 ))

		skView.showsFPS = true
		skView.showsNodeCount = true
            
		/* Sprite Kit applies additional optimizations to improve rendering performance */
		skView.ignoresSiblingOrder = true
            
		/* Set the scale mode to scale to fit the window */
		scene.scaleMode = .Fill//.AspectFit
            
		skView.presentScene(scene)
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
