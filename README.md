# NDI recorder Dockerfile
Record NDI streams within a Docker container. Currently supports 1 stream per
container. Downloads SDK and recorder directly from [ndi.video](https://ndi.video). See an
excerpt of the relevant documentation in [SDK_DOCUMENTATION.md](./SDK_DOCUMENTATION.md)
or the [online docs](https://docs.ndi.video/all/developing-with-ndi/sdk/command-line-tools).

This docker image **needs a Linux host** for mDNS sharing with avahi and dbus. Install
avahi-daemon and avahi-utils on the host as well and ensure the avahi-daemon service
is enabled.

First, [install Docker](https://docs.docker.com/engine/install/) if you haven't already.

Run locally: 
```shell
# Install host dependencies, assumes you have docker installed
apt install avahi-daemon avahi-utils

# Build container
docker build -t ndi-recorder .

# Run the recorder container (use -dt instead of -it to run in background; view with `docker ps`)
# Output folder must exist!
docker run -it \
--mount type=bind,source=/var/run/dbus,target=/var/run/dbus \
--mount type=bind,source=/var/run/avahi-daemon/socket,target=/var/run/avahi-daemon/socket \
--mount type=bind,source=.,target=/storage \
-e STREAM_NAME="BIRDDOG-PTZ-01 (CAM)" \
-e OUTPUT_FOLDER="/storage/your_output_folder" \
ndi-recorder
```

If you would like to simply open a shell without starting the recorder, add `bash` after the
final `ndi-recorder` text in the command above.

An example docker compose file is provided; run this with `docker compose up`.

## Network-attached storage
To save directly to a network-attached storage device, first create a volume:
```shell
# Create a volume (change IP, device, and name) if you want to record to NFS server
docker volume create --driver local \
--opt type=nfs \
--opt o=nfsvers=4,addr=192.168.216.58,nolock,soft,rw \
--opt device=:/mnt/HELYX/Storage \
my_storage_volume
```

Then, replace the mount argument `source=.,target=/storage` with this:
```shell
--mount source=my_storage_volume,target=/storage
```

## To do's
- Easier changing of output folder
- Timestamps & chopping:
  - needs wrapper program to send `<record_chop filename="$OUTPUT_FOLDER/$STREAM_NAME-$TIMESTAMP.mov"/>`)
  - might be possible using a cronjob or docker healthcheck?
- Example docker compose file segfaults, find out why
