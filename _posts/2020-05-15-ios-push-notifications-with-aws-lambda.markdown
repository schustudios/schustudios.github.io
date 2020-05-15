---
layout: post
title:  "iOS Push Notifications With AWS Lambda"
date:   2020-05-15 9:00:00
categories: ios push notification aws lambda python
---

Push notifications are an important part of modern mobile apps. While there are many services available for incorporating push notifications into our apps, like Firebase and Airship, some products still opt to roll their own push notification services. 

For developers to test and build these integrations quickly, without waiting for changes on backend services, we may need to set up our own small scale service. This way, our team can push to our own development devices. With this service, we can quickly debug our app's responses to push notifications, and test out new features, like deep linking or background updates, without waiting on updates to backend services.

This article will quickly help developers set up an AWS Lambda that will send a push notification to an app signed with the developer or production certificates. This will be accomplished using the [Simple Push][simple-push-repo] service, a small Python module which runs on Amazon Lambda and proxies requests to APNs.

# How It Works

Spin up a Lambda on AWS, and an API Gateway to pass POST requests through to the Lambda. The Lambda will parse the JSON object in the POST body, and build a request to APNs. Finally, the iOS app will receive the notification from APNs. 

This demo uses the following technologies:
- [AWS Lambda][aws_lambda]: Run code without servers
- [AWS API Gateway][api-gateway]: AWS Service lets developers make API calls that can be consumed by AWS Lambda
- [Python][python]: This will be the code running on Lambda that will send the push notification
- [Hyper][hyper]: API for making HTTP requests.
- [Postman][postman]: App that lets us easily send a RESTful call to our new AWS API.


# Building The App
Adding Push Notification Support to an iOS app is simple, easy, and fun!

Developers only need to add the remote notification methods to the app delegate:
- `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`: Called when the device token is available
- `application(_:didFailToRegisterForRemoteNotificationsWithError:)`: Called when there is an error getting the device token
- `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)`: Called when the device receives a push notification. This is where the app can handle any background updates or user action the app will need to perform. 

For this article, I built a very simple example app, which implements background push notifications and support for background alerts. While your app might not need both of these features, the Simple Push service can support them. You do not need to use this example app, and can follow along with the rest of this article as long as you can retrieve the Device Token.

Find the code for the [sample app here][example-ios-repo].

# Get The Certificate

To send push notifications to APNs, a SSL Certificate is needed. Separate certificates are needed for the Production and Development APNs servers. This will enable the service to send push notifications to apps built from XCode, deployed to TestFlight, or purchased from the App Store. 

An identifier for the app will need to be generated in the Apple Developer Portal. One may have been generated automatically. If you are using the Sample App, you will also need to update the app's Bundle Identifer with this new App Identifier.

Once the App Identifier is generated, scroll down to Push Notifications, click configure:
![Apple Push Configure SSL Cert](/assets/i/push/push-ssl-configure.png)

An SSL certificate will need to be generated each server, so you may need to go through the following instructions twice, once for Development, and again for Production.

Tap on the Create Certificate button below, for the certificate we want to generate. 

![Apple Push Notification Service SSL Cert](/assets/i/push/push-ssl-certificates.png)

The page will navigate to the Create A New Certificate page. The file the page is asking for is a Certificate Signing Request. To generate this file, open Keychain Access and create the Certificate Signing Request. You can open Keychain Access from Spotlight, or by opening the app in finder by navigating to Applications -> Utilities -> "Keychain Access.app". 

From there, navigate to Keychain Access -> Certificate Assistant -> "Request a Certificate From a Certificate Authority..." in the top menu bar. 

![Request a Certificate From a Certificate Authority...](/assets/i/push/push-request-cert-from-ca.png)

This will open the Certificate Assistant. Enter your Email Address and the Common name, which will be the name of the Public/Private keypair generated. Here, I set my common name to `pushexample_ssl_dev`. A unique name will make it easier to identify the required keys in the keychain. Select Save to disk, and continue. 

![Certificate Assistant](/assets/i/push/push-certificate-assistant.png)

You will be prompted to save the new Certificate Signing Request. Save the file somewhere you will remember. Go back to the Apple Developer Portal, and upload the new file in the "Create a New Certificate" screen.

![Create a New Certificate](/assets/i/push/push-create-new-certificate.png)

This will create the Certificate, and navigate to the "Download You Certificate" page. Click the download button in the upper right corner, and save the file. It should be named either "aps_development.cer" or "aps_production.cer". 

![Download Your Certificate](/assets/i/push/push-download-certificate.png)

Double click to open the downloaded file in Keychain Access. There will be a new certificate in the login keychain named "Apple Development IOS Push Services: com.schustudios.PushExample", where "com.schustudios.PushExample" is replaced by the bundle identifer set in the Apple Developer Portal.

From the Certificate category in Keychain Access, find the certificate, expand the certificate to show the private key, and select both the Private Key, and the Certificate as pictured below. Right click on the items, and click "Export 2 Items..."

![Export Certificate](/assets/i/push/push-export-cert.png)

Now, save the exported file to a good location, maybe a directory next to the project. Name the file something distinctive, and ensure the File Format is set to "Personal Information Exchange (.p12)" as seen bellow. 

![Save Exported p12](/assets/i/push/push-save-cert.png)


Finally, we need to convert the exported P12 file to a P12 file that the Simple Push service will be able to use when connecting to APNs. From Terminal, run the following command, where `exported.p12` is the file just exported from Keychain Access. Rename `pushcert_dev.p12` to `pushcert_prod.p12` when exporting the Production SSL certificate.

```
openssl pkcs12 -in exported.p12 -out pushcert_dev.p12 -nodes -clcerts
```

