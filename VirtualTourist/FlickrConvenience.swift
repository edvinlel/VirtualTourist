//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Edvin Lellhame on 5/17/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import Foundation

struct FlickrConvenience {
	
	static func photoSearchJSON(data: Data?, completion: @escaping (_ result: AnyObject?, _ error: Error?) -> ()) {
		var parsedResult: AnyObject!
		do {
			parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
		} catch {
			completion(nil, error)
		}
		
		completion(parsedResult, nil)
	}
	
	private static func parseDictionary(results: AnyObject, completion: @escaping (_ maxPages: Int?, _ result: [[String: AnyObject]]?, _ errorString: String) -> ()) {
		guard let photos = results["photos"] as? [String: AnyObject] else {
			completion(nil, nil, "Error parsing photos ditionary")
			return
		}
		
		guard let maxPhotos = photos["pages"] as? Int else {
			completion(nil, nil, "Error parsing maxPhotos")
			return
		}
		
		guard let photo = photos["photo"] as? [[String: AnyObject]] else {
			completion(nil, nil, "Error parsing photo dictionary")
			return
		}
		
		completion(maxPhotos, photo, "No errors found")
	}
	
	static func fetchPhotosFromFlickr(withPageNumber page: Int, latitude: String, andLongitude longitude: String, completion: @escaping (_ maxPages: Int?, _ respone: [[String: AnyObject]]?, _ errorString: String) -> ()) {
		
		let url = NSMutableURLRequest(url: URL(string: createPhotosSearchURL(pageNumber: page, latitude: latitude, longitude: longitude))!)
		print(url)
		Networking.HTTPSendRequest(withUrl: url) { (result, error) in
			guard error == nil else {
				print("ERROR IN ERROR==NIL")
				return
			}
			guard let result = result else { return }
			
			parseDictionary(results: result, completion: { (maxPhotos, photos, errorString) in
				
				guard photos != nil, maxPhotos != nil else {
					completion(nil, nil, errorString)
					return
				}
				completion(maxPhotos, photos, "No error, parse successful")
			})
		}
	}
	
	private static func createPhotosSearchURL(pageNumber: Int, latitude: String, longitude: String) -> String {
		var components = URLComponents()
		
		components.scheme = "https"
		components.host = "api.flickr.com"
		components.path = "/services/rest/"
		components.queryItems = [
			URLQueryItem(name: "method", value: Constants.FlickrURLValue.flickrMethods.photosSearch.rawValue),
			URLQueryItem(name: "api_key", value: Constants.FlickrAPI.key),
			URLQueryItem(name: Constants.FlickrURLName.accuracy, value: Constants.FlickrURLValue.flickrAccuracy.country.rawValue),
			URLQueryItem(name: Constants.FlickrURLName.lat, value: latitude),
			URLQueryItem(name: Constants.FlickrURLName.lon, value: longitude),
			URLQueryItem(name: Constants.FlickrURLName.extras, value: Constants.FlickrURLValue.flickrExtras.url_m.rawValue),
			URLQueryItem(name: Constants.FlickrURLName.page, value: "\(pageNumber)"),
			URLQueryItem(name: Constants.FlickrURLName.per_page, value: Constants.FlickrURLValue.perPage),
			URLQueryItem(name: Constants.FlickrURLName.format, value: Constants.FlickrURLValue.format),
			URLQueryItem(name: Constants.FlickrURLName.callback, value: Constants.FlickrURLValue.callBack),
		]
		
		return components.string!
	}

}
