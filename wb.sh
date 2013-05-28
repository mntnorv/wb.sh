#!/bin/bash
#
# Download images from wallbase.cc
#
# by Mantas Norvaiša
# 2013
#

#############################
###    DEFAULT OPTIONS    ###
#############################

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
# toplist
TOPLIST=1w

PURITY=100
BOARDS=23
SORT_BY=date
SORT_ORDER=desc
IMGS_PER_PAGE=20
TOTAL_IMGS=1

RESOLUTION=0
RES_OPTION=gteq
ASPECT_RATIO=0

#####################
###   FUNCTIONS   ###
#####################

#
# Prints usage
#

function printUsage {
	echo "Usage: ./`basename $0` [options...]"
	echo "Options:"
	echo "     --aspect ASPECT Specify exact aspect ratio"
	echo " -b, --boards BOARDS Specify boards to search in"
	echo " -c, --color COLOR   Specify a color to search for"
	echo " -d, --directory DIR Directory to download images to. Defaults to current directory."
	echo "     --do-not-download  Do not download images. Saves image urls to a file."
	echo "     --leave-old     Leave all images currently in the download directory."
	echo " -n, --images COUNT  Number of images to download"
	echo "     --images-per-page COUNT  Number of images per page"
	echo " -p, --password PASSWORD  wallbase.cc password (required for NSFW)"
	echo " -P, --purity PURITY Specify image purity"
	echo " -q, --query QUERY   Specify a query"
	echo " -r, --resolution RESOLUTION  Specify a resolution"
	echo "     --res-at-least  Search for a greater or equal resolution"
	echo "     --res-exact     Search for an exact resolution (default)"
	echo " -u, --user USER     wallbase.cc username (required for NSFW)"
	echo "     --top INTERVAL  Specify a toplist interval"
	echo " -s, --sort SORT_BY  Specify sort type"
	echo "     --sort-asc      Ascending sort (default)"
	echo "     --sort-desc     Descending sort"
	echo " -t, --type TYPE     Specify query type (required)"
}

#
# Tests if a string is numeric. If not, prints an error message and
# stop the execution.
#   arg1: string
#

function testIsNumeric {
	case $1 in
    	''|*[!0-9]*)
			echo "Error: \"$1\" is not a number"
			exit 1
			;;
	esac
}

#
# Checks argument count. If there are less arguments than is needed
# usage is printed and execution of this is script is aborted.
#   arg1: argument count
#   arg2: required count
#

function testArgCount {
	if [ $1 -lt $2 ]; then
		printUsage
		exit 0
	fi
}

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
		echo "Error: failed to log in" 1>&2
		exit
	fi
	# Check login errors
	if curl -s -c $3 -d "usrname=$1&pass=$2&nopass_email=Type+in+your+e-mail+and+press+enter&nopass=0&1=1" -e "http://wallbase.cc/start/" http://wallbase.cc/user/login | grep "Wrong username or password." > /dev/null; then
		echo "Error: failed to log in" 1>&2
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
			decodedUrl=$(echo ${code:3:$length} | base64 -d)
			# If images need to be downloaded and if the string is not empty
			# print required parameters for curl
			if [ -n "$decodedUrl" ]; then
				echo "$decodedUrl" >> $2
				
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

