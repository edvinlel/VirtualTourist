//
//  Networking.swift
//  VirtualTourist
//
//  Created by Edvin Lellhame on 5/17/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import Foundation

struct Networking {
	
	static func HTTPSendRequest(withUrl request: NSMutableURLRequest, completion: @escaping (_ result: AnyObject?, _ error: Error?) -> ()) {
		let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
			guard error == nil else {
				completion(nil, error)
				return
			}
			
			guard let data = data else {
				completion(nil, error)
				return
			}
			
			FlickrConvenience.photoSearchJSON(data: data, completion: completion)
		}
		task.resume()
	}
}
