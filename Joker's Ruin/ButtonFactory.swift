//
//  ButtonFactory.swift
//  Viridia
//
//  Created by Dilan Jenkins on 7/11/16.
//  Copyright © 2016 Dilan Jenkins. All rights reserved.
//

import Foundation
import SpriteKit

class ButtonFactory
{
	static let defaultWidth : CGFloat = 128
	
	static let defaultHeight : CGFloat = 32
	
	static func createButton( buttonTitle : String, buttonType : ButtonType , xCenter : CGFloat, yCenter : CGFloat ) -> UIButton
	{
		switch( buttonType )
		{
		case .TitleButton:
			let screenWidth = UIScreen.mainScreen().bounds.width
			let titleWidth = ceil(screenWidth * 0.5)
			return createButton( buttonTitle, buttonType : buttonType, xPos : xCenter - ( titleWidth / 2 ), yPos : yCenter - ( defaultHeight / 2) )
		case .MenuButton:
			return createButton( buttonTitle, buttonType : buttonType, xPos : xCenter - ( defaultWidth / 2 ), yPos : yCenter - ( defaultHeight / 2) )
		case .SmallButton:
			return createButton( buttonTitle, buttonType : buttonType, xPos : xCenter - ( defaultHeight / 2 ), yPos : yCenter - ( defaultHeight / 2) )
		}
	}
	
	static func createButton( buttonTitle : String, buttonType : ButtonType , xCenter : CGFloat, yPos : CGFloat ) -> UIButton
	{
		switch( buttonType )
		{
		case .TitleButton:
			let screenWidth = UIScreen.mainScreen().bounds.width
			let titleWidth = ceil(screenWidth * 0.5)
			return createButton( buttonTitle, buttonType : buttonType, xPos : xCenter - ( titleWidth / 2 ), yPos : yPos )
		case .MenuButton:
			return createButton( buttonTitle, buttonType : buttonType, xPos : xCenter - ( defaultWidth / 2 ), yPos : yPos )
		case .SmallButton:
			return createButton( buttonTitle, buttonType : buttonType, xPos : xCenter - ( defaultHeight / 2 ), yPos : yPos )
		}
	}

	static func createButton( buttonTitle : String, buttonType : ButtonType, xPos : CGFloat, yPos : CGFloat ) -> UIButton
	{
		let button = UIButton(type: UIButtonType.Custom) as UIButton
		let backImage = UIImage( named: buttonType.rawValue ) as UIImage?
		
		switch( buttonType )
		{
		case .TitleButton:
			let screenWidth = UIScreen.mainScreen().bounds.width
			let titleWidth = ceil(screenWidth * 0.5)
			button.frame = CGRectMake( xPos, yPos , titleWidth, defaultHeight )
			button.setBackgroundImage( backImage, forState: .Normal )
			button.userInteractionEnabled = false
		case .MenuButton:
			button.frame = CGRectMake( xPos, yPos, defaultWidth, defaultHeight )
			button.setBackgroundImage( backImage, forState: .Normal )
		case .SmallButton:
			button.frame = CGRectMake( xPos, yPos,  defaultHeight, defaultHeight )
			button.setBackgroundImage( backImage, forState: .Normal )
		}
		
		button.setTitleColor( UIColor.blackColor(), forState: .Normal)
		button.setTitle( buttonTitle, forState: .Normal )
		button.layer.zPosition = 100
		setupDefaultFont( button )
		return button
	}
	
	static func createCenteredButton( buttonTitle : String, buttonType: ButtonType, yCenter : CGFloat ) -> UIButton
	{
		let screenWidth = UIScreen.mainScreen().bounds.width
		return createButton( buttonTitle, buttonType: buttonType, xCenter : screenWidth / 2, yCenter : yCenter )
	}
	
	static func createCenteredButton( buttonTitle : String, buttonType : ButtonType, xOffset : CGFloat, yCenter : CGFloat ) -> UIButton
	{
		let screenWidth = UIScreen.mainScreen().bounds.width
		return createButton( buttonTitle, buttonType: buttonType, xCenter : ( screenWidth / 2 ) - xOffset, yCenter : yCenter )
	}
	
	static func createCenteredButton( buttonTitle : String, buttonType : ButtonType, yPos : CGFloat ) -> UIButton
	{
		let screenWidth = UIScreen.mainScreen().bounds.width
		return createButton( buttonTitle, buttonType: buttonType, xCenter : screenWidth / 2, yPos : yPos )
	}
	
	static func setupDefaultFont( button : UIButton )
	{
		button.titleLabel!.font = UIFont( name: "Thonburi", size: button.titleLabel!.font!.pointSize )
	}
	
	static func disableButton( button : UIButton )
	{
		button.userInteractionEnabled = false
		let image = UIImage( named: "btnGreyDef" ) as UIImage?
		button.setBackgroundImage( image, forState: .Normal )
		button.setTitleColor( UIColor.grayColor(), forState: .Normal)
	}
	
	static func boxSizeFromType( type : ButtonType ) -> CGRect
	{
		switch( type )
		{
		case .TitleButton:
			let screenWidth = UIScreen.mainScreen().bounds.width
			let titleWidth = ceil(screenWidth * 0.5)
			return CGRect( x: 0, y: 0, width: titleWidth, height: defaultHeight )
		case .MenuButton:
			return CGRect( x: 0, y: 0, width: defaultWidth, height: defaultHeight )
		case .SmallButton:
			return CGRect( x: 0, y: 0, width: defaultHeight, height: defaultHeight )
		}
	}
	
	static func makeButtonDifferent( button: UIButton, revertToSame : Bool = false )
	{
		if revertToSame
		{
			let backImage = UIImage( named: ButtonType.MenuButton.rawValue ) as UIImage?
			button.setBackgroundImage( backImage, forState:  .Normal )
			button.setTitleColor( UIColor.blackColor(), forState: .Normal )
		}
		else
		{
			let backImage = UIImage( named: "btnGreenPrs" ) as UIImage?
			button.setBackgroundImage( backImage, forState:  .Normal )
			button.setTitleColor( UIColor.whiteColor(), forState: .Normal )
		}
	}
	
	static func createCustomButton( backImage : String, title: String, width: CGFloat, height: CGFloat, xPos: CGFloat, yPos: CGFloat ) -> UIButton
	{
		let button = UIButton(type: UIButtonType.Custom) as UIButton
		let backImage = UIImage( named: backImage ) as UIImage?
		button.frame = CGRectMake( xPos, yPos, width, height )
		button.setBackgroundImage( backImage, forState: .Normal )
		button.setTitleColor( UIColor.blackColor(), forState: .Normal)
		button.setTitle( title, forState: .Normal )
		button.layer.zPosition = 100
		setupDefaultFont( button )
		return button
	}
}

enum ButtonType : String
{
	case TitleButton = "btnGreenTitle"
	
	case MenuButton = "btnGreenDef"
	
	case SmallButton = "btnGreenSmall"
}