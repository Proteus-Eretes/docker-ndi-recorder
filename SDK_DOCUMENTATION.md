Taken from the NDI SDK Documentation (SDK v5.5, 10 April 2023).

# 17 COMMAND LINE TOOLS
## 17.1 RECORDING
A, full cross-platform native NDI recording is provided in the SDK. This is
provided as a command line application in order to allow it to be integrated
into both end-user applications and scripted environments. All input and output
from this application is provided over stdin and stdout, allowing you to read
and/or write to these in order to control the recorder.

The NDI recording application implements most of the complex components of file
recording, and may be included in your applications under the SDK license. The
functionality provided by the NDI recorder is as follows:

- Record any NDI source. For full-bandwidth NDI sources, no video recompression
  is performed. The stream is taken from the network and simply stored on disk,
  meaning that a single machine will take almost no CPU usage in order to record
  streams. File writing uses asynchronous block file writing, which should mean
  that the only limitation on the number of recorded channels is the bandwidth
  of your disk sub-system and efficiency of the system network and disk device 
  drivers.
- All sources are synchronized. The recorder will time-base correct all
  recordings to lock to the current system clock. This is designed so that, if
  you are recording a large number of NDI sources, the resulting files are
  entirely synchronized with each other. Because the files are written with
  timecode, they may then be used in a nonlinear editor without any additional
  work required for multi-angle or multi-source synchronization.
- Still better, if you lock the clock between multiple computers systems using
  NTP, recordings done independently on all computer systems will always be
  automatically synchronized.
- The complexities of discontinuous and unlocked sources are handled correctly.
  The recorder will handle cases in which audio and/or video are discontinuous
  or not on the same clock. It should correctly provide audio and video
  synchronization in these cases and adapt correctly even when poor input
  signals are used.
- High Performance. Using asynchronous block-based disk writing without any
  video compression in most cases means that the number of streams written to
  disk is largely limited only by available network bandwidth and the speed of
  your drives. On a fast system, even a large number of 4K streams may be
  recorded to disk!
- Much more... Having worked with a large number of companies wanting recording
  capabilities, we realized that providing a reference implementation that
  handles a lot of the edge-cases and problems of recording would be hugely
  beneficial. And allowing all sources to be synchronized makes NDI a
  fundamentally more powerful and useful tool for video in all cases.
- The implementation provided is cross-platform, and may be used under the SDK
  license in commercial and free applications. Note that audio is recorded in
  floating-point and so is never subject to audio clipping at record time.

Recording is implemented as a stand-alone executable, which allows it either to
be used in your own scripting environments (both locally and remotely), or
called from an application. The application is designed to take commands in a
structured form from `stdin` and put feedback out onto `stdout`.

### 17.1.1 COMMAND LINE ARGUMENTS
The primary use of the application would be to run it and specify the NDI source
name and the destination filename. For instance, if you wished to record a
source called `My Machine (Source 1)` into a file `C:\Temp\A.mov`. The command
line to record this would be:

```shell
"NDI Record.exe" –I "My Machine (Source 1)" –o "C:\Temp\A.mov"
```

This would then start recording when this source has first provided audio and
video (both are required in order to determine the format needed in the file).
Additional command line options are listed below:

| Command Line Option | Description                                                                                                                                                                                                                                                                                                                                                                                                                                   |
|---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `-i "source-name"`  | Required option. The NDI source name to record.                                                                                                                                                                                                                                                                                                                                                                                               |
| `-o "file-name"`    | Required option. The filename you wish to record into. Please note that if the filename already exists a number will be appended to it to ensure that it is unique.                                                                                                                                                                                                                                                                           |
| `-u "url"`          | Optional. This is the URL of the NDI source if you wish to have recording start slightly quicker, or if the source is not currently visible in the current group or network.                                                                                                                                                                                                                                                                  |
| `-nothumbnail`      | Optional. Specify whether a proxy file should be written. By default this option is enabled.                                                                                                                                                                                                                                                                                                                                                  |
| `-noautochop`       | Optional. When specified, this specifies that if the video properties change (resolution, framerate, aspect ratio) the existing file is chopped and new one started with a number appended. When false it will simply exit when the video properties change, allowing you to start it again with a new file-name should you want. By default, if the video format changes it will open a new file in that format without dropping any frames. |
| `-noautostart`      | Optional. This command may be used to achieve frame-accurate recording as needed. When specified, the record application will run and connect to the remote source however it will not immediately start recording. It will them start immediately when you send a `<start/>` message to `stdin`.                                                                                                                                             |

