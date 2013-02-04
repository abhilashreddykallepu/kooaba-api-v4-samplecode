# iOS Sample Code for kooaba Query API V4

## Prerequisites

This sample code provides an example iOS app that sends queries to kooaba's Query API V4. You will need the following in order to successfully run the sample code:

* An account on the [kooaba platform](https://platform.kooaba.com/). There is a free plan so go ahead and sign up if you haven't already.
* The Key ID and Secret Token of a Query Key for Query API V4
* A working iOS development environment for iOS 6.0 or later (simulator only is ok), recommended deployment target is 5.1 or higher.
* Automatic Reference Counting - The sample code requires ARC

## Quick Start

To get started, run Xcode and

1. Add your Query Key ID and Query Key Secret Token to the constants defined at the top of the `KIRAppDelegate.m` file.
2. Run the app in the simulator or on an iOS device.
3. Tap the camera button to take a picture.

The results of your query will be displayed on the main screen.

## Troubleshooting

You can find more documentation on the Query API V4 at [http://kooaba.github.com/](http://kooaba.github.com/).

### When I run the sample code, I get the error `NSURLErrorDomain error -1012`. What could be wrong?

Check your Query Key ID and Secret Token in the `KIRAppDelegate.m` file.
