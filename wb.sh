#!/bin/bash
#
# Download images from wallbase.cc
#
# by Mantas Norvaiša
# 2012
#

#####################
###    OPTIONS    ###
#####################

### Login

USER=
PASS=

# Directory to download images to
DIR=~/Documents/Walls/

# REMOVE_OLD
# 1 to remove all images from $DIR
# 0 to leave images in $DIR
REMOVE_OLD=1

# DOWNLOAD
# 1 - download images
# 0 - only get image links and save them to imgs.txt
DOWNLOAD=1

### Search options

# QUERY
# String to search for
QUERY=landscape

# PURITY
# 100 - SFW
# 010 - Sketchy
# 001 - NSFW
# Can be combined:
# 110 - SFW and Sketchy
# etc.
PURITY=100

# BOARDS
# 1 - Anime / Manga
# 2 - Wallpapers / General
# 3 - High Resolution
# Can be combined:
# 12 - Anime / Manga AND Wallpapers / General
# etc.
BOARDS=123

# SORT_BY
# Accepted values:
# date, views, favs, relevance
SORT_BY=date

# SORT_ORDER
# Accepted values:
# asc, desc
SORT_ORDER=desc

# IMGS_PER_PAGE
# Accepted values:
# 20, 32, 40, 60
IMGS_PER_PAGE=20

# TOTAL_IMGS
# Should be a multiple of IMGS_PER_PAGE
TOTAL_IMGS=20

#####################
###   FUNCTIONS   ###
#####################

#
# Login to wallbase.cc and store the cookies
#   arg1: username
#   arg2: password
#   arg3: cookie file
#

function login {
	# Login
	echo "Logging in..."
	# Check arguments
	if [ $# -lt 3 ] || [ $1 == '' ] || [ $2 == '' ]; then
		echo "Error logging in"
		exit
	fi
	# Check login errors
	if curl -s -c $3 -d "usrname=$1&pass=$2&nopass_email=Type+in+your+e-mail+and+press+enter&nopass=0&1=1" -e "http://wallbase.cc/start/" http://wallbase.cc/user/login | grep "Wrong username or password." > /dev/null; then
		echo "Error logging in"
		exit
	fi
	# Get permission to NSFW
	echo "Getting NSFW permission..."
	curl -s -b $3 -c $3 -e "http://wallbase.cc/start/" http://wallbase.cc/user/adult_confirm/1
}

#
# Get exact URLs from an .html file
# and write the results to a file
#    arg1: .html file
#    arg2: result file
#    arg3: cookie file
#    arg4: ignore list file
#    arg5: current page number
#

function getURLs {
	# Get image page URLs from a html file
	URLSFORIMAGES="$(cat $1 | grep -o "http:.*" | cut -d " " -f 1 | grep wallpaper)"
	
	# Current image number
	imgNum=1
	
	# Iterate through all URLs
	for imgURL in $URLSFORIMAGES
	do
		# Show current image number
		echo -en "\rPage $5: $imgNum/$IMGS_PER_PAGE"
		# URL of one image
		img="$(echo $imgURL | sed 's/.\{1\}$//')"
		# Image number
		number="$(echo $img | sed  's .\{29\}  ')"
		# If not in ignore list
		if ! cat $4 | grep "$number" >/dev/null; then
			if [ $DOWNLOAD == 1 ]; then
				echo "-O" >> $2
			fi
			# Save exact image URL
			curl -s -b $3 -e "http://wallbase.cc" $img | egrep -o "http:.*(png|jpg)" | egrep "wallbase2|imageshack.us|ovh.net" >> $2
		fi
		# Increment imgNum
		imgNum=$(($imgNum + 1))
	done
	
	# New line after the output
	echo
}

#####################
###    SCRIPT     ###
#####################

# Change directory to the specified one
cd $DIR

# Files
cookies=cookies.txt
urls=imgs.txt
page=imgs.html
ignore=ignore.txt

# Login
login $USER $PASS $cookies

echo "Getting URLs:"

# Current page number
pageNum=1

# Get all URLs
for (( count= 0; count< "$TOTAL_IMGS"; count=count+"$IMGS_PER_PAGE" ));
do
	# Get search page
	curl -s -b $cookies -d "query=$QUERY&board=$BOARDS&nsfw=$PURITY&res=0&res_opt=gteq&aspect=0&orderby=$SORT_BY&orderby_opt=$SORT_ORDER&thpp=20&section=wallpapers&1=1" -e "http://wallbase.cc" http://wallbase.cc/search/$count > $page
	# Get URLs
	getURLs $page $urls $cookies $ignore $pageNum
	rm $page
	# Increment pageNum
	pageNum=$(($pageNum + 1))
done

# Remove old images
if [ $REMOVE_OLD == 1 ]; then
	rm *.jpg 2> /dev/null
	rm *.png 2> /dev/null
fi

# Download images
if [ $DOWNLOAD == 1 ]; then
	echo
	echo "Downloading..."
	cat $urls | xargs curl
fi

# Clean up
rm $cookies

if [ $DOWNLOAD == 1 ]; then
	rm $urls
fi

echo "Done."
