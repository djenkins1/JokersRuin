//
//  GameViewController.swift
//  Joker's Ruin
//
//  Created by Dilan Jenkins on 7/18/16.
//  Copyright (c) 2016 Dilan Jenkins. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController
{
	private(set) var isMuted = false
	
	private var musicPlayer: AVPlayer!
	
	private var playMusicList = [Music]()
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		isMuted = SettingsHandler.getHandler().getMuteStatus()
		
		setupMusic()
		if ( !isMuted )
		{
			playMusic()
		}
		
		changeState( .Menu )
    }
	
	private func setMuted( muteState : Bool ) -> Bool
	{
		isMuted = muteState
		SettingsHandler.getHandler().updateMuteStatus( isMuted )
		
		if ( isMuted )
		{
			musicPlayer.pause()
		}
		else
		{
			musicPlayer.play()
		}
		
		return isMuted
	}
	
	func toggleMute() -> Bool
	{
		return setMuted( !isMuted )
	}
	
	func muteSpriteFromStatus() -> String
	{
		return ( isMuted ? "musicOff" : "musicOn" )
	}
	
	//changes the games state to the state provided and presents the associated scene
	func changeState( toState : GameState )
	{
		if let scene = sceneFromState( toState )
		{
			changeScene( scene )
		}
		else
		{
			print( "Could not change state" )
		}
	}
	
	func newGameFromModel( model : GameModel )
	{
		let scene = sceneFromState( .Play )
		( scene as! GameScene ).model = model
		changeScene( scene! )
	}
	
	private func changeScene( scene : MyScene )
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
			let scene = GameScene( size: sizeBox )
			scene.tutorialHandled = TutorialHandler()
			return scene
		case .Credits:
			return CreditsScene( size: sizeBox )
		case .NewGame:
			return NewGameScene( size: sizeBox )
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
	
	//plays the background music in a loop
	func playMusic()
	{
		musicPlayer.play()
	}
	
	func setupMusic()
	{
		playMusicList = Music.randomMusicList()
		musicPlayer = AVPlayer( playerItem: playMusicList[ 0 ].getItem() )
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.playerDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: musicPlayer.currentItem )
	}
	
	func setupNextSong()
	{
		playMusicList.append( playMusicList.removeAtIndex( 0 ) )
		musicPlayer = AVPlayer( playerItem: playMusicList[ 0 ].getItem() )
		musicPlayer.play()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.playerDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: musicPlayer.currentItem )
	}
	
	//called when the player finishes a song
	func playerDidFinishPlaying(note: NSNotification)
	{
		if ( isMuted )
		{
			return
		}
		
		NSNotificationCenter.defaultCenter().removeObserver( note.object! )
		NSTimer.scheduledTimerWithTimeInterval(2.0 , target: self, selector: #selector(self.setupNextSong), userInfo: nil, repeats: false)
		
		
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