Once running, the application can be interacted with by taking input on `stdin`,
and will provide response onto `stdout`. These are outlined below.

If you wish to quit the application, the preferred mechanism is described in the
input settings section, however one may also press `CTRL+C` to signal an exit
and the file will be correctly closed. If you kill the recorder process while it
is running the resulting file will be invalid, since QuickTime files require an
index at the end of the file. The Windows version of the application will also
monitor its launching parent process; if that should exit it will correctly close the file and exit.

### 17.1.2 INPUT SETTINGS
While this application is running, a number of commands can be sent to `stdin`.
These are all in XML format and can control the current recording settings.
These are outlined as follows.

| Command Line Option                     | Description                                                                                                                                                                                                                                              |
|-----------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `<start/>`                              | Start recording at this moment; this is used in conjuction with the “`-noautostart`” command line.                                                                                                                                                       |
| `<exit/>` or `<quit/>`                  | This will cancel recording and exit the moment that the file is completely on disk.                                                                                                                                                                      |
| `<record_level gain="1.2"/>`            | This allows you to control the current recorded audio levels in decibels. 1.2 would apply 1.2 dB of gain to the audio signal while recording to disk.                                                                                                    |
| `<record_agc enabled="true"/>`          | Enable (or disable) automatic gain control for audio, which will use an expander/compressor to normalize the audio while it is being recorded.                                                                                                           |
| `<record_chop/>`                        | Immediately stop recording, then restart another file without dropping frames.                                                                                                                                                                           |
| `<record_chop filename="another.mov"/>` | Immediately stop recording, and start recording another file in potentially adifferent location without dropping frames. This allows a recording location to be changed on the fly, allowing you to span recordings across multiple drives or locations. |

### 17.1.3 OUTPUT SETTINGS
Output from NDI recording is provided onto `stdout`. The application will place
all non-output settings onto `stderr` allowing a listening application to
distinguish between feedback and notification messages. For example, in the run
log below different colors are used to highlight what is placed on `stderr` (blue)
and `stdout` (green).

```
NDI Stream Record v1.00
Copyright (C) 2023 Vizrt NDI AB. All rights reserved.
[14:20:24.138]: <record_started filename="e:\Temp 2.mov" filename_pvw="e:\Temp2.mov.preview" frame_rate_n="60000" frame_rate_d="1001"/>
[14:20:24.178]: <recording no_frames="0" timecode="732241356791" vu_dB="-23.999269" start_timecode="732241356791"/>
[14:20:24.209]: <recording no_frames="0" timecode="732241690457" vu_dB="-26.976938"/>
[14:20:24.244]: <recording no_frames="2" timecode="732242024123" vu_dB="-20.638922"/>
[14:20:24.277]: <recording no_frames="4" timecode="732242357789" vu_dB="-20.638922"/>
[14:20:24.309]: <recording no_frames="7" timecode="732242691455" vu_dB="-17.237122"/>
[14:20:24.344]: <recording no_frames="9" timecode="732243025121" vu_dB="-19.268487"/>
...
[14:20:27.696]: <record_stopped no_frames="229" last_timecode="732273722393"/>
```

Once recording starts it will put out an XML message specifying the filename for
the recording, and provide you with the framerate.

It then gives you the timecode for each recorded frame, and the current audio
level in decibels (if the audio is silent then the dB level will be `-inf`). If
a recording stops it will give you the final timecode written into the file.
Timecodes are specified as UTC time since the Unix Epoch (1/1/1970 00:00) with
100 ns precision.

### 17.1.4 ERROR HANDLING
A number of different events can cause recording errors. The most common is when
the drive system that you are recording to is too slow to record the video data
being stored on it, or the seek times to write multiple streams end up
dominating the performance (note that we do use block writers to avoid this as
much as possible).

The recorder is designed to never drop frames in a file; however, when it cannot
write to disk sufficiently fast it will internally “buffer” the _compressed_
video until it has fallen about two seconds behind what can be written to disk.
Thus, temporary disk or connection performance issues do not damage the
recording.

Once a true error is detected it will issue a record-error command as follows:

```
[14:20:24.344]: <record_error error="The error message goes here."/>
```

If the option for autochop is enabled, the recorder will start attempting to
write a new file. This process ensures that each file always has all frames
without drops, but if data needed to be dropped because of insufficient disk
performance, that data will be missing between files.
