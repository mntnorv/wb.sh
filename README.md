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

**USER, PASS**:
wallbase.cc username and password for operations that require login (eg. downloading NSFW content)

Download options
----------------

**DIR**:
directory to download images to

**REMOVE_OLD**:
option to remove all images from DIR
- `1` - removes all *.jpg and *.png images from DIR
- `0` - leaves all images in DIR

**DOWNLOAD**:
option to download or only get image URLs
- `1` - downloads images according to options
- `0` - only gets images links and saves them to "imgs.txt"

Search options
--------------

**TYPE**:
search type
- `search` - normal search (string)
- `color` - search by dominating color

**QUERY**:
the string to search for when `TYPE=search`

**COLOR_R, COLOR_G, COLOR_B**:
R G B components of the search color when `TYPE=color`. Accepted values: `0 - 255`

**PURITY**:
image purity
- `100` - SFW
- `010` - Sketchy
- `001` - NSFW

These values can be combined. For example:
- `110` - SFW and Sketchy

**BOARDS**:
wallbase.cc boards to search in
- `1` - Anime / Manga
- `2` - Wallpapers / General
- `3` - High Resolution

These values can be combined. For example:
- `12` - Anime / Manga and Wallpapers / General

**SORT_BY**:
- `date` - sort by date
- `views` - sort by view counts
- `favs` - sort by favorite counts
- `relevance` - sort by relevance

**SORT_ORDER**:
- `asc` - ascending
- `desc` - descending

**IMGS_PER_PAGE**:
images per page. Accepted values: `20`, `32`, `40`, `60`

**TOTAL_IMGS**:
total number of images to download. Should be a multiple of `IMGS_PER_PAGE`