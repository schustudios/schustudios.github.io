---
layout: post
title:  "What's In A Git Commit?"
date:   2019-08-03 12:00:00
categories: git commit hash 
---

Git is a very powerful tool, and has become the industry standard for source control. However, many devs don’t have a deep understanding of the most fundamental component of git: The Commit.

## What is a Commit?

A commit is a snapshot of the project. A commit includes:

- The commit author with a timestamp
- The committer with a timestamp 
- A message describing the commit. 
- The hash of the parent commit
- The hash of a tree, containing a hash of every file in the project. This is how the commit stores a snapshot of the project. 

A commit is referred to by its hash. The hash is generated using a SHA-1 hash algorithm with all of the above, plus a NUL terminated header with the word commit, and the length of the commit. 

## Git Objects

Before we can dive into the contents of the git commit, we need to understand how git manages objects. In Git, everything is hashed, and referred to by that hash. There are three types of objects:

- **Commit**:  The subject of this article. 
- **Tree**: This is how git represents directories in a project. Each tree contains a list of git objects, similar to how directories contain a list of files and folders.
- **Blob**: This represents files stored in the Project.   

Git effectively operates as a large key/value store, where any object can be reference by its hash. The contents of these files are stored in the `.git/objects/` directory of your git project by their hash.  

Hashes are used throughout Git to ensue the integrity of data. This will ensure that even though the repository is distributed amongst multiple users, the data on each machine is the same. 

From the Pro Git Book:

> Everything in Git is checksummed before it is stored and is then referred to by that checksum. This means it’s impossible to change the contents of any file or directory without Git knowing about it. This functionality is built into Git at the lowest levels and is integral to its philosophy. You can’t lose information in transit or get file corruption without Git being able to detect it.

## Looking inside a commit

To look at the contents of a commit (or any Git object), we can use the command `git cat-file -p <hash>`. This command prints out the content of a Git Object to the console, and will allow us to see how Git stores and manages objects. In this article, I will use the project found here: [https://github.com/steg132/sample-git](https://github.com/steg132/sample-git)

Off of the master branch, if I run `git cat-file -p HEAD` the details of the commit are printed out to the console:

```
tree 5c6cd40710a49a5790b4c6f9edbcd3dbf9292c53
parent 4d18a74e7a4e31b52624d5cd20fafebab0f34ecc
author Ryan Schumacher <steg132@gmail.com> 1564493077 -0400
committer Ryan Schumacher <steg132@gmail.com> 1564493077 -0400

Adding a new line by Ryan
```

### Tree

The first item printed out in the commit is the hash of the tree. 

```
tree 5c6cd40710a49a5790b4c6f9edbcd3dbf9292c53
```

This tree represents the root directory of the project. Running `git cat-file -p 5c6cd40710a49a5790b4c6f9edbcd3dbf9292c53` will print out the list of files at the root of the project directory that are being tracked by git:

```
100644 blob f2e765815731d0e3c6cd5e6ab98c52b2499f022a	README.md
100755 blob 0ac8e680aa29c7991137e58a6e07c2bbe9c4feee	say.sh
```

The hash of the tree is generated from the contents of this list. So, since objects are hashed from their content, you can see how changing anything in the tree will cause the hash of the tree to change. This behavior is how git is able to verify the contents of each object and commit in the Git repository.

You can generate the hash of the Tree itself by running the following command:

```bash
(printf "tree %s\0" $(git cat-file tree 5c6cd40710a49a5790b4c6f9edbcd3dbf9292c53 | wc -c); git cat-file tree 5c6cd40710a49a5790b4c6f9edbcd3dbf9292c53) | sha1sum
```

Or the hash of a file with the following command. Just replace `README.md` with whatever file you wish to hash.

```bash
(printf "blob %s\0" $(cat README.md | wc -c); cat README.md) | sha1sum
```

As a result of this, if you have duplicates of files in your project directory, git will only store one copy of that file in its database. Take a look at the tree of the `duplicate-files` branch. In this branch `README.md` and `README-2.md` are exact duplicates of each other. `git cat-file -p 5c431147977781d65e9c500dadbf3dca05eaaf92`

```bash
$ git cat-file -p 5c431147977781d65e9c500dadbf3dca05eaaf92
100644 blob f2e765815731d0e3c6cd5e6ab98c52b2499f022a	README-2.md
100644 blob f2e765815731d0e3c6cd5e6ab98c52b2499f022a	README.md
100755 blob 0ac8e680aa29c7991137e58a6e07c2bbe9c4feee	say.sh
```

### Parent

The next line listed in the git commit is:

```bash
parent 4d18a74e7a4e31b52624d5cd20fafebab0f34ecc
```

This is a hash of the previous commit in the current branch's history. This makes git commits work as a singly linked list, where every commit points only to the previous commit.

This continues to reinforce the security of git by verifying the hash of the entire history of your current git branch. 

If you run `git cat-file -p 4d18a74e7a4e31b52624d5cd20fafebab0f34ecc` you will see the contents of that commit, and notice that the `parent` line is missing. This is because it is the first commit in the repository. 

```
tree f93e3a1a1525fb5b91020da86e44810c87a2d7bc
author Ryan Schumacher <steg132@gmail.com> 1564452766 -0400
committer Ryan Schumacher <steg132@gmail.com> 1564452766 -0400

Initial Commit
```

 

### Author and Committer

```
author Ryan Schumacher <steg132@gmail.com> 1564493077 -0400
committer Ryan Schumacher <steg132@gmail.com> 1564493077 -0400
```

These last two lines in the commit can be a little bit unintuitive. 

The author is the original author of the commit, while the committer is the last person to change the commit. Each line ends in a unix timestamp, and the timezone for that commit. These values usually stay the same, and only change when developer cherry-pick commits or rebase their branches.

Take a look at the `author-committer` branch. This branch has two additional commits which were cherry picked  from the `original-author-committer` so that the second commit appears in the git history before the first commit.

```
commit 6936b157c16009e40f91b6ecec7805492bf18f40 (HEAD -> author-committer)
Author: Ryan Schumacher <steg132@gmail.com>
Date:   Wed Jul 31 23:32:05 2019 -0400

    Adding a new line by Ryan

commit 7668f81c07099a4f6803d1370aa0484dd1ae3039
Author: Ryan Schumacher <steg132@gmail.com>
Date:   Wed Jul 31 23:33:10 2019 -0400

    Adding Another file!

commit 638c7a6f284b9a01b29a8f67090eabddaa58f5c2 (master)
Author: Ryan Schumacher <steg132@gmail.com>
Date:   Tue Jul 30 09:24:37 2019 -0400

    Adding content to repository

commit 4d18a74e7a4e31b52624d5cd20fafebab0f34ecc
Author: Ryan Schumacher <steg132@gmail.com>
Date:   Mon Jul 29 22:12:46 2019 -0400

    Initial Commit
```

You might figure that despite the `author-committer` branch, and the `original-author-committer` brach pointing to two different commits, they should have the same contents. Because of that, the tree listed in both of those commits is the same hash. 

## Final Commit

Git is such a powerful tool, and it is instrumental in our everyday workflow. While many Git GUIs like Source Tree and the Git integrations in many IDSs abstract us away from the underlying mechanisms of git, it is important to think about how git works. This will help ensure we are always using the tool to its maximum benefit.

### Sources:

[Git Manual](https://git-scm.com/book/en/v2): Available for free on the Git website. Written by Scott Chacon and Ben Straub 

[Explanation.md](https://gist.github.com/masak/2415865)