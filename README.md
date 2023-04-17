# NDI recorder Dockerfile
Record NDI streams within a Docker container. Currently supports 1 stream per container.
Downloads SDK and recorder directly from ndi.tv

Needs Linux host.

Run locally: 
```shell
docker build -t ndi-recorder

docker run -it \
--mount type=bind,source=/var/run/dbus,target=/var/run/dbus \
--mount type=bind,source=/var/run/avahi-daemon/socket,target=/var/run/avahi-daemon/socket \
-e STREAM_NAME="BIRDDOG-PTZ-01 (CAM)" \
-e OUTPUT_FOLDER="H:/files/" \
ndi-recorder
```

## To do's
- Test directly outputting to different server, e.g. H:/Opnames/wedstrijd/ or 192.168.216.52/Opnames
- Timestamps & chopping:
  - needs wrapper program to send `<record_chop filename="$OUTPUT_FOLDER$STREAM_NAME-$TIMESTAMP.mov"/>`)
  - might be possible using a cronjob?
