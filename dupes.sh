#! /usr/bin/env bash
#
# dupes.sh
# Allows a user to find duplicate files in a given directory tree.
# Rachael Birky
# 2014.09.29

# Validate user input
if [[ $# -ne 1 ]]; then
    printf "Illegal number of parameters\n  Usage: $0 <directory path>\n" >&2
    exit 1
fi

if [[ ! -d $1 ]]; then
    printf "Invalid argument\n  Usage: $0 <directory path>\n" >&2
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