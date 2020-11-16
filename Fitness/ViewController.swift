// ==============================================================================================
//  ViewController.swift
//  Fitness
//
//  Created by Jonathan Uhler on 2/28/20.
//  Copyright © 2020 Jonathan Uhler. All rights reserved.
//
// ==============================================================================================
// Revision History
//	version		  date						changes
//  -------		--------			-----------------------
//	1.0.0		11/15/20			Changes in this version:
//										-First workable version of Fitness
//
//
//

// Import healthkit utilities
import UIKit
import HealthKit
import HealthKitUI

// Create the healthSore healthkit manager --> this is what is used to read and write HK data
let healthStore = HKHealthStore()


// ==============================================================================================
// class ViewController extends UIViewController
// ==============================================================================================
//
//
// MARK: class ViewController
class ViewController: UIViewController {
	
	// Get the screen dimensions
	let screenRect = UIScreen.main.bounds
	lazy var screenWidth = screenRect.size.width
	lazy var screenHeight = screenRect.size.height
	
	// MARK: Begin: Getting data from HK
	var resultEnergy: Double = 0.0
	var resultSteps: Double = 0.0
	var resultMove: Double = 0.0
	
	// Shape layer for rings
	let shapeLayer = CAShapeLayer()
	
	// Time
	let globalNow = Date()
	
	// resultData is what is returned by the function at the end
	var resultData = 0.0
	
	enum resultType {
		case energy
		case steps
		case move
	}
	
	
	// ==============================================================================================
	// func getExerciseData
	//
	// A function that gets the required data from the Health app for the ring app
	//
	// Arguments--
	//
	// dataType (of type HKQuantityTypeIdentifier):		the type of data to search for (steps,
	//													calories, etc.)
	//
	// healthQuantityType (of type HKQuantityType):		again, the type of data to get, but used in
	//													a different location and manner
	//
	// unitOfData (of type HKUnit):						the unit in which to return data (ex. kcals)
	//
	// Returns--
	//
	// resultData:										The result from healthkit
	//
	// MARK: func getExerciseData
	func getExerciseData(resultType: resultType, dataType: HKQuantityTypeIdentifier, unitOfData: HKUnit, fromTime: Date, toTime: Date) -> Void {
		
		print("from: \(fromTime), to: \(toTime)")
		
		// Uses the dataType argument to get the type of data (.activeEnergyBurned, .stepCount,
		// or .distanceWalkingRunning)
		guard let healthQuantityType = HKQuantityType.quantityType(forIdentifier: dataType) else { return }
		
		// Setup the range of time to get health data from
		var interval = DateComponents()
		interval.day = 1
		
		// Setup the query to healthkit (this is what you need to get and do with HK)
		let query = HKStatisticsCollectionQuery(quantityType: healthQuantityType,
												quantitySamplePredicate: nil,
												options: [.cumulativeSum],
												anchorDate: fromTime,
												intervalComponents: interval)
		
		// Handle results (either and error or data back)
		query.initialResultsHandler = { _, result, error in
			// Get data for a certain time period
			result?.enumerateStatistics(from: fromTime, to: toTime) { statistics, _ in
				
				if let sum = statistics.sumQuantity() {
					// Save the data in a double variable with the correct unit
					switch resultType {
					case .energy:
						self.resultEnergy = sum.doubleValue(for: unitOfData)
					
					case .steps:
						self.resultSteps = sum.doubleValue(for: unitOfData)
						
					case .move:
						self.resultMove = sum.doubleValue(for: unitOfData)
					}
				} // end: if
				
			} // end: result!.enumerateStatistics
		} // end: query.initialResultsHandler
		
		// Execute the query with health kit to get HK data
		healthStore.execute(query)
		
	} // end: func getExerciseData

	
	// ==============================================================================================
	// func viewDidLoad
	//
	// Gets data and authorization from healthkit once the UIView of the app is able to load
	//
	// Arguments--
	// None
	//
	// Returns--
	// None
	//
	// MARK: func viewDidLoad
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		getExerciseData(resultType: .energy, dataType: HKQuantityTypeIdentifier.activeEnergyBurned, unitOfData: HKUnit.largeCalorie(), fromTime: Calendar.current.startOfDay(for: globalNow), toTime: globalNow)
		
