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

# Login
USER=
PASS=

# Directory to downlaod images to
DIR=~/Documents/Walls/

# Remove old images
REMOVE_OLD=1

# Search options
QUERY=landscape
SORT_BY=date
SORT_ORDER=desc
IMGS_PER_PAGE=20
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
	curl -c $3 -d "usrname=$1&pass=$2&nopass_email=Type+in+your+e-mail+and+press+enter&nopass=0&1=1" -e "http://wallbase.cc/start/" http://wallbase.cc/user/login
	# Get permission to NSFW
	echo "Getting NSFW permission..."
	curl -b $3 -c $3 -e "http://wallbase.cc/start/" http://wallbase.cc/user/adult_confirm/1
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
			# Save exact image URL
			echo "-O" >> $2
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

echo "Getting URLs"

# Current page number
pageNum=1

# Get all URLs
for (( count= 0; count< "$TOTAL_IMGS"; count=count+"$IMGS_PER_PAGE" ));
do
	# Get search page
	curl -s -b $cookies -d "query=$QUERY&board=123&nsfw=100&res=0&res_opt=gteq&aspect=0&orderby=$SORT_BY&orderby_opt=$SORT_ORDER&thpp=20&section=wallpapers&1=1" -e "http://wallbase.cc" http://wallbase.cc/search/$count > $page
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
cat $urls | xargs curl

# Clean up
rm $cookies
rm $urls
