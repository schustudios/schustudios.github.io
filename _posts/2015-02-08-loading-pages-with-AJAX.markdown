---
layout: post
title:  "Loading Pages with AJAX"
date: 	2015-02-08 17:10:00
categories: jekyll AJAX JQuery load 
---

Modern websites not only need to look good, but they need to be responsive and have smooth page transitions, even in unfavorable enviornments. To impliment this feature of modern web design on my new blog, I used a pretty convienient method provided by JQuery: `load(url[, data][, complete])`. This method loads data from the url, and loads the returned HTML into the invoking element([docs][jquery_load_doc]).


Starting With JQuery
===============

To get started, I needed to add JQuery to my site. I decided to use the lib hosted by [Google][google_hosted_libs] over hosting the library myself on Github Pages because of the increased to page load speed for the following reasons:

- Users who have visited pages that also use the JQuery library hosted by Google will have the script cached by their browser.
- Github Pages can be very slow, and it may take users a long time to download the 84 KB minified JQuery library.

(Plus, I don't want to clutter up my repo with JQuery releases!)

Adding JQuery from [Google Hosted Libraries][google_hosted_libs] can be done by adding the following line to the head block in `_includes\head.html`:

`<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>`

Update the Layout
=====

In my default layout, I add a “load” div at the top of the body. This div will display an animation icon, fade in, and fade out after the page has loaded. The animations are handled by JQuery later on in the code, and the image, and other visual settings are set in the site’s scss.

In my “main.scss”, I add a section to that initially hides the icon (`display: none`), sets the image, and centers the image in the page:

	#load {
	  display: none;
	  position: fixed;
	  background: url({{site.image_path}}loader.gif);
	  width: 24px;
	  height: 24px;
	  text-indent: -9999em;
	  top: 50%;
	  left: 50%;
	  margin-top: -12px;
	  margin-left: -12px;
	  transform: scale(2);
	}



And Now to the Fun Part
====================

Next, I added some logic to the page that will do the following:

1. Update internal links to load directly into the current page.
1. Update the browser history, so users can go back to previous pages.
1. Add a smooth transition between pages.

I start by adding a “load” event handler to the page. It starts by logging the current time, marking when the page was last loaded. Next, it calls the `updateClick` method on all the \<a\> tags in the page. This method updates the click event of the provided elements to call `changePage`, if the link is internal. The last thing I do is add an event handler to the `popstate` event, to catch when the user clicks the back button, and use the `changePage` method to load the previous page.

	window.onload = ->
	     # Log when the page is loaded
	     console.log new Date().toString()

	     # Bind all links to the changepage function except rel=external
	     updateClick $("a")

	     # Bind "popstate", it is the browsers back and forward
	     window.onpopstate = (e) ->
	          changePage document.location, false, null


The next couple methods, `updateClick` and `isInternalLink`, update the page so that I don’t have to manually change every link to call a my custom click event. The `updateClick` method takes an element from the page, and adds my ‘click’ event listener. I do a little browser compatibility check; in Firefox, `e` is null, and the actual event can be found in `window.event`. The listener checks if the link is internal, and if so, calls the change page method. 

	# Updates the click event of the provided element
	# to call changePage, if it is an internal link
	updateClick = (a)->
	     a.on("click", (e) ->
	          # Browser compatibility
	          e = e || window.event
	          # check if this is an internal link
	          if isInternalLink this.href 
	               # Load the href and add to our history
	               changePage $(this).attr("href"),true,e)

	# Checks if the provided link is internal,
	# and is a kind of link we want to load.
	# Currently ignores '.xml' files
	isInternalLink = (url) ->
	     # Ignore XML files
	     if url.endsWith ".xml" then return false
	    
	     # build a parser
	     # Idea from: https://gist.github.com/jlong/2428561
	     parser = document.createElement 'a'
	     parser.href = url

	     # check if the url links to our own origin
	     if parser.host == document.location.host then return true
	    
	     # default to false
	     return false


Finally, I have the `changePage` method which takes three arguments; the URL of the page we are going to, a bool to indicate wether to push this url into the page history, and the default event, to be called if the change page method cannot complete. I start by checking if history is supported, bail out if it isn’t, and prevent the default event from firing. Next, I push the state into the browser history, if we are supposed to. I add a little custom data to the page, and make sure that the Title is used to denote the page in the browser history.

The real magic of the mage happens at the end of this method, with a little help from JQuery. It starts by fading out the “.page-content” and “.site-footer”. On completion, I call `load` on the page content div, and fadein the loading div. Notice that I modify the url passed into the method; `url + " .page-content > *”`. This tells Jquery to download the url, but only load the *content* of the “.page-content” div into my current page content div, as opposed to the whole page, or the content div its self. I don’t want recursive divs :) After the load is complete, I update all the link tags in the newly loaded content with the `updateClick` method. Next, I do a little Regex to grab the page title. Finally, I fade out my loading div, and fade in my page content.

	# Called when loading an internal link
	# Adds new page to the browser history
	# and loads the content of the new page
	changePage = (url, doPushState, defaultEvent) ->
	     console.log "*** Change Page ***"
	     console.log "window.location:" + window.location.href
	     console.log "url:" + url
	     console.log "doPushState:" + doPushState

	     # check if history is supported
	     if !history.pushState then return true # Bail Out

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


Conclusion
=====

The code detailed above has not been extensivly tested, but works great in current versions of Google Chrome, Firefox, and Safari, and does not do anything in Internet Explorer. Linking to anchors is also not supported by the above code, and I am sure a few other <del>bugs</del> features may exist in the code as well.

I will keep this post updated with any other updates I make to the code. 

Thanks for reading, and I will see you soon!



[jquery_load_doc]: http://api.jquery.com/load/
[google_hosted_libs]: https://developers.google.com/speed/libraries/devguide
