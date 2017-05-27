//
//  Consants.swift
//  VirtualTourist
//
//  Created by Edvin Lellhame on 5/17/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import Foundation

struct Constants {
	
	struct FlickrAPI {
		static let key = "f24a34d255053de0a062c8a1edaf8a8d"
		static let secret = "95d7a952c65eb973"
		static let authToken = "72157680886976295-3c17b7ab9dff1867"
		static let apiSig = "74124533127439e887dba9c9dcb73e98"
	}
	
	struct FlickrURLName {
		
		static let method = "method"
		
		static let api_key = "api_key"
		static let accuracy = "accuracy"
		static let lat = "lat"
		static let lon = "lon"
		static let extras = "extras"
		static let page = "page"
		static let per_page = "per_page"
		static let format = "format"
		static let callback = "nojsoncallback"
		static let auth_token = "auth_token"
		static let api_sig = "api_sig"
	}
	
	struct FlickrURLValue {
		
		/// Constant values for each query item for Flickr URL
		
		/// Enum for different Flickr methods
		enum flickrMethods: String {
			case photosSearch = "flickr.photos.search"
		}
		
		/// Enum for different Flickr accuracy
		/**
			World level is 1
			Country is ~3
			Region is ~6
			City is ~11
			Street is ~16
		*/
		
		enum flickrAccuracy: String {
			case worldLevel = "1"
			case country = "3"
			case region = "6"
			case city = "11"
			case street = "16"
		}
		
		enum flickrExtras: String {
			case url_m = "url_m"
		}
		
		static let perPage = "21"
		static let format = "json"
		static let callBack = "1"
	}
}
