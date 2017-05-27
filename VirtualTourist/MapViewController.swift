//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Edvin Lellhame on 4/18/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class MapViewController: UIViewController {
	
	// MARK: - Properties
	@IBOutlet weak var mapView: MKMapView!
	
	
	let longPressGesture = UILongPressGestureRecognizer()
	var coreDataStack: CoreDataStack!
	var pins: [Pin] = []
	var currentPin: Pin!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		loadPins()
		
		longPressGesture.addTarget(self, action: #selector(addAnnotationFromLongPress))
		mapView.addGestureRecognizer(longPressGesture)
		mapView.delegate = self
	}

	func addAnnotationFromLongPress() {
		// long press the map view to drop a pin and store that pin to core data
		if longPressGesture.state == .began {
			let point = longPressGesture.location(in: mapView)
			let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
			
			let annotation = PinAnnotation()
			annotation.coordinate = coordinate
			
			mapView.addAnnotation(annotation)
			guard let entitiyDescription = NSEntityDescription.entity(forEntityName: "Pin", in: coreDataStack.managedContext) else {
				return
			}
			let pin = Pin(entity: entitiyDescription, insertInto: coreDataStack.managedContext)
			pin.latitude = "\(annotation.coordinate.latitude)"
			pin.longitude = "\(annotation.coordinate.longitude)"
			coreDataStack.saveContext()
			
			annotation.pin = pin
			pins.append(pin)
		}
	}

	private func loadPins() {
		// fetch and load pins to the map view
		let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
		
		do {
			pins = try coreDataStack.managedContext.fetch(fetchRequest)
			pinsToMap(pins: pins)
		} catch let error as NSError {
			print("Error in loadPins \(error), \(error.userInfo)")
		}
	}
	
	private func pinsToMap(pins: [Pin]) {
		// go through Pin array and add data to the map
		for pin in pins {
			if let longitude = Double(pin.longitude!), let latitude = Double(pin.latitude!) {
				let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
				let annotation = PinAnnotation()
				annotation.coordinate = coordinate
				annotation.pin = pin
				
				mapView.addAnnotation(annotation)
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "photosSegue" {
			let collectionVC = segue.destination as! CollectionViewController
			
			/// pass the core data stack and current pin selected
			collectionVC.coreDataStack = coreDataStack
			collectionVC.currentPin = currentPin
		}
	}
}

extension MapViewController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		DispatchQueue.main.async {
			// i was having a problem of going back to the pin annotation you just got back from
			// deslecting it fixed the problem
			mapView.deselectAnnotation(view.annotation, animated: true)
			
			// get the current pin and store it
			guard let pin = view.annotation as? PinAnnotation else { return }
			self.currentPin = pin.pin
			
			self.performSegue(withIdentifier: "photosSegue", sender: self)
		}
		
	}
}

