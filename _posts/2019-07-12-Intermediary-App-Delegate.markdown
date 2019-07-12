---
layout: post
title:  "Intermediary App Delegate"
date:   2019-07-12 09:00:00
categories: ios swift appdelegate architecture
---

The `UIApplicationDelegate` has a tendency to become very cluttered very quickly. Since it acts as a single point of contact between the App and the OS, a lot of business logic and state gets shoved into the AppDelegate instance. This makes the class large and unwieldy, while also breaking the Single Responsibility Principle.

Introducing the Intermediary App Delegate. This allows developers to break their massive App Delegate into multiple App Delegates, each focusing on a single responsibility. For example, one app delegate my be responsible for handling deep links into an app, while another delegate is responsible for initializing and maintaining a crash reporting library. Since these App Delegates have been separated from the primary App Delegate, instances of these objects may be used throughout the application, instead of going through the shared AppDelegate instance.

I created this project here on GitHub as a Swift Package, and can easily be imported into your projects on Xcode 11.

## How It Works

iOS still interacts with most of the methods in the AppDelegate via Objective C, so the methods cannot be implemented in a Protocol Extension, and must be implemented in a NSObject subclass. The IntermediaryAppDelegate package declares two concrete classes: 

1. IntermediaryAppDelegate: This class implements most methods in the UIApplicationDelegate protocol, and routs each of those method calls to all of the registered delegates. 
2. RemoteNotificationIntermediaryAppDelegate: This class subclasses IntermediaryAppDelegate, and provides implementations for methods needed to handle remote notifications.

I split the functionality into two classes because, if the Remote Notification capability is not listed in the info.plist but the methods are implemented in the UIApplicationDelegate subclass, the app dumps an error message out to the logs.

In iOS 13, the new methods used to configure and discard the UISceneSessions can be defined in a Protocol Extension, and don’t require Objective C support. Since the OS will call those methods if they are provided in the UIApplicationDelegate, I implemented them in the ConfigureSceneIntermediaryAppDelegate protocol. To have your iOS 13 app support the new Scene Sessions, simply add that protocol to your UIApplicationDelegate, and implement the methods in one of the registered App Delegates. 

There were a few methods I chose not to implement in the IntermediaryAppDelegate:
1. `application(:supportedInterfaceOrientationsFor:)`: If this method is defined, the app will use the returned value instead of the UIInterfaceOrientation key of the app’s Info.plist. Since not every app wants to override this value, I do not support routing this value to the registered app delegates.
2. `application(:handle:completionHandler:)`: This method is used to handle SiriKit intents. I wrote an implementation for this method in an early version of the IntermediaryAppDelegate, but chose to remove it since I both don’t understand how it is expected to work, and have no way to easily test if the method is working. 

Some methods in the UIApplicationDelegate require a result. In my implementation, I iterate through the registered delegates, check if any return a non-default value, and return that value. Otherwise, I return the default values as described in Apple’s documentation. 

Here is a simple example. In `application(:willFinishLaunchingWithOptions:)`, I call reduce across the array of registered delegates. I begin the reduce with the default response for this method, and only set the value to false if a registered delegate returns false from its implementation.

```
open func application(_ application: UIApplication,
                 willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    return delegates.reduce(into: true) { result, delegate in
        if delegate.application?(application, willFinishLaunchingWithOptions: launchOptions) == false {
            result = false
        }
    }
}
```


## Using the Library

Adding this library to your project is pretty simple. You can either import the Swift package via Xcode 11, or download the source, and include it in the project directly. Here are some steps for implementing the IntermediaryAppDelegate:

1. Create a main UIApplicationDelegate, and subclass either IntermediaryAppDelegate or RemoteNotificationIntermediaryAppDelegate if you need to support remote notifications. Also, add the ConfigureSceneIntermediaryAppDelegate protocol if using SwiftUI. 
2. Create the new UIApplicationDelegates where each delegate method will be implemented. Each class should be focused around a single responsibility, like managing the lifecycle of a Crash Reporter, handling Remote Notifications, or responding to Deep Links.
3. Register the App Delegates in the main UIApplicationDelegate. This is done by simply returning each AppDelegate in the init method of the main UIApplicationDelegate like below:

```
@UIApplicationMain
class AppDelegate: RemoteNotificationIntermediaryAppDelegate, ConfigureSceneIntermediaryAppDelegate {

    override init() {
        super.init([CoreModule(),
                    SceneSessionModule(),
                    AppLifeCycleModule(),
                    NotificationModule()])
    }
}
```

You can find the IntermediaryAppDelegate package on [GitHub here](https://github.com/steg132/IntermediaryAppDelegate)

And a simple [Sample Project here](https://github.com/steg132/ModularApp)
