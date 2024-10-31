# du -h -a --max-depth 0 ./

FOLDER_ARG=$1
if [ -z "$FOLDER_ARG" ]; then
    FOLDER_ARG="./"
fi
du -lh --max-depth 1 $FOLDER_ARG | sort -h -r