		getExerciseData(resultType: .steps, dataType: HKQuantityTypeIdentifier.stepCount, unitOfData: HKUnit.count(), fromTime: Calendar.current.startOfDay(for: globalNow), toTime: globalNow)
		
		getExerciseData(resultType: .move, dataType: HKQuantityTypeIdentifier.distanceWalkingRunning, unitOfData: HKUnit.mile(), fromTime: Calendar.current.startOfDay(for: globalNow), toTime: globalNow)
		
		
		if HKHealthStore.isHealthDataAvailable() {
			// Add code to use HealthKit here.
			
			let infoToRead = Set([
				HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!,
				HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
				HKSampleType.quantityType(forIdentifier: .stepCount)
			])
			
			let infoToWrite = Set([
				HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!,
				HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
				HKSampleType.quantityType(forIdentifier: .stepCount)!,
			])
			
			
			// Check for Authorization
			healthStore.requestAuthorization(toShare: infoToWrite, read: infoToRead as? Set<HKObjectType>) { (success, error) in
				if (success) {
					
					
					
				} // end: if
			} // end: healthStore.requestAuthorization
		} // end: if
		
		
		// Check for left and right swiping to change the date being displayed
		let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
		swipeRight.direction = UISwipeGestureRecognizer.Direction.right
		self.view.addGestureRecognizer(swipeRight)

		let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
		swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
		self.view.addGestureRecognizer(swipeLeft)


		// MARK: Visuals and rings
		// Set the app background color to a dark gray
		self.view.backgroundColor = UIColor.init(red: 0.04, green: 0.05, blue: 0.05, alpha: 1.0)

		// Position on the screen to display the three rings
		let CGPoint_x = screenWidth * 0.5
		let CGPoint_y = screenHeight * 0.35
		
