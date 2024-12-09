# Ensure pv is installed: sudo apt-get install pv

FOLDER_ARG=$1
if [ -z "$FOLDER_ARG" ]; then
    FOLDER_ARG="./"
fi

# Use pv to show progress
# if pv installed 
if [ -x "$(command -v pv)" ]; then
    du -lh --max-depth 1 $FOLDER_ARG | pv -l -s $(find $FOLDER_ARG -maxdepth 1 | wc -l) | sort -h -r
    exit 0
fi

du -lh --max-depth 1 $FOLDER_ARG | sort -h -r