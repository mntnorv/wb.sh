#####################
###     LOGIN     ###
#####################

===   USER, PASS  ===
wallbase.cc username and password for operations that
require login (eg. downloading NSFW content)

#####################
###    DOWNLOAD   ###
###    OPTIONS    ###
#####################

===      DIR      ===
Directory to download images to

===   REMOVE_OLD  ===
Accepted values:
	1 - removes all *.jpg and *.png images from DIR
	0 - leaves all images in DIR

===    DOWNLOAD   ===
Accepted values:
	1 - downloads images accorting to options
	0 - only gets images links and saves them to "imgs.txt"

#####################
###    SEARCH     ###
###    OPTIONS    ###
#####################

===     TYPE      ===
Choose search type.
Available search types:
	search - normal search, searching by specified string
	color  - search by dominating color

===     QUERY     ===
The string to search for when TYPE=search

===    COLOR_R    ===
===    COLOR_G    ===
===    COLOR_B    ===
R G B components of the search color when TYPE=color
Accepted values: 0 - 255

===     PURITY    ===
Choose SFW, Sketchy, NSFW
	100 - SFW
	010 - Sketchy
	001 - NSFW
These values can be combined. For example:
	110 - SFW and Sketchy

===     BOARDS    ===
Choose boards to search in
	1 - Anime / Manga
	2 - Wallpapers / General
	3 - High Resolution
These values can be combined. For example:
	12 - Anime / Manga and Wallpapers / General

===    SORT_BY    ===
Accepted values:
	date      - sort by date
	views     - sort by view counts
	favs      - sort by favorite counts
	relevance - sort by relevance according to the search

===   SORT_ORDER  ===
Accepted values:
	asc  - ascending
	desc - descending

=== IMGS_PER_PAGE ===
Images per page. This should be set so that TOTAL_IMGS is
a multiple of this number.
Accepted values:
	20, 32, 40, 60

===   TOTAL_IMGS  ===
Total number of images to download. Should be a multiple
of IMGS_PER_PAGE.
