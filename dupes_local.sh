#! /usr/bin/env bash
#
# dupes.sh
# Allows a user to find duplicate files in a given directory tree.
# Rachael Birky
# 2014.09.29

# Validate user input
if [[ $# -ne 1 ]]; then
	echo "Illegal number of parameters/
		\nUsage: $0 <directory path>" >&2
	exit 1
fi

# these are all files that are duplicates, but NOT GROUPED YET
arr=( $(find $1 -type f -print0 | xargs -0 md5sum | sort -g | uniq -w32 -D | cut -d ' ' -f 3) )
grossNumDupes=${#arr}
grossDupesSize=0

# for file in "${arr[@]}"; do stat --printf="%s" $file; done

for file in "${arr[@]}"; do
	s=$(stat -c %s $file);
	grossDupesSize=$((grossDupesSize+s));
done

# set size of duplicates, number of groups, and counter variable
#  for iterating over duplicates to zero
dupesSize=0
numGroups=0
i=0

# loop over entire contents of array
while [[ i -lt ${#arr} ]]
do
    # access the file at i
	file=${arr[i]}
    
    #calculate the size and md5sum of the current file
    m1=$(md5sum $file | cut -d ' ' -f 1)
    s=$(stat -c %s $file);

    # store the file at i in a new array representing the current group
    a1=(${arr[i]})

    # initialize a new counter variable to iterate through rest of array
    j=$((i+1))

    # if the md5sum of the next files are equal to the inital,
    #  and the index is in range, add the next file to the current group
    #  and iterate the second counter variable by one
    while [[ $(md5sum ${arr[j]} | cut -d ' ' -f 1) = m1 -a $j -lt ${#arr} ]]
    do
   		a1+=(${arr[j]})
    	j=$((j+1))
    done

    # after finishing a group, increment the number of groups by one
    #  and add the current size to the total size
    numGroups=$((numGroups+1))
    dupesSize=$((dupesSize+s))

    # increment the first counter variable to skip the files of the previous group
    #  and start a fresh group
    i=$((i+j))

    # TODO
    # calculate B, K, M etc, store in $s


    # print info where s is size, counter is size of a1, files are files in a1
    echo "%d files (%d%s each)" ${#a1} $s
    echo ${a1} # use a for loop for pretty formatting
    echo ""
done


# TODO
# calculate B, K, M etc, store in dupesSize
echo "Total Duplicates: " $((grossNumDupes-numGroups))
echo "Total Size: " $dupesSize


######################################################################################
# NOTES
######################################################################################

# List all files, and calculate md5sums
find $1 -type f -print0 | xargs -0 md5sum | sort -g | cut -d ' ' -f 1 | uniq -D 
find . -type f -print0 | xargs -0 md5sum | sort -g | cut -d ' ' -f 1 | uniq -D 

#store files in an array...? since can't pass to xargs twice or use exec and xargs

# should probably store in a file, but I want to record file sizes too
# find size using...
stat --printf="%s" ${file}
# use sed/awk to append file size to each line??
# md5sum / file / size

# then sort, cut, list only repeated (uniq -D)

# for my mac terminal
find . -type f -print0 | xargs -0 md5 | cut -d '=' -f 2 | sort -g

# storing in an array
files=($(find $1 -type f -print0))

arr=( $(find . -type f) )
echo ${arr[@]}

arr=( $(find $1 -type f) )
arr=( $(find $1 -type f | xargs md5sum | sort -g | uniq -w32 -D) )
arr=( $(find $1 -type f -print0 | xargs -0 md5sum | sort -g | uniq -w32 -D) )

# printing each line to stdout
for line in "${arr[@]}"
do
	echo $line
done

# saving in a file
find -type f -print0 | xargs -0 md5sum | sort -g | uniq -w32 -D > results.txt

# these are all files that are duplicates, but not grouped yet
arr=( $(find $1 -type f -print0 | xargs -0 md5sum | sort -g | uniq -w32 -D | cut -d ' ' -f 3) )

# calculating the size of files
s=size
su=suffix
# can also concatenate int with str as m=$n"str"
return $s$suffix

function file_size($size)
{
    $filesizename = array(" Bytes", " KB", " MB", " GB", " TB", " PB", " EB", " ZB", " YB");
    return $size ? round($size/pow(1024, ($i = floor(log($size, 1024)))), 2) . $filesizename[$i] : '0 Bytes';
}

if [ $s -gt 1000 ] then;
    answer=$(bc <<< "scale=2;$var1/$var2")
    echo $s
else
    echo $s
fi

if [ $s -ge 1000000000 ]
    then s="$(bc <<< "scale=2;$s/1000000000") G"
elif [ $s -ge 1000000 ]
    then s="$(bc <<< "scale=2;$s/1000000") M"
elif [ $s -ge 1000 ]
    then s="$(bc <<< "scale=2;$s/1000") K"
else
    s="$s B"
fi

if [ $dupesSize -ge 1000000000 ]
    then dupesSize="$(bc <<< "scale=2;$dupesSize/1000000000") G"
elif [ $dupesSize -ge 1000000 ]
    then dupesSize="$(bc <<< "scale=2;$dupesSize/1000000") M"
elif [ $dupesSize -ge 1000 ]
    then dupesSize="$(bc <<< "scale=2;$dupesSize/1000") K"
else
    dupesSize="$dupesSize B"
fi
