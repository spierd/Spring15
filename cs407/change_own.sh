#!bin/sh
#I wanted to learn more about bash scripting so I had some fun with this...
#This script will search for lab files matching a specific format, then change permissions and ownership of found files.
#v1.0

OPTIND=1
verbose=0
flist=0
fmod=0
dir="/home/u/csci2/dogs/merantn/cs407/labs/graded/"
dir2=""
files=""
name=""
group=""

while getopts "vh?lmd:" opt; do
        case "$opt" in
        h)
                echo "Usage:"
                echo " -d DIR -- Searches DIR. Default searches /home/u/csci2/dogs/merantn/cs407/labs/graded/"
                echo " -l -- Outputs the names of files matching lab format"
                echo " -m -- Outputs file modifications that are taking place"
                echo "       Note: existing permissions are not checked prior to chown or chmod application"
                echo " -v -- Verbose. Combines -l and -m options"
                echo " -h -- Displays this help information"

                exit 1
                ;;
        v)
                verbose=1
                ;;
        l)
                flist=1
                ;;
        m)
                fmod=1
                ;;
        d)
                if [ -d "$OPTARG" ]
                then
                        dir=$OPTARG
                else
                        echo "Directory $OPTARG not accessible. Exiting."
                        exit 1
                fi
                ;;

        *)
                echo " Use -h to list flags. Exiting."
                exit 1
                ;;
        esac
done

#easy way to print the directory in which to search
cd $dir
echo "Searching in `pwd` for completed labs."
cd -

#ensures only labs are modified
files=`ls $dir | grep '^cs407-lab.*-.*\.\(txt\|pdf\|sh\)$'`

if [ "$files" == "" ]
then
        echo "No lab files available. Exiting."
        exit 1
fi

if [ "$verbose" -eq 1 -o "$flist" -eq 1 ]
then
        echo "Labs found:"
        echo "$files"
else
        echo "Files found and modifications beginning."
fi

#ensures that the given directory ends in a slash
dir2=`echo $dir | sed 's/\([^\/]\)$/\1\//'`

for i in $files; do
        name=`echo $i | cut -d'-' -f3 | cut -d'.' -f1`
        group=`groups $name | cut -d" " -f1`

        chmod 600 $dir2$i
        chown $name:$group $dir2$i
        if [ "$verbose" -eq 1 -o "$fmod" -eq 1 ]
        then
                echo "applied chmod to $dir2$i with 600"
                echo "applied chown to $dir2$i with $name:$group"
        fi
done
echo "Done."
exit 0
