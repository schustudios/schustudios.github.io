---
layout: post
title:  "Loading Pages with AJAX"
date: 	2015-01-17 19:40:00
categories: jekyll AJAX JQuery load 
---

Modern websites not only need to look good, but they need to be responsive and have smooth page transitions, even in unfavorable enviornments. To impliment this feature of modern web design on my new blog, I used a pretty convienient method provided by JQuery: `load(url[, data][, complete])`. This method loads data from the url, and loads the returned HTML into the invoking element([docs][jquery_load_doc]).


Starting With JQuery
====================

To get started, I needed to add JQuery to my site. I decided to use the lib hosted by [Google][google_hosted_libs] over hosting the library myself on Github Pages because of the increased to page load speed for the following reasons:

- Users who have visited pages that also use the JQuery library hosted by Google will have the script cached by their browser.
- Github Pages can be very slow, and it may take users a long time to download the 84 KB minified JQuery library.

(Plus, I don't want to clutter up my repo with JQuery releases!)

Adding JQuery from [Google Hosted Libraries][google_hosted_libs] can be done by adding the following line to `_includes\head.html`:

`<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>`

And Now to the CoffeeScript
====================

Next, I added some logic to the page that will allow me to handle page transitions between internal links. Because I don’t want to go through every file, and change every single internal link on my site to call my load method, so I will need to add function to the page that updates the Click event on ‘a’ tags at runtime.

Let’s look at the following code:

	$ ->
		# Log when the page is loaded
		console.log new Date().toString()

		# Bind all links to the changepage function except rel=external
		updateClick $("a[rel!='external']")

		# Bind "popstate", it is the browsers back and forward
		window.onpopstate = (e) ->
			changePage document.location, false, null


	changePage = (url, doPushState, defaultEvent) ->

		# check if history is supported
		if !history.pushState then return true

		# Stop default event from executing
		if defaultEvent? then defaultEvent.preventDefault()

		# Update the page history
		if doPushState 
			history.pushState {type: "custom", uid: 199}, "Title", url

		# Hide the current page content
		$(".page-content,.site-footer").fadeOut 'fast', () ->
			# load the new content
			$(".page-content").load(url + " .page-content > *", (response) ->
				updateClick $(".page-content a")
				# Update the title
				document.title = response.match("<title>(.*?)</title>")[1]
				# Hide the loading bar
				$('#load').fadeOut 'fast'
				# show the new page content
				$('.page-content,.site-footer').fadeIn 'fast'
			)
		# show loading bar while the content loads
		$('#load').fadeIn 'fast'


	updateClick = (a)-> 
		a.on("click", (e) -> 
			# check if this is an internal link
			if isInternalLink this.href  
				# Load the href and add to our history
				changePage $(this).attr("href"),true,e)

	isInternalLink = (url) ->
		# Ignore XML files
		if url.endsWith ".xml" then return false
		
		# check if the url links to our own origin
		if url.startsWith document.location.origin then return true
		
		# default to false
		return false


	# Helper Methods
	String::startsWith ?= (s) -> @[...s.length] is s
	String::endsWith   ?= (s) -> s is '' or @[-s.length..] is s





[jquery_load_doc]: http://api.jquery.com/load/
[google_hosted_libs]: https://developers.google.com/speed/libraries/devguide


