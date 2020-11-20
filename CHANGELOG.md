# Fitness-App Changelog

Note: The most recent versions of the app will also be at the top of ViewController.swift as comments

Project created 2/28/2020 -- Changelog begin:

PRE-RELEASES--

	version		 date							changes
	-------		--------			----------------------------------
	0.1.0		11/15/20			Changes in this version:
										-First working version of Fitness

	0.2.0		11/17/20			Changes in this version:
										-The screen can now be swiped to change the day that data is displayed for
										-Rendering issues with the date stamp were fixed
										-All three rings will update correctly when the screen is tapped
										-Issues with tapping and swiping at the same time were fixed
										-App icon updated to support all versions of iOS 7-14 on all devices

	0.2.1		11/18/20			Changes in this version:
										-Single taps to update rings will only be detected when tapping on the rings

	0.2.2		11/18/20			Changes in this version:
										-Minor documentation changes
										-Semi-functional sliders to change goals

	0.3.0		11/18/20			Changes in this version:
										-The goals can now be changed by tapping on anywhere on the three rows of text at the bottom
											-Slider will show up that can be dragged to change goals
											-When the rings are tapped, the new goals will be used
											-Goals are saved even when closing the app
											

FULL-RELEASES--

	version		date							changes
	-------		--------			----------------------------------
	1.0.0		11/18/20			First working full release of Fitness
	
	1.0.1		11/19/20			Changes in this version:
										-Minor documentation changes
										-UIColors for the rings replaced with global variables of the save values

	1.0.2		11/19/20			Removed old debug utilities
	
	1.0.3		11/20/20			App only supports portrait mode now

	1.0.4		10/20/20			Changes in this version:
										-displayClearRect masks adjusted to fit all phones up to the
										 iPhone 8
										-UIView elemnts moved around; slider moved to match text
										-Slider thumb rectangles increased in size to make them easier to use
