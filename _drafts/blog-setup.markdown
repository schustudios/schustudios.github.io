---
layout: post
title:  "Setting up my Jekyll site on Github Pages"
date: 	2015-01-12 22:00:00
categories: jekyll setup git github pages
---

So, I have just launched my Jekyll site Github Pages, and have decided to make my first post about the process. Untimately, it was a pretty easy setup, but there were a few gotchas that I ran into, like switching my domain from Amazon, and a few configuration pitfalls on my part. 

Install Dependencies
--------------------

Before you begin, make sure you have the following tools installed on your system:

*	[Ruby][get-ruby]
*	[RubyGems][get-rubygems]
*	[Git][get-git] ([or use a GUI][get-gitgui])
*	[Node.js][get-node]
* On OSX, make sure you have installed Command Line Tools

Next, install the Github-Pages Ruby Gem with the following command:

`$ gem install github-pages`

Create The Repo
-------------

On your Github account, [create a new repository][git-new]. Name the repository *owner*.github.io, where *owner* is either your username, or the organization name on Github.

Now clone the newly created repository. From the Terminal, enter:

`$ git clone https://github.com/username/username.github.io`

Now that you have the repository setup, it's time to...

Set Up Jekyll
-------------

In your new repository folder, create a new blog:

~~~~~
$ cd username.github.io
$ jekyll new .
~~~~~

Checkout your brand new Jekyll blog by running `$ jekyll serve`, and opening [127.0.0.1:4000][jekyll-dev]

At this point, if you run `git status`, you should see a long list of files waiting to be added to the repo. Before doing that, I suggest you update your .gitignore using [Gitignore.io][gitignore]. The following command should download a .gitignore file appropriate for your basic install. Feel free to add languages/platforms/tools your are currently using:

`$ wget -O .gitignore "https://www.gitignore.io/api/jekyll,osx,linux,windows,vim"`

You can now commit all of your files, and push those changes to Github. After about 30 minutes, when you go to *owner*.github.io, you will see your new Jekyll blog.

You can now start customizing you blog, adding templates, and writing posts. When new commits are push to the remote repo, they should be reflected on your website within a few seconds.

Setting A Custom Domain
------------

If you want to give your new site a custom domain, you have two choices: 

* Use a subdomain, like http://blog.example.com
* Use an apex domain, like http://example.com

To configure either custom domains, you will need to login to your DNS provider.

### Configuring A Subdomain



[//]:# (Install links)

[get-git]: http://git-scm.com/book/en/v2/Getting-Started-Installing-Git
[get-gitgui]: http://git-scm.com/downloads
[get-ruby]: https://www.ruby-lang.org/en/documentation/installation/
[get-rubygems]: https://rubygems.org/pages/download
[get-node]: http://nodejs.org/
[get-bundler]: http://bundler.io/
[get-jekyll]: http://jekyllrb.com/

[gitignore]: https://www.gitignore.io/

[git-new]: https://github.com/new

[//]: # (Link to localhost)

[jekyll-dev]: http://127.0.0.1:4000
