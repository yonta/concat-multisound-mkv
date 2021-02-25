# concat-multisound-mkv

Concatenate all videos which has multiple track audio and is made by OBS,
changing sound volume.

[OBS](https://obsproject.com/ja) can record video which has multiple track
audio.
But, using the video with multiple track audio is not easy.
For example, you need complex `ffmpeg` command or professional editing software.

This product give you easy way to record and edit videos with OBS.
You need only some rule about OBS recording and `make` command.

## Requirements

- OBS
- GNU Make and command line

## How to Use

### Requirement Usage of OBS

We assume that you record videos with multiple sound tracks by OBS.
The video has all sound in track 1, has only game sound in track 2,
and has only voice sound in track 3.

More detail of OBS configurations, please google it.

### Record Video

We assume that you record videos with adove settings.
You can stop and restart with new video file as many time as you like.
It makes video small, and you manage it easily.

### Move Videos

Move recorded videos to same directory with `Makefile` of this repository.
Our script targets all videos in this directory.

### Edit Volume configuration

Open `Makefile` with editor, edit lines of `BGM_VOLUME` and `VOICE_VOLUME`.
Game and voice sounds will changed by this values.
You can use ratio by float and dB notation.

For example, if you want to change game sound down, and do not want to change
voice sound.

``` makefile
BGM_VOLUME := -15dB
VOICE_VOLUME := 1.0
```

### Concatenate Videos

Run `make` command and wait.
It will generate `output.mkv` video.

``` console
$ make
ffmpeg -i input1.mkv -vn -map 0:2 -codec:a aac -filter:a volume=-10dB input1_bgm.aac
...
video:2364kB audio:244kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: 0.258335%
$
```

### Cleaning

After script have finished, run `make clean` to remove old temporarily files.
And move your videos and output video to other place.
