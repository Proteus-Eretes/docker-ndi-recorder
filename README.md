# NDI recorder Dockerfile
Record NDI streams within a Docker container. Currently supports 1 stream per
container. Downloads SDK and recorder directly from [ndi.tv](ndi.tv). See an
excerpt of the relevant documentation in [SDK_DOCUMENTATION.md](./SDK_DOCUMENTATION.md)
or online at https://docs.ndi.video/docs/sdk/16.-command-line-tools

**Needs Linux host** for mDNS sharing with avahi and dbus. Install avahi-daemon
and avahi-utils on the host as well.

Run locally: 
```shell
# Install host dependencies
apt install avahi-daemon avahi-utils

# Build container
docker build -t ndi-recorder .

# Create a volume (change IP, device, and name) if you want to record to NFS server
# or use a different mount when running instead, e.g. `--mount type=bind,source=~/,target=/H`
docker volume create --driver local \
--opt type=nfs \
--opt o=nfsvers=4,addr=192.168.216.58,nolock,soft,rw \
--opt device=:/mnt/HELYX/Storage \
hakclient1_storage

# Run the recorder container (use -dt instead of -it to run in background; view with `docker ps`)
# Output folder must exist!
docker run -it \
--mount type=bind,source=/var/run/dbus,target=/var/run/dbus \
--mount type=bind,source=/var/run/avahi-daemon/socket,target=/var/run/avahi-daemon/socket \
--mount source=hakclient1_storage,target=/H
-e STREAM_NAME="BIRDDOG-PTZ-01 (CAM)" \
-e OUTPUT_FOLDER="/H/your_output_folder" \
ndi-recorder
```

## To do's
- Easier changing of output folder
- Timestamps & chopping:
  - needs wrapper program to send `<record_chop filename="$OUTPUT_FOLDER/$STREAM_NAME-$TIMESTAMP.mov"/>`)
  - might be possible using a cronjob?
  - doesn't seem like `ndi-record` responds to commands