# Parse command line options
while [ $# -gt 0 ]; do
	case $1 in
		'--aspect' )
			testArgCount $# 2
			ASPECT_RATIO="$2"
			shift 2
			;;
		'-b' | '--boards' )
			testArgCount $# 2
			# TODO: PARSE BOARDS
			shift 2
			;;
		'-c' | '--color' )
			testArgCount $# 2
			# TODO: PARSE COLORS
			shift 2
			;;
		'-d' | '--directory' )
			testArgCount $# 2
			DIR="$2"
			shift 2
			;;
		'--do-not-download' )
			DOWNLOAD=0
			shift 1
			;;
		'-n' | '--images' )
			testArgCount $# 2
			testIsNumeric "$2"
			TOTAL_IMGS="$2"
			shift 2
			;;
		'--images-per-page' )
			testArgCount $# 2
			testIsNumeric "$2"
			IMGS_PER_PAGE="$2"
			shift 2
			;;
		'--leave-old' )
			REMOVE_OLD=0
			shift 1
			;;
		'-p' | '--password' )
			testArgCount $# 2
			PASSWORD="$2"
			shift 2
			;;
		'-P' | '--purity' )
			testArgCount $# 2
			# TODO: PARSE PURITY ARGS
			shift 2
			;;
		'-q' | '--query' )
			testArgCount $# 2
			QUERY="$2"
			shift 2
			;;
		'-r' | '--resolution' )
			testArgCount $# 2
			# TODO: PARSE RESOLUTION
			shift 2
			;;
		'--res-at-least' )
			RES_OPTION=gteq
			shift 1
			;;
		'--res-exact' )
			RES_OPTION=eqeq
			shift 1
			;;
		'-u' | '--user' )
			testArgCount $# 2
			USER="$2"
			shift 2
			;;
		'--top' )
			testArgCount $# 2
			TOPLIST="$2"
			shift 2
			;;
		'-s' | '--sort' )
			testArgCount $# 2
			SORT_BY="$2"
			shift 2
			;;
		'--sort-asc' )
			SORT_ORDER=asc
			shift 1
			;;
		'--sort-desc' )
			SORT_ORDER=desc
			shift 1
			;;
		'-t' | '--type' )
			testArgCount $# 2
			TYPE="$2"
			shift 2
			;;
		* )
			echo "Error: unrecognised option \"$1\""
			exit 1
			;;
	esac
done

# Change directory to the specified one
if [ ! -d "$DIR" ]; then
	echo "Error: directory \"$DIR\" doesn't exist" 1>&2
	exit
fi

cd $DIR

# Files
cookies=cookies.txt
urls=imgs.txt
page=imgs.html
ignore=ignore.txt

# POST and URL
post=""
url=""
urlSuffix=""

# Login
if [ $(($PURITY % 10)) == 1 ]; then
	if [ -z "$USER" -o -z "$PASS" ]; then
		echo "Error: username or password empty" 1>&2
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
	url="http://wallbase.cc/search"
elif [ $TYPE == top ]; then
	url="http://wallbase.cc/toplist"
	urlSuffix="$BOARDS/$RES_OPTION/$RESOLUTION/$ASPECT_RATIO/$PURITY/$IMGS_PER_PAGE/$TOPLIST"
elif [ $TYPE == color ]; then
	post="board=$BOARDS&nsfw=$PURITY&res=$RESOLUTION&res_opt=$RES_OPTION&aspect=$ASPECT_RATIO"
	post="$post&orderby=$SORT_BY&orderby_opt=$SORT_ORDER&thpp=$IMGS_PER_PAGE"
	url="http://wallbase.cc/search/color/$COLOR_R/$COLOR_G/$COLOR_B"
elif [ $TYPE == random ]; then
	post="board=$BOARDS&nsfw=$PURITY&res=$RESOLUTION&res_opt=$RES_OPTION&aspect=$ASPECT_RATIO&thpp=$IMGS_PER_PAGE"
	url="http://wallbase.cc/random"
fi

# Get all URLs
for (( count= 0; count< "$TOTAL_IMGS"; count=count+"$IMGS_PER_PAGE" )); do
	# Get search page
	fullUrl="$url/$count"
	if [ -n "$urlSuffix" ]; then
		fullUrl="$fullUrl/$urlSuffix"
	fi

	if [ -n "$post" ]; then
		curl -s -b $cookies -d $post -e "http://wallbase.cc" $url > $page
	else
		curl -s -b $cookies -e "http://wallbase.cc" $url > $page
	fi
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
