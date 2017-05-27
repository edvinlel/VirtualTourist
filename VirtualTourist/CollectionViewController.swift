//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Edvin Lellhame on 4/19/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate,UICollectionViewDelegateFlowLayout {
	
	// MARK: - Properties
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var insructionView: UIView!
	@IBOutlet weak var instructionExitButton: UIButton!
	@IBOutlet weak var deleteInstructionsLabel: UILabel!
	@IBOutlet weak var newCollectionOutlet: UIButton!
    @IBOutlet var collectionView: UICollectionView!
	
	var coreDataStack: CoreDataStack!
	var currentPin: Pin!
	
	// get the current page and also the max photos allowed from the flickr call
	var currentPage = 1
	var maxPhotos = 0
	
	var photosArray = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// a long press gesture to delete a selected item in the collection view
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(CollectionViewController.longPressTouch))
		longPress.minimumPressDuration = 0.5
		longPress.delaysTouchesBegan = true
		longPress.delegate = self
		collectionView.addGestureRecognizer(longPress)

		guard let latitude = currentPin.latitude, let longitude = currentPin.longitude else { return }
		pinToMap(latitude: Double(latitude)!, longitude: Double(longitude)!)
		
		guard let count = currentPin.photos?.count else { return }
		
		
		// check to see if the count of photos is not 0, then perform a fetch request and get photos to pin
		if count != 0 {
			performPhotosFetch()
		} else {
			// if not, make a call to the flckr api and get photos and save to pin
			flickrAPICall()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// show an instruction pop up of how to delete cell items the first time app has been launched
		if UserDefaults.standard.bool(forKey: "firstLaunch") {
			hideLabels(value: true)
		} else {
			UserDefaults.standard.set(true, forKey: "firstLaunch")
			UserDefaults.standard.synchronize()
			
			hideLabels(value: false)
		}
	}
	
	// MARK: - Helper Method(s)

	/// hide labels and view of the instructional pop up
	private func hideLabels(value: Bool) {
		insructionView.isHidden = value
		deleteInstructionsLabel.isHidden = value
		instructionExitButton.isHidden = value
	}
	
	private func flickrAPICall() {
		FlickrConvenience.fetchPhotosFromFlickr(withPageNumber: currentPage, latitude: currentPin.latitude!, andLongitude: currentPin.longitude!) { (maxPhotos, results, errorString) in
			guard let results = results, let maxPhotos = maxPhotos else {
				print("Error getting results from fetchPhotosFromFlickr in collection view controller")
				return
			}
			
			/// get max photos from flickr and store it for your app use
			self.maxPhotos = maxPhotos
			if self.maxPhotos == 1 {
				self.newCollectionOutlet.isEnabled = false
			}
			
			/// if the results come to 0, send the user back to the map view to try another location
			if results.count == 0 {
				let alert = UIAlertController(title: "Sorry", message: "Couldn't find any photos from this location. Try another place!", preferredStyle: .alert)
				let action = UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
					self.navigationController?.popViewController(animated: true)
				})
				alert.addAction(action)
				self.present(alert, animated: true, completion: nil)
			} else {
				/// store photos to core data and present to collection view
				guard let entityDescription = NSEntityDescription.entity(forEntityName: "Photo", in: self.coreDataStack.managedContext) else { return }
				for photos in results {
					DispatchQueue.main.async(execute: { 
						let photo = Photo(entity: entityDescription, insertInto: self.coreDataStack.managedContext)
						
						photo.pin = self.currentPin
                        let media_url = photos["url_m"] as? String
						photo.media_url = media_url
						photo.maxPages = Int32(maxPhotos)
						
						self.photosArray.append(photo)
					})
				}
				DispatchQueue.main.async {
					self.collectionView.reloadData()
				}
			}
		}
	}
	
	/// function to delete item from collection view
	/// I know this is a tedious way of doing things and I won't be doing it on a final apple store submission app
	@objc func longPressTouch(gestureRecognizer: UILongPressGestureRecognizer) {
		
		if gestureRecognizer.state != UIGestureRecognizerState.ended {
			return
		}
		
		let point = gestureRecognizer.location(in: collectionView)
		let indexPath = collectionView.indexPathForItem(at: point)
		
		if let index = indexPath {
			
			let alert = UIAlertController(title: nil, message: "Are you sure you want to delete this image?", preferredStyle: .alert)
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			let action = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
				self.coreDataStack.managedContext.delete(self.photosArray[index.row])
				self.photosArray.remove(at: index.row)
				self.collectionView.deleteItems(at: [index])

				self.coreDataStack.saveContext()
				DispatchQueue.main.async(execute: { 
					self.collectionView.reloadData()
				})
			})
			alert.addAction(action)
			alert.addAction(cancelAction)
			present(alert, animated: true, completion: nil)
			
		} else {
			print("Error could not find index")
		}
	}
	
	/// perform a Photo fetch request to certain Pin
	private func performPhotosFetch() {
		let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "pin == %@", currentPin)
		
		do {

			photosArray = try coreDataStack.managedContext.fetch(fetchRequest)
			
            if photosArray.count > 0 {
				let photos = photosArray[0]
                self.maxPhotos = Int(photos.maxPages)
                self.currentPage = Int(photos.currentPage)
            }
			
            if self.maxPhotos > 1 {
                self.newCollectionOutlet.isEnabled = true;
                self.newCollectionOutlet.alpha = 1;
            } else {
                self.newCollectionOutlet.isEnabled = false;
                self.newCollectionOutlet.alpha = 0.4;
            }
            
            self.collectionView.reloadData()
			
		} catch {
			print("ERROR\(error.localizedDescription)")
		}
	}
	
	/// add annotation pin from map view to header of collection view for user view
	private func pinToMap(latitude: Double, longitude: Double) {
		let annotation = MKPointAnnotation()
		annotation.coordinate.latitude = latitude
		annotation.coordinate.longitude = longitude
		
		mapView.addAnnotation(annotation)
		
		let span = MKCoordinateSpanMake(0.5, 0.5)
		let location = CLLocationCoordinate2DMake(latitude, longitude)
		let region = MKCoordinateRegionMake(location, span)
		mapView.setRegion(region, animated: true)
	}
	
	// MARK: - IBAction(s)
	
	@IBAction func onInstructionScreenExitPressed(_ sender: Any) {
		hideLabels(value: true)
	}
	
	/// when a new collection is wanted
	@IBAction func onNewCollectionButtonPressed(_ sender: UIButton) {
		/// update current page + 1 and also check to see if current page has reached flickr's api max pages
		currentPage += 1
		
		if currentPage == maxPhotos {
			currentPage = 1
		}
		
		/// disable the new collection outlet button so user cannot press button fast, or until images load
		newCollectionOutlet.isEnabled = false
		newCollectionOutlet.alpha = 0.4
		
		
		/// run the call to flickr again with updated page number
		FlickrConvenience.fetchPhotosFromFlickr(withPageNumber: currentPage, latitude: currentPin.latitude!, andLongitude: currentPin.longitude!) { (maxPhotos, results, errorString) in
            guard let results = results, let maxPhotos = maxPhotos else {
                print("Error getting results from fetchPhotosFromFlickr in collection view controller")
                return
            }
			
			/// delete the current items in the collection view
            if results.count > 0 {
                for i in self.photosArray {
                    self.coreDataStack.managedContext.delete(i)
                    FlickrCache.remove(i.media_url)
                }
                self.photosArray = Array<Photo>()
                self.collectionView.reloadData()
            }
            
			
			guard let entityDescription = NSEntityDescription.entity(forEntityName: "Photo", in: self.coreDataStack.managedContext) else { return }
			for photos in results {
				DispatchQueue.main.async(execute: {
					let photo = Photo(entity: entityDescription, insertInto: self.coreDataStack.managedContext)
					
					photo.pin = self.currentPin
					let media_url = photos["url_m"] as? String
					photo.media_url = media_url

					photo.maxPages = Int32(maxPhotos)
					
					self.photosArray.append(photo)
				})
			}
			DispatchQueue.main.async {
				self.newCollectionOutlet.isEnabled = true
				self.newCollectionOutlet.alpha = 1
				self.collectionView.reloadData()
			}
				
		}
	}
	
	
	// MARK: - CollectionView
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.photosArray.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PinCell
		let photo = self.photosArray[indexPath.row]
        cell.imageView.setImageWith(photo, indexPath.item, completionHandler: { (data, media_url, index) in
            guard let data = data else { return }
            let photoObj = self.photosArray[index!]
            photoObj.image = data as NSData
            try? self.coreDataStack.managedContext.save()
        }, errorHandlerBlock: nil)
		return cell
	}
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size: CGFloat = UIScreen.main.bounds.size.width
        let totalHeight: CGFloat = (size / 3)
        let totalWidth: CGFloat = (size / 3)
		
        return CGSize(width: CGFloat(ceil(totalWidth - 1)), height: CGFloat(ceil(totalHeight - 1)))
    }
    
    @objc(collectionView:layout:insetForSectionAtIndex:) func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    @objc(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:) func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    @objc(collectionView:layout:minimumLineSpacingForSectionAtIndex:) func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

}
