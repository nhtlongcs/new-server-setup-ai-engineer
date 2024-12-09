MOUNT_SRC=$1
MOUNT_DST=$2
MOUNT_TYPE=$3

# Check if the source and destination are provided

if [ -z $MOUNT_SRC ] || [ -z $MOUNT_DST ] || [ -z $MOUNT_TYPE ]; then
    echo "Usage: mount_disk.sh <source> <destination> <type>"
    exit 1
fi
# Check if the destination directory exists
if [ ! -d $MOUNT_DST ]; then
    echo "Destination directory does not exist"
    exit 1
fi

# mount type should be [drvfs, cifs, nfs, exfat]

mkdir -p $MOUNT_DST
echo "Mounting $MOUNT_SRC to $MOUNT_DST"
sudo mount -t $MOUNT_TYPE $MOUNT_SRC $MOUNT_DST
echo "Granting permissions to $MOUNT_DST"
# sudo mount -t drvfs $MOUNT_SRC $MOUNT_DST
sudo chmod -R 777 $MOUNT_DST

