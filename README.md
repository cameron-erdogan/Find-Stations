#Find Some CitiBike Stations!

## Write Up

- Written using MapKit for map functionality, Alamofire for making web requests, and SwiftJSON for nice JSON processing
- The crux of the app is a map with pins representing the locations of CitiBike dock locations
- On iOS 9 and above the pins are color-coded according to the number of available bikes. Red means no available bikes and green means all bikes are available, with a spectrum of colors in between. In iOS 8 and below, all pins are red.
- Data is cached via CoreData. If you open the app in airplane mode, it'll use the results of the most recent web request
- The database is queried at app's launch. I wasn't sure of the best rate of refresh, so I include a "reload data" button above the map to manually re-query the CitiBike database. The ttl of the data is 10 seconds, so re-querying every minute or so might be just as useful. 
- When you tap on a pin, it shows the name of that station and the number of bikes available / total station capacity. 
- When you tap on the detail disclosure of a pin, it launches a modal view that shows more detailed information about the station. This view can be dismissed. 

## Running notes:

- this should build on iOS 8 and above
- it's written in Swift 2.2 in order to successfully target iOS 8 SDK
- Because the project uses CocoaPods for managing submodules, you must open FindStations.xcworkspace to view and build the code (NOT FindStations.xcodeproj)
