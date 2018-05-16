//
//  MSVAddrAutoCompletion.swift
//  faeBeta
//
//  Created by Yue Shen on 10/29/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import GooglePlaces

extension MapSearchViewController: MKLocalSearchCompleterDelegate {
    
    // GMSLookUpPlaceForCoordinate
    func lookUpForCoordinate() {
        print("lookUpForCoordinate")
        General.shared.lookUpForCoordinate { (place) in
            let region = MKCoordinateRegionMakeWithDistance(place.coordinate, 20000, 20000)
            self.delegate?.jumpToLocation?(region: region)
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    // GMSAutocompleteFilter
    func placeAutocomplete(_ searchText: String) {
        Key.shared.selectedPrediction = nil
        googleFilter.type = .city
        GMSPlacesClient.shared().autocompleteQuery(searchText, bounds: nil, filter: googleFilter, callback: {(results, error) -> Void in
            if let error = error {
                joshprint("Autocomplete error \(error)")
                self.googlePredictions.removeAll(keepingCapacity: true)
                self.showOrHideViews(searchText: searchText)
                return
            }
            if let results = results {
                self.googlePredictions = results
            }
            self.showOrHideViews(searchText: searchText)
        })
    }
    
    // Mark: - MKLocalSearchCompleterDelegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        filteredLocations = searchResults.map({ $0.title })
        tblLocationRes.reloadData()
        showOrHideViews(searchText: completer.queryFragment)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}
