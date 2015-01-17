---
layout: post
title:  "Setting up my Jekyll site on Github Pages"
date: 	2015-01-16 00:21:00
categories: jekyll setup git github pages
---

![Jekyll](/assets/i/jekyll.png)

So, I have just launched my Jekyll site on Github Pages, and decided to make my first post about the process. Untimately, it was a pretty easy setup, but there were a few gotchas that I ran into, like switching my domain from Amazon, and a few configuration pitfalls on my part. 

Below is the process I went through to get my website set up. If you are looking for a step-by-step guyde to setting up a Jekyll blog on Github Pages, there are a few exelent ones found all over the internet, but feel free to follow along.

Install Dependencies
--------------------

Before I began, I had the following software installed on OSX:

*	[Ruby][get-ruby] I am running 1.9.3, but 2.x.x should work as well
*	[RubyGems][get-rubygems]
*	[Git][get-git] (or [use a GUI][get-gitgui])
*	[Node.js][get-node]
* On OSX, make sure you have installed Command Line Tools

I also installed the `github-pages` gem. It contains Jekyll and a bunch of other usefull dependencies.

Create The Repo
-------------

On Github, I created a new organization named ["SchuStudios"][schustudios-git]. On my Github account, I went to [create a new repository][git-new], selected my new organization and named the new repository schustudios.github.io. The first word in your repository must mach the *owner* account it was created under. E.g. http://github.com/owner/owner.github.io

Now, I can clone my newly created repository, and begin adding content!

Setting Up Jekyll
-------------

In my new repo, I initialized a Jekyll blog with the following command:

~~~~~
$ jekyll new .
~~~~~

This creates a skeleton Jekyll instance that will serve as the basis for my blog. You can preview your new Jekyll blog by running `$ jekyll serve`, and opening [127.0.0.1:4000][jekyll-dev]

At this point, if you run `git status`, you should see a long list of files waiting to be added to the repo. Before doing that, I suggest you update your .gitignore using the [Gitignore.io][gitignore] API. The following command will download a .gitignore file appropriate for your basic install. Feel free to add languages/platforms/tools your are currently using:

`$ wget -O .gitignore "https://www.gitignore.io/api/jekyll,osx,linux,windows,vim"`

You can now commit all of your files, and push those changes to Github. After about 30 minutes, when you go to *owner*.github.io, you will see your new Jekyll blog.

I can now start customizing you blog, adding templates, and writing posts. When new commits are push to the remote repo, they should be reflected on my website within a few seconds.

Setting A Custom Domain
------------

When I started this site, my domain was pointing at an AWS micro-instance. I wanted to transfer that domain to be used for this site. To give my new site a custom apex domain, I went to my DNS (GoDaddy), removed the existing Host records, and (CNAME) Alias recorde. 

Next, I created two host records for my domain, pointing to:

* 192.30.252.153
* 192.30.252.154

I also added an Alias entry that points www.schustudios.com to my Github Pages domain, SchuStudios.github.io.

![On GoDaddy, your Dashboard should look something like this...](/assets/i/blog-setup-00.png)

With these two changes, http://www.schustudios.com and http://schustudios.com now both point to the Github pages, but there is still one step left.

In my repository, I added a new file, CNAME (all caps) to the root of the directory, containing only the custom domain of my blog: `schustudios.com`

With this entry in my repo, pushed to the remote server, Github Pages now serves my blog to http://schustudios.com and recdirects http://www.schustudios.com to the former Domain. These changes may take about an hour to propagate.


Basic Jekyll Configurations
------------

Now that I have my pretty, new domain setup for my blog, I can update the Jekyll settings to use that domain.

It's time to open `_config.yml`, found in the root of my repository. I went ahead and updated the default settings on this page to give the site a little more information about me, like my name, email, twitter, etc.

I changed the URL to "http://schustudios.com". I also added the permalink settings. I didn't really like the default permalink setting for the blog posts, which is normaly something like "/category/otherCategory/2015/01/16/myTitle.html". It is too long for my tastes. I wanted something short, and concise, like "/blog/myTitle". To get that path, set `permalink: /blog/:title`.

For more information on setting your blog's permalink, check it out on the [Jekyll documentation][jekyll-permalink].  

Over So Soon?
---

I will keep posting about updates that I make to the site. Hopefully, that should give me more than a few posts worth of content.

See you soon!



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
[schustudios-git]: http://github.com/schustudios
[jekyll-permalink]: http://jekyllrb.com/docs/permalinks/