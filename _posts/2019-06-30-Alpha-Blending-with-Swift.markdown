---
layout: post
title:  "Alpha Blending With Swift"
date:   2019-06-30 09:00:00
categories: developer swift swiftui alpha blending 
---

I recently came across some code I wrote a few months ago. I left no documentation, and could not figure out what it was doing. After a bit of banging my head against the wall, I was able to finally figure out what it was doing and why.

I needed set the color of a view to match the color of a TabBar on the page. This was a little bit more involved than just setting the color of my view to the `tintcolor` of the TabBar, because the TabBar was semi transparent, and blended with the white background color. This caused the user to see a much lighter color on by TabBar than they did in my view.

I could have hardcoded the new matching color, but I wanted to compute the value incase we changed the color of the TabBar.

This meant I had to programaticly alpha blend my color with the background to find the proper color for my view. This is accomplished with a pretty simple formula:

```
New Color = MyColor * Alpha + Background*(1 - Alpha)
```

Where:
- MyColor is the TabBar tintColor 
- Background is the background color, and can be any color 
- Alpha is the Opacity of the TabBar. 

*In my project, I found that the Alpha value for the TabBar was `0.850000023841858`*

Here is some simple sample code to do this in Swift 5 and Swift UI. This isn't the code from the original project, but a simplified version to show the algorithm:

```swift
// Compute the source color
let source = UIColor(hue: CGFloat(hue),
                     saturation: 0.75,
                     brightness: 1.0,
                     alpha: 1.0)

// Get RGB Values for the source color
let (red, green, blue) = source.rgb

// Get the Background Color out of the assets
// There must be a better way to do this in SwiftUI
let bkgColor = UIColor(named: "backgroundColor") ?? UIColor.white

// Get RGB Values for the background color
// These values will all be 1.0 if you only have a white background.
let (bkgRed, bkgGreen, bkgBlue) = bkgColor.rgb

// Compute the inverse alpha for convenience.
let inverseAlpha = 1.0 - alpha

// Do The Math, and return the new Color
return Color(red: red * alpha + bkgRed * inverseAlpha,
             green: green * alpha + bkgGreen * inverseAlpha,
             blue: blue * alpha + bkgBlue * inverseAlpha)
```
Here is a quick Preview of the app:

<img src="/assets/i/Alpha-Blending-with-Swift.app-preview.png" alt="Cool App Preview" width="250">

I also added a little convenience method in an Extension to UIColor to more easily get the colors:

```swift
var rgb: (red: Double, green: Double, blue: Double) {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0

    self.getRed(&red, green: &green, blue: &blue, alpha: nil)

    return (Double(red), Double(green), Double(blue))
}
```


Project sample for those with Xcode 11 can be found [here!](https://github.com/steg132/alpha-blending)