		// Call createTrackLayer to create circles
		// Exercise circle
		createTrackLayer(layerRadius: 110, layerStart: -CGFloat.pi / 2, layerEnd: 1.5 * CGFloat.pi, layerStrokeColor: UIColor.init(red: 0.14, green: 0.14, blue: 0.14, alpha: 1.0).cgColor, circleStrokeColor: UIColor.init(red: 0.92, green: 0.06, blue: 0.33, alpha: 1.0).cgColor, point_x: CGPoint_x, point_y: CGPoint_y)
		// Steps circle
		createTrackLayer(layerRadius: 75, layerStart: -CGFloat.pi / 2, layerEnd: 1.5 * CGFloat.pi, layerStrokeColor: UIColor.init(red: 0.14, green: 0.14, blue: 0.14, alpha: 1.0).cgColor, circleStrokeColor: UIColor.green.cgColor, point_x: CGPoint_x, point_y: CGPoint_y)
		// Miles circle
		createTrackLayer(layerRadius: 40, layerStart: -CGFloat.pi / 2, layerEnd: 1.5 * CGFloat.pi, layerStrokeColor: UIColor.init(red: 0.14, green: 0.14, blue: 0.14, alpha: 1.0).cgColor, circleStrokeColor: UIColor.init(red: 0.38, green: 0.87, blue: 0.91, alpha: 1.0).cgColor, point_x: CGPoint_x, point_y: CGPoint_y)
	}
	
	// ==============================================================================================
	// func respondToSwipeGesture
	//
	// A function to recognize and repond to the user swiping on the screen (if this happens, the date
	// being displayed will be changed)
	//
	// Arguments--
	// guesture:			the type of gesture to analyze
	//
	// Returns--
	// None
	//
	// MARK: func respondToSwipeGesture
	@objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
		// Verify that the gesture is a UISwipeGesture
		if let swipeGesture = gesture as? UISwipeGestureRecognizer {
			switch swipeGesture.direction {
				// Swiping right
				case UISwipeGestureRecognizer.Direction.right:
					
					let prevDay = globalNow - (1000)
					displayDate(dateToDisplay: prevDay)
					
					// Call the getExerciseData function again to update the data
					getExerciseData(resultType: .energy, dataType: HKQuantityTypeIdentifier.activeEnergyBurned, unitOfData: HKUnit.largeCalorie(), fromTime: Calendar.current.startOfDay(for: prevDay), toTime: prevDay)
					
					getExerciseData(resultType: .steps, dataType: HKQuantityTypeIdentifier.stepCount, unitOfData: HKUnit.count(), fromTime: Calendar.current.startOfDay(for: prevDay), toTime: prevDay)
					
					getExerciseData(resultType: .move, dataType: HKQuantityTypeIdentifier.distanceWalkingRunning, unitOfData: HKUnit.mile(), fromTime: Calendar.current.startOfDay(for: prevDay), toTime: prevDay)

				// Swiping left
				case UISwipeGestureRecognizer.Direction.left:
					
					let nextDay = globalNow + (1000 * 60 * 60 * 24)
					displayDate(dateToDisplay: nextDay)
					
					// Call the getExerciseData function again to update the data
					getExerciseData(resultType: .energy, dataType: HKQuantityTypeIdentifier.activeEnergyBurned, unitOfData: HKUnit.largeCalorie(), fromTime: Calendar.current.startOfDay(for: nextDay), toTime: nextDay)
					
					getExerciseData(resultType: .steps, dataType: HKQuantityTypeIdentifier.stepCount, unitOfData: HKUnit.count(), fromTime: Calendar.current.startOfDay(for: nextDay), toTime: nextDay)
					
					getExerciseData(resultType: .move, dataType: HKQuantityTypeIdentifier.distanceWalkingRunning, unitOfData: HKUnit.mile(), fromTime: Calendar.current.startOfDay(for: nextDay), toTime: nextDay)

				// No swipe; breaking
				default:
					break
			} // end: switch
		} // end: if
	} // end: func respondToSwipeGesture
	
	
	// ==============================================================================================
	// func displayDate
	//
	// Displays the date stamp at the top of the app
	//
	// Arguments--
	// dateToDisplay:		the date to show data for (changed by swiping the screen)
	//
	// Returns--
	// None
	//
	// MARK: func displayDate
	func displayDate(dateToDisplay: Date) {
		let date = dateToDisplay
		let format = DateFormatter()
		format.dateFormat = "MM / dd / yyyy"
		let formattedDate = format.string(from: date)

		let dateFrame:CGRect = CGRect(x: screenWidth * 0.5 - 90, y: screenHeight * 0.05, width: 180, height: 25)
		let dateLabel:UILabel = UILabel(frame: dateFrame)
		dateLabel.text = "\(formattedDate)"
		dateLabel.textAlignment = .center
		dateLabel.font = UIFont(name: "Gill Sans", size: 30)
		dateLabel.textColor = UIColor.white
		self.view.addSubview(dateLabel)
	}


	// ==============================================================================================
	// func createTrackLayer
	//
	// Creates the gray rings that are filled in inside the app
	//
	// Arguments--
	// layerRadius:			the final radius of the circle
	//
	// layerStart:			the angle at which the track layer and the circle starts
	//
	// layerEnd:			the angle at whcih the track layer and the circle end
	//
	// layerStrokeColor:	the fill color of the track (bottom) layer
	//
	// circleStrokeColor:	the fill color of the circle (top) layer
	//
	// Returns--
	// None
	//
	// MARK: func createTrackLayer
	func createTrackLayer(layerRadius: CGFloat, layerStart: CGFloat, layerEnd: CGFloat, layerStrokeColor: CGColor, circleStrokeColor: CGColor, point_x: CGFloat, point_y: CGFloat) {
		
		// Define the track as a shape layer
		let trackLayer = CAShapeLayer()
		
		// Create the circular path with the arguments from the function call
		let circularPath = UIBezierPath(arcCenter: CGPoint(x: point_x, y: point_y), radius: layerRadius, startAngle: layerStart, endAngle: layerEnd, clockwise: true)
		// Set the trackLayer to be the circular path
		trackLayer.path = circularPath.cgPath
		
		// Fill in the track layer
		trackLayer.strokeColor = layerStrokeColor
		trackLayer.lineWidth = 30
		trackLayer.fillColor = UIColor.clear.cgColor
		trackLayer.lineCap = CAShapeLayerLineCap.round
		view.layer.addSublayer(trackLayer)
		
		// Create circle
		shapeLayer.path = circularPath.cgPath
		
		// Fill in the circle
		shapeLayer.strokeColor = circleStrokeColor
		shapeLayer.lineWidth = 30
		shapeLayer.fillColor = UIColor.clear.cgColor
		shapeLayer.lineCap = CAShapeLayerLineCap.round
		
		shapeLayer.strokeEnd = 0
		
		view.layer.addSublayer(shapeLayer)
		
		view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
	} // end: func createTrackLayer

	
	// ==============================================================================================
	// func handleTap
	//
	// A function that begins displaying the UI information when the screen is tapped
	//
	// Arguments--
	// None
	//
	// Returns--
	// None
	//
	// MARK: func handleTap
	@objc func handleTap() {
		// Create all of the ring animations
		// Energy animation
		let energyRounded = round(1.0 * self.resultEnergy) / 1.0
		handleRingAnimation(dataResults: energyRounded,
							goal: 150,
							frame_x: 0, frame_y: screenHeight * 0.55, frame_w: screenWidth, frame_h: 150,
							labelTextColor: UIColor.init(red: 0.92, green: 0.06, blue: 0.33, alpha: 1.0),
							labelMsg: "WORK",
							isThousands: false)
		// Steps animation
		let stepsRounded = round(1.0 * self.resultSteps) / 1.0
		handleRingAnimation(dataResults: stepsRounded,
							goal: 5000,
							frame_x: 0, frame_y: screenHeight * 0.62, frame_w: screenWidth, frame_h: 150,
							labelTextColor: UIColor.green,
							labelMsg: "STEPS",
							isThousands: true)
		// Miles animation
		let moveRounded = round(100.0 * self.resultMove) / 100.0
		handleRingAnimation(dataResults: moveRounded,
							goal: 2,
							frame_x: 0, frame_y: screenHeight * 0.69, frame_w: screenWidth, frame_h: 150,
							labelTextColor: UIColor.init(red: 0.38, green: 0.87, blue: 0.91, alpha: 1.0),
							labelMsg: "MOVE",
							isThousands: false)
	}
	
	
	// ==============================================================================================
	// func handleRingAnimation
	//
	// A function to animate the ring's progress when the app loads
	//
	// Arguments--
	// dataResults:		the results from the getExerciseData function
	//
	// goal:			determines the size of the ring, this is the end goal in an amount of units
	//
	// frame_x:			the x position of the frame that encloses the text
	//
	// frame_y:			the y position of the frame
	//
	// frame_w:			the width of the frame
	//
	// frame_h:			the height of the frame
	//
	// labelTextColor:	the color to use for the text
	//
	// labelMsg:		this is used for the ring type (like MOVE or STEPS)
	//
	// isThousands:		a boolean used for steps (if this is true, the text will be displayed as 0k/5k
	//					instead of 0/5000)
	//
	// Returns--
	// None
	//
	// MARK: func handleRingAnimation
	func handleRingAnimation(dataResults: Double, goal: Int, frame_x: CGFloat, frame_y: CGFloat, frame_w: CGFloat, frame_h: CGFloat, labelTextColor: UIColor, labelMsg: String, isThousands: Bool) {
		
		let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
		
		// Take the data from healthkit (like resultEnergy) and the goal
		let currentDataStatus: Double = Double(dataResults)
		let goalForData: Int = goal
		// Convert the data to a float (from 0 to 1) and then to a percentage
		let dataToFloat: Float = Float(currentDataStatus) / Float(goalForData)
		let dataToPercent: Int = Int(dataToFloat * 100)
		
		
		// Animation
		basicAnimation.toValue = dataToFloat // how long the animation is
		basicAnimation.duration = 1 // 1 second to complete the animation
		// Filling the correct area
		basicAnimation.fillMode = CAMediaTimingFillMode.forwards
		basicAnimation.isRemovedOnCompletion = false // do not remove once completed
		
		// Add the shape layer
		shapeLayer.add(basicAnimation, forKey: "test")
		
		
		// Complete the animation
		// Setup the frame and basic message
		let animationFrame:CGRect = CGRect(x: frame_x, y: frame_y, width: frame_w, height: frame_h)
		let animationLabel:UILabel = UILabel(frame: animationFrame)
		
		if (isThousands) {
			animationLabel.text = "\(labelMsg):  \(currentDataStatus / 1000)k/\(goalForData / 1000)k | \(dataToPercent)%"
		}
		else {
			animationLabel.text = "\(labelMsg):  \(currentDataStatus)/\(goalForData) | \(dataToPercent)%"
		}
		
		animationLabel.textAlignment = .center
		animationLabel.font = UIFont(name: "Gill Sans", size: 30)
		animationLabel.textColor = labelTextColor
		
		self.view.addSubview(animationLabel)
		
	} // end: func handleRingAnimation

} // end: class ViewController

