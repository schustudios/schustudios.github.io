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

	# load the new content
	$("#page-content").load(url + " #page-content > *", ->
		updateChangePage $("#page-content a")

		)

updateChangePage = (a)-> 
	a.on("click", (e) -> 
			# check if this is an internal link
			if isInternalLink this.href  
				changePage $(this).attr("href"),true,e)



isInternalLink = (url) ->
	if url.endsWith ".xml" then return false
	if url.startsWith document.location.origin then return true
	false

$ ->
	console.log new Date().toString()

	# Bind all links to the changepage function except rel=external
	updateChangePage $("a[rel!='external']")

	# Bind "popstate", it is the browsers back and forward
	window.onpopstate = (e) ->
		#if e.state?
		changePage document.location, false, null

	# Save state on load
	# history.pushState {type: "custom"}, "Title", document.location.toString()


