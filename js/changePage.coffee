---
---

# loadlink.coffee
#
# This file enables loaded pages to load the content of 
# the internal link they click into the page, instead 
# of loading a new page.
#
# Inspired by:
# http://stackoverflow.com/questions/8202719/lifehacker-implemention-of-url-change-with-ajax

window.onload = -> 
	# Log when the page is loaded
	console.log new Date().toString()

	# Bind all links to the changepage function except rel=external
	updateClick $("a")

	# Bind "popstate", it is the browsers back and forward
	window.onpopstate = (e) ->
		changePage document.location, false, null

	# disable bfcache
	window.addEventListener 'unload', (e) ->
	  console.log 'unload'


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

# Updates the click event of the provided element
# to call changePage, if it is an internal link
updateClick = (a)-> 
	a.on("click", (e) -> 
		e = e || window.event
		# check if this is an internal link
		if isInternalLink this.href  
			# Load the href and add to our history
			changePage $(this).attr("href"),true,e)

# Called when loading an internal link
# Adds new page to the browser history
# and loads the content of the new page
changePage = (url, doPushState, defaultEvent) ->
	console.log "*** Change Page ***"
	console.log "window.location:" + window.location.href
	console.log "url:" + url
	console.log "doPushState:" + doPushState

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



# Helper Methods
String::startsWith ?= (s) -> @[...s.length] is s
String::endsWith   ?= (s) -> s is '' or @[-s.length..] is s
