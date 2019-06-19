---
layout: post
title:  "HealthKit Changes In iOS 13"
date:   2019-06-19 09:00:00
categories: apple developer healthkit ios13
---

Below is a short list of API changes coming to Apple HealthKit in iOS 13. Apple isn’t bring any major changes to the APIs, but I believe some of the changes do make HealthKit a little easier to work with, and more streamlined for future updates.

This is all part of the iOS 13 Beta, and may change between now and it’s release, probably sometime in September.

## Changes to Health Kit’s Discrete Types

`HKQuantityAggregationStyle` describes the way HealthKit aggregates a series of quantitative data, either as cumulative sums or discrete means.

In iOS 13, HealthKit has “expanded” their data representations by deprecating the `.discrete` case in the `HKQuantityAggregationStyle` enum, and adding more descriptive types:
- `.cumulative`: This remains unchanged and simply produces the sum of the values represented by a quantity sample. Use this aggregation style to get sum of samples in your Quantity Sample or Statistics Query, like steps, calories, and flights climbed.
- `.discreteArithmetic`: This will largely replace the newly deprecated `.discrete` case. This aggregation style takes a mean of samples in your Quantity Sample or Statistics Query. Use this aggregation style for samples like weight.
- `.discreteTemporallyWeighted`: This is used to compute the average for heart rate data.
- `.discreteEquivalentContinuousLevel`: This is a special aggregation style for audio exposure quantities.
 

## New Quantity Sample Subclasses

With iOS 13, `HKQuantitySample` has become an abstract superclass for `HKCumulativeQuantitySample` and `HKDiscreteQuantitySample`. The system will automatically the choose the correct subclass based on the `HKQuantityType`. 

Also of note, all `HKQuantitySample` are now quantity series, even if they are a series of one. With this update, HealthKit has deprecated `HKCumulativeQuantitySeriesSample`, and recommends using `HKCumulativeQuantitySample` instead.

## New Audiograms Samples

Apple has introduced the ability for developers to store the results of hearing tests with iOS 13. For this, they have introduced a few new APIs:

- `HKAudiogramSensitivityPoint`: A hearing sensitivity reading associated with a hearing test. This includes Sensitivity for the Left and Right ears, and frequency. What’s interesting is that the values for each ear are optional, so it appears that developers can include values for only one ear, both, or none in each sample.
- `HKAudiogramSample`: This `HKSample` stores the results of a hearing test and is comprised of data from multiple HKAudiogramSensitivityPoint. 
- `HKUnit.hertz`: This is a new unit used to represent the quantity values for the frequency of the `HKAudiogramSensitivityPoint`.  

## Some New Workouts

What is a new HealthKit release without a few new workouts:
- **Disc Sports**: Ultimate Frisbee enthusiasts rejoice, you can now record your workout in the Quad.
- **Fitness Gaming**: I guess this may encourage more active apps to track user activity in HealthKit. This may be useful for tracking workouts in VR.

