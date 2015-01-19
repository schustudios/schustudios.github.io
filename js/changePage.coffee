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
			updateChangePage $(".page-content a")
			# Update the title
			document.title = response.match("<title>(.*?)</title>")[1]
			# Hide the loading bar
			$('#load').fadeOut 'fast'
			# show the new page content
			$('.page-content,.site-footer').fadeIn 'fast'
		)
	# show loading bar while the content loads
	$('#load').fadeIn 'fast'


updateChangePage = (a)-> 
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
	false

$ ->
	# Log when the page is loaded
	console.log new Date().toString()

	# Bind all links to the changepage function except rel=external
	updateChangePage $("a[rel!='external']")

	# Bind "popstate", it is the browsers back and forward
	window.onpopstate = (e) ->
		changePage document.location, false, null

# Helper Methods
String::startsWith ?= (s) -> @[...s.length] is s
String::endsWith   ?= (s) -> s is '' or @[-s.length..] is s