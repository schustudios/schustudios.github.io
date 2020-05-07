---
layout: post
title:  "Git Worktree"
date:   2020-04-10 9:00:00
categories: git worktree commit development tools
---

Hey Nerds!

Today, I want to share with you the good word about Git Worktree, the solution to so many of our daily problems.

## The Problems

As a lead developer on a large project, I often find myself being called to take on a variety of tasks throughout the day. Sometimes, I need to take a look at a Pull Request on Github. Other times there is a nasty bug in someone's code that we can't quite figure out. And when working on my own work, I sometimes like to refer to other versions of the project, especially when working on a complicated regression bug. 

With all this work, it is difficult to constantly keep switching branches throughout the day. I can stash the work I have, and checkout another branch easily enough, but all that stashing and branching can be a complicated mess. 

_WHAT EVER CAN I DO?_

![WHAT EVER CAN I DO?](/assets/i/car-wash.gif){: style="display: block;margin-left: auto;margin-right: auto;"}

## The Solution

Git Worktree is a fantastic tool that any developer working with git on a regular basis needs to keep in their back pocket. Git Worktree allows developers to manage multiple working trees at a time. This lets developers checkout different branches, tags, or commits into directories outside you main working tree.

While the Git Worktrees exist in different directories, they all still refer to the same Git Database. This means making new commits from a worktree, fetching the latest changes from remote repository, or adding new branched to your local repository will be reflected in other worktrees. Plus, you don't need to have multiple copies of the the entire repository taking up space on your hard drive.

# What is a Working Tree?

Glad you asked. In Git, there is an object called a Tree. A Tree is how git represents Directories in the database. Each Tree contain a list of git objects, similar to how a directory contains a list of files and folders. The Working Tree, or Working Directory, refers to the Tree of the currently checked out commit, which has all of it's objects pulled out of the Git Database, and decompressed into your directory.

## Working with Worktree

Let's say your Lead Developer hits you up on Teams, and asks you to take a look at a Pull Request. Obviously, you hate the guy. And you are in the middle of some pretty complicated work. And you don't really want to commit what you have just yet. 

No Problem!

To check out the branch into a new Worktree, you can run the command `git worktree add <path> <branch>`. This will checkout `<branch>` into the directory at `<path>`. Make sure that `<path>` is not an existing directory containing file. Now, you should see a new directory with the contents of `<branch>` freshly checked out. Make sure to run any project initialization steps, like initializing submodules or installing pods, just like you would if you had just pulled the repository down onto a new computer. 

Once you are done with the worktree, you can run `git worktree remove <path>`, and git will delete the directory, and all of its contents. If you delete the directory yourself, you can also run `git worktree prune` to remove the linked worktrees in directories that no longer exist. 

To see a list of all the current worktrees, run `git worktree list`. This will print out a list of the current worktrees, the commit, and the branch currenlty checked out on each worktree. It is important to remember that you cannot checkout the same branch into multiple worktrees. 

In my daily workflow, I keep 3 worktrees active on my computer:
- One with the latest on Develop
- One with the branch of my latest work
- One which I use to checkout Pull Requests, or other developer's work

Check out the documentation on [Git Worktree here!](https://git-scm.com/docs/git-worktree)

# In Conclusion

As developers, it is important to have the best tools at our disposal. Since Git has become a part of just about every developer's workflow, it is important to use it as best we can. Git Worktree has become a valuable part of the way I use git every day, and I hope you find a way to incorporate this tool, and make your life a little easier. 

Have a good day, and don't forget to Git Gud!
