# iOS Sample Code for kooaba's Query API V4

## Prerequisites

This sample code is an example iOS app that sends queries to kooaba's Query API V4. You will need the following in order to successfully build and run the sample code:

* An account on the [kooaba platform](https://platform.kooaba.com/). There is a free plan so go ahead and sign up if you haven't already.
* The Key ID and Secret Token of a Query Key for Query API V4
* A working iOS development environment for iOS 6.0 or later (simulator only is ok), recommended deployment target is 5.1 or higher.
* Automatic Reference Counting - The sample code requires ARC

## Quick Start

To get started, run Xcode and

1. Add your Query Key ID and Query Key Secret Token to the constants defined at the top of the `KIRAppDelegate.m` file.
2. Run the app in the simulator or on an iOS device.
3. Tap the camera button to take a picture.

A list of the matching items will be displayed.

## Features

The sample app will show the titles of the items that were recognized. To view the individual attributes for a recognized item, tap the blue disclosure button for an item. You can also view the raw response for a query.

### Redirect URLs

The sample app can also be used as a simple demo app. When creating an item, add metadata to the item and specify an object as the metadata with an attribute named `redirect_url`. In the list of results, if the sample app detects that an item has a `redirect_url` in its metadata, then tapping on the item on the response screen will load that URL in a web view.

For example, the metadata for an item that would load the kooaba home page would be entered as:

`{"redirect_url": "http://kooaba.com/"}`

### Demo Mode

The sample app has two modes, "Debug Mode" and "Demo Mode". In "Debug Mode", the app will always show the list of results when receiving a response from the Query API. In "Demo Mode", if the first item has a valid `redirect_url`, then the sample app will automatically load the URL of the first item in a web view. This can be useful for demonstrating the capabilities of the kooaba API.

## Troubleshooting

You can find more documentation on the Query API V4 at [http://kooaba.github.com/](http://kooaba.github.com/).

### When I run the sample code, I get the error `NSURLErrorDomain error -1012`. What could be wrong?

Check your Query Key ID and Secret Token in the `KIRAppDelegate.m` file. This error usually indicates that the server did not recognize the Query Key ID or the request was not signed with the correct Secret Token.

