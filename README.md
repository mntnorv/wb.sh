wb.sh
=====

A user-friendly wallbase.cc image download script using curl

Features
========

- Ability to choose these search options:
	- Sort by
	- Sort order
	- Purity
	- Boards
- Search by color
- Unlimited image downloads
- Download NSFW content (login required)
- Ignore list (ignore certain images)
- Only get URLs and save them to a file

Options
=======

Login
-----

**USER, PASS**
wallbase.cc username and password for operations that require login (eg. downloading NSFW content)

Download options
----------------

**DIR** directory to download images to

**REMOVE_OLD** option to remove all images from DIR

Accepted values:
 - *1* removes all *.jpg and *.png images from DIR
 - *0* leaves all images in DIR