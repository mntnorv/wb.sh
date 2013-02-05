#!/bin/bash
#
# Download images from wallbase.cc
#
# by Mantas Norvaiša
# 2013
#

#####################
###    OPTIONS    ###
#####################

### Login
USER=
PASS=

### Download options
DIR=~/Documents/Walls/
REMOVE_OLD=1
DOWNLOAD=1

### Search options
TYPE=search

# search
QUERY=landscape
# color
COLOR_R=64
COLOR_G=87
COLOR_B=10

PURITY=100
BOARDS=23
SORT_BY=date
SORT_ORDER=desc
IMGS_PER_PAGE=20
TOTAL_IMGS=20

RESOLUTION=0
RES_OPTION=gteq
ASPECT_RATIO=0

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
		# Download or not
		dload=true
		# If ignore file exists
		if [ -f $4 ]; then
			# If in ignore list
			if cat $4 | grep "$number" >/dev/null; then
				dload=false
			fi
		fi
		# Download only if dload is true
		if [ $dload == true ]; then
			# Save exact image URL
			code=$(curl -s -b $3 -e "http://wallbase.cc" $img | egrep -o "B\('(\w|=|\+|/)+?'\)")
			length=${#code}
			length=$(($length - 5))
			url=$(echo ${code:3:$length} | base64 -d)
			# If images need to be downloaded and if the string is not empty
			# print required parameters for curl
			if [ -n "$url" ]; then
				echo "$url" >> $2
				
				if [ $DOWNLOAD == 1 ]; then
					echo "-O" >> $2
				fi
			fi
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

# POST and URL
post=""
url=""

# Login
if [ $(($PURITY % 10)) == 1 ]; then
	if [ -z "$USER" -o -z "$PASS" ]; then
		echo "Error: username or password empty"
		exit
	else
		login $USER $PASS $cookies
	fi
fi

echo "Getting URLs:"

# Current page number
pageNum=1

# Save post data and URL
if [ $TYPE == search ]; then
	post="query=$QUERY&board=$BOARDS&nsfw=$PURITY&res=$RESOLUTION&res_opt=$RES_OPTION&aspect=$ASPECT_RATIO"
	post="$post&orderby=$SORT_BY&orderby_opt=$SORT_ORDER&thpp=$IMGS_PER_PAGE&section=wallpapers"
	url=http://wallbase.cc/search
elif [ $TYPE == color ]; then
	post="board=$BOARDS&nsfw=$PURITY&res=$RESOLUTION&res_opt=$RES_OPTION&aspect=$ASPECT_RATIO"
	post="$post&orderby=$SORT_BY&orderby_opt=$SORT_ORDER&thpp=$IMGS_PER_PAGE"
	url=http://wallbase.cc/search/color/$COLOR_R/$COLOR_G/$COLOR_B
elif [ $TYPE == random ]; then
	post="board=$BOARDS&nsfw=$PURITY&res=$RESOLUTION&res_opt=$RES_OPTION&aspect=$ASPECT_RATIO&thpp=$IMGS_PER_PAGE"
	url=http://wallbase.cc/random
fi

# Get all URLs
for (( count= 0; count< "$TOTAL_IMGS"; count=count+"$IMGS_PER_PAGE" ));
do
	# Get search page
	curl -s -b $cookies -d $post -e "http://wallbase.cc" $url/$count > $page
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
if [ $(($PURITY % 10)) == 1 ]; then
	rm $cookies
fi

if [ $DOWNLOAD == 1 ]; then
	rm $urls
fi

echo "Done."
