<p align="center">
    <img src="https://s3-us-west-2.amazonaws.com/taywils.me.static.files/AppSession.png" alt="AppSession" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/platform-iOS%209%2B-blue.svg?style=flat" alt="Platform: iOS 9+" />
    <a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/language-swift2-f48041.svg?style=flat" alt="Language: Swift 2" /></a>
    <img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat" alt="License: MIT" />
</p>

# Introduction

AppSession is a simple wrapper around a dictionary type that allows one
to easily share data across different SpriteKit Scenes and or ViewControllers
for the duration of a single session of an App.

## Installation

AppSession is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AppSession"
```

To run the example project, clone the repo, and run `pod install` from the Example directory first.

# Basic Usage

AppSession uses the [sharedInstance](https://thatthinginswift.com/singletons/) pattern to represent a Singleton.

Thus there is no need for declaring any AppSession objects.

## Set
Store something in AppSession

```swift
let foobar = 42
AppSession.set("foo", value: foobar)
```

## Get
Later on take something out of AppSession

```swift
let barFoo = AppSession.get("foo") as? Int
```

## Delete
Use delete to get rid of something you don't need in AppSession anymore

```swift
AppSession.delete("foo")
```

## Group
Use __group__ to reduce key collisions, or to mark data as related

Example: Pretend we are on the menu page of a restaurant app

```swift
AppSession.set("main_dish", value: "Steak", group: "order")
AppSession.set("side_dish", value: "Salad", group: "order")
AppSession.set("coupon", value: "12231", group: "order")
```

Now when you segue over to the checkout page, you pull the "order" from the AppSession
```swift
let customerOrder = AppSession.get("order") as? [String:Any]
```

Then if the coupon causes some modal view to display over the checkout page that needs to update the order
we can just update the AppSession "order" group
```swift
AppSession.set("special_discount", value: 0.20, group: "order")
```

## Pop
Then when you dismiss the modal you can just pop the discount and apply it to your price
```swift
let discount = AppSession.pop("special_discount") as? Double
```
Now isn't that neat? We didn't have to fire any NSNotifications or re-wire our Storyboards or add a specialDiscount property to a Model or modify our unit tests that probably would have broken the build on our CI server due to some random place in the code that wasn't updated to rely on the new specialDiscount property.

# Advanced Usage

AppSession allows you to store complex types such as classes, structs and nested arrays.

The trick with using them is to properly typecast the value upon retrieval.

## Structs and Classes
Consider a struct that you've defined in your code, you place it in the AppSession.

```swift
struct BasicStruct {
    var property: String

    init(property: String) {
        self.property = property
    }
}
let basicStruct = BasicStruct(property: "hello world")

AppSession.set("basic_struct", value: basicStruct)
```

Just like any other type you can obtain the struct by casting the value from the AppSession.

```swift
let myStruct = AppSession.get("basic_struct") as? BasicStruct
```

Classes, being reference types are a bit different in that AppSession does not create a separate copy of your class.

__If you update the value of the object outside the session its changes will update the shared reference in the AppSession.__

```swift
/* WARNING: Storing reference types within AppSession could lead to accidental state changes */
class BasicClass {
    var prop: Int

    init(prop: Int) {
        self.prop = prop
    }

    func method() -> String {
        return String(self.prop)
    }
}
```

Update the class by setting a property value.

```swift
let basicClass: BasicClass? = BasicClass(prop: 42)

// Store the class in the session
AppSession.set("basic_class", value: basicClass)
```

Now outside of the session we set the prop again.

```swift
basicClass?.prop = 777
```

Once you get the class from the session it will have the updated value.

```swift
let basicClassFromSession = AppSession.get("basic_class") as? BasicClass

assert(basicClass?.prop == basicClassFromSession?.prop)
```

Always be cautious about storing reference types in AppSession.

# Misc Usage

Some of the other methods include the following:

## Count

Count returns the number of *keys* within AppSession.

```swift
AppSession.count
```

## Keys

Keys will return a __Set__ of all the keys

```swift
AppSession.keys
```

## Clear

Completely wipes the entire AppSession.

```swift
AppSession.clear()
```

## Contains

Returns *true* if the given key exists in the current AppSession

```swift
AppSession.contains("some_key")
// This is equivalent to
AppSession.keys.contains("some_key".lowercaseString)
```

# Why AppSession?
AppSession was created due to my frustrations with existing tools that either needed to access the disk for caching,
required modifying my code to implement some strange Protocol(s) and or couldn't handle storing reference types.
So during the creation/debugging of one of my SpriteKit games I started building a class that let me initialize a SKScene
based on any arbitrary game data; I extracted the code from my game and re-named it AppSession.

## What AppSession Is Not
* A replacment for Core Data
* A replacement for Realm
* A replacement for NSKeyedArchiver
* A replacement for NSUserDefaults
* A cache

## What AppSession Is
* A simple place to store data in-between SKScene/ViewController segues
* A tool to assist decoupling your ViewControllers/SKScenes
* A tool to help you stop using unecessary static global values in your app (oh the irony... but yes now you can revert them to structs and just keep them around in AppSession)
* A way to help cut down on firing NSNotifications that simply update data

# License

AppSession is available under the MIT license. See the LICENSE file for more info.

