---
layout: post
title:  "iOS Push Notifictions With AWS Lambda"
date:   2020-04-25 9:00:00
categories: ios push notification aws lambda node.js
---

Push notificaitons are an important part of modern mobile apps. While there are many services available for incorporating Push Notifcations into our apps, like Firebase and Airship, some products still opt to roll their own Push Notification Services. For developers to test and build these integrations quickly, without waiting for changes on backend services, we may need to set up our own small scale service, where we can push to our own development devices. With this service, we can quickly debug our app's responses to push notifications, and test out new features, like deeplinking, without waiting on updates to backend services.

This article will quickly help developers set up Lambda that will send a push notification to a app signed with the developer certificate with the following technologies:
- [AWS Lambda][aws_lambda]: Run code without servers
- [AWS API Gateway][api-gateway]: AWS Service lets developers make API calls that can be consumed by AWS Lambda
- [Node.js][node-js]: This will be the code running on Lambda that will send the push notification
- [APNS2][apns2]: Node Package which will make the request to Apple Push Notification Service (APNS)
- [Postman][postman]: App that lets us easily send a restfull call to our new AWS API







[aws_lambda]: https://aws.amazon.com/lambda/
[api-gateway]: https://aws.amazon.com/api-gateway/
[node-js]: https://nodejs.org/en/
[postman]: https://www.postman.com/
[apns2]: https://www.npmjs.com/package/apns2