For more instructions on how to generate the SSL Certificates, checkout [Apple's Documentation here.][apple-create-certificate-signing-request]

# Launching the Lambda

Now that the SSL Certificates have been generated, it's time to set up the Lambda Service! 

I have a [Simple Push service][simple-push-repo] that kicks off the requests to APNs. But you can also build your own! If you are using python, I recommend the [APNS2][apns2] module. 

With the Simple Push repo, place the Production and Development certificates into the `cert/` directory. Name the Development certificate `pushcert_dev.p12`, and the Production certificate `pushcert_prod.p12`. Run `./package.sh` from the root of the repo, and see that the `function.zip` file was produced. This file contains all of the dependencies, certificates, and the lambda function compressed, and ready to upload to Amazon Lambda. 

In the Browser, navigate to the [Amazon Console][amazon-lambda-console]. You may need to create an Amazon Web Services account. From this page, click on the "Create function" button in the upper right corner. 

On this form, just set a few simple variables:
- Name the function something descriptive like "SimplePush"
- Set the runtime to the Programming Language you are using. The Simple Push example is using Python 3.7.

![Create Function Form](/assets/i/push/push-create-function-form.png)


This will create the Lambda Function, and navigate to a page to manage the function. A simple function has already been provided, but the generated function.zip file needs to be uploaded. Scroll down the page to the Function code section and select "Upload a .zip file" in the dropdown underneath the "Code entry type" option.

Tap the Upload button, and select the generated function.zip file.

![Upload Zip Here](/assets/i/push/push-lambda-upload-zip.png)


# The Final Gateway

Now that the Lambda is created, an API Gateway needs to be created to send the request from Postman or CURL into the Lambda. This is the easiest part. 

At the top of the page on the Lambda page, see the Designer console. From here, click on "+ Add Trigger" under API Gateway. 

![API Gateway Connector](/assets/i/push/push-lambda-api-gateway-connector.png)

The Add Trigger page will appear. Simply select "REST API" under "API type". The default settings for the trigger are fine for the development tool. Just click "Add" at the bottom of the page to add the API Gateway trigger.

![Add Trigger](/assets/i/push/push-lambda-add-trigger.png)

Lastly, navigate to the API Gateway that was just created. Out of the box, the API Gateway that was created with the basic settings will work perfectly fine for this app. All that needs to be done is to Deploy the . Navigate to the Resources from the left pannel, and from the "Actions" dropdown, select Deploy API.

![API Gateway Deploy API](/assets/i/push/push-lambda-deploy-api.png)

A simple Dialog Box pops up. Set the deployment stage to "default", tap the deploy button, and the API will be live!

![API Gateway Deploy Popup](/assets/i/push/push-lambda-final-deploy.png)

At the top of the screen, see the Invoke URL. This is the URL we will post to for sending out test notifications. 

# Bringing It All Together

Finally, it is time to test out the new Lambda, and send the first Push Notification. 

If using the Simple Push example, this is pretty easy. Simple Push has a very lightweight interface, and allows for maximum flexibility in sending messages to APNs. Just build a PUT request to the API Gateway generated above. The Simple Push service basicity takes the values in the JSON request, and uses them to build the URL and the Headers for the APNs request. The Body of the APNs request is taken from the object value of the "apns" key. If used carefully, this is a great tool for testing out different Push Notification formats when working with more experimental Push Notification features.

```
{
    "topic": Usually the Bundle Identifier. Check out the Apple Documentation for details.
    "token_hex": Device identifier notification is being sent.
    "environment": "production" or "development". Sets which Apple API is being hit.
    "apns": This object serves as the body of the APNs request. Fill it out as you would a normal APNs request

    # Optional Values
    "apns-id": A canonical UUID that identifies the notification. If there is an error sending the notification
    "apns-expiration": A UNIX epoch date expressed in seconds (UTC)
    "apns-priority": The priority of the notification.
    "apns-collapse-id": Multiple notifications with the same collapse identifier are displayed to the user as a single notification

}
```
For more Details on the contents of each parameter sent to APNS, see [Apple's Documentation][apple-communicating-with-apns]

A simple POST request can have the following body:

```
{
  "topic": "com.schustudios.PushExample",
  "token_hex": "4177cc6b62437e0943c5b9fd3d5bad8344c80ae7ed38bb429d7bdb26b1a6f042",
  "environment": "development",
  "apns": {
    "aps": {
      "alert": "Test Alert!"
    },
    "acme": "Some Test Metadata"
  }
}
```

 If working with the Test App, it is pretty easy to get the Device Id, and test this flow out! Just update the Topic to the App Identifier of your app, and set the Hex Token to the Device identifer provided by Apple. 

# The End

I hope you enjoyed this quick overview on how to use AWS Lambda to send push notifications to your iOS app. 
AWS is an amazing resource. It allows developers to easily deploy some code that can be shared with their team, or throw up a simple service to support a small customer base. 





[aws_lambda]: https://aws.amazon.com/lambda/
[api-gateway]: https://aws.amazon.com/api-gateway/
[python]: https://www.python.org/
[node-js]: https://nodejs.org/en/
[postman]: https://www.postman.com/
[apns2]: https://www.npmjs.com/package/apns2
[hyper]: https://hyper.readthedocs.io/en/latest/

[example-ios-repo]: https://github.com/schustudios/push-notification-example
[simple-push-repo]: https://github.com/schustudios/SimplePush

[apple-create-certificate-signing-request]: https://help.apple.com/developer-account/#/devbfa00fef7
[apple-developer-portal]: https://developer.apple.com/account
[apple-communicating-with-apns]: https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html#//apple_ref/doc/uid/TP40008194-CH11-SW1

[amazon-lambda-console]: https://console.aws.amazon.com/lambda/home

