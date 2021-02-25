# 出力

TARGET = output.mkv

# 入力

ALL_MKV_FILES = $(wildcard *.mkv)
ALL_INPUT_FILES = $(filter-out $(VIDEO_FILE),$(filter-out $(TARGET),$(ALL_MKV_FILES)))

# 音量（ex. 倍2、半減-0.5、10dB、-10dB）

BGM_VOLUME = -10dB
VOICE_VOLUME = 1.0

# 一時ファイル

ALL_BGM_FILES = $(patsubst %.mkv,%_bgm.aac,$(ALL_INPUT_FILES))
ALL_VOICE_FILES = $(patsubst %.mkv,%_voice.aac,$(ALL_INPUT_FILES))

VIDEO_FILE = video.mkv
BGM_FILE = bgm.aac
VOICE_FILE = voice.aac
SOUND_FILE = sound.aac

VIDEO_INDEX_FILE = indexlist_video.txt
BGM_INDEX_FILE = indexlist_bgm.txt
VOICE_INDEX_FILE = indexlist_voice.txt

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(VIDEO_FILE) $(SOUND_FILE)
	ffmpeg -i $(VIDEO_FILE) -i $(SOUND_FILE) \
           -c copy -map 0:v:0 -map 1:a:0 $@

######## SOUND #############################

$(SOUND_FILE): $(BGM_FILE) $(VOICE_FILE)
	ffmpeg -i $(BGM_FILE) -i $(VOICE_FILE) -filter_complex "amix" $@

######## VIDEO #############################

# indexlistをつくる
$(VIDEO_INDEX_FILE): $(ALL_INPUT_FILES)
	$(file > $@,# This is made automatically.)
	$(foreach f,$^,$(file >> $@,file $(f)))

# 複数のmkvを結合する
$(VIDEO_FILE): $(VIDEO_INDEX_FILE) $(ALL_VIDEO_FILES)
	ffmpeg -f concat -i $< -c copy $@

######## BGM #############################

# indexlistをつくる
$(BGM_INDEX_FILE): $(ALL_BGM_FILES)
	$(file > $@,# This is made automatically.)
	$(foreach f,$^,$(file >> $@,file $(f)))

# 複数のaacを結合する
$(BGM_FILE): $(BGM_INDEX_FILE) $(ALL_BGM_FILES)
	ffmpeg -f concat -i $< -c copy $@

# 複数のmkvから複数のaacをつくる
%_bgm.aac: %.mkv
	ffmpeg -i $< -vn -map 0:2 -codec:a aac -filter:a volume=$(BGM_VOLUME) $@

######## VOICE #############################

# indexlistをつくる
$(VOICE_INDEX_FILE): $(ALL_VOICE_FILES)
	$(file > $@,# This is made automatically.)
	$(foreach f,$^,$(file >> $@,file $(f)))

# 複数のaacを結合する
$(VOICE_FILE): $(VOICE_INDEX_FILE) $(ALL_VOICE_FILES)
	ffmpeg -f concat -i $< -c copy $@

# 複数のmkvから複数のaacをつくる
%_voice.aac: %.mkv
	ffmpeg -i $< -vn -map 0:3 -acodec aac -filter:a volume=$(VOICE_VOLUME) $@

######## CLEAN #############################

clean:
	rm -rf $(VIDEO_FILE) $(SOUND_FILE) $(VOICE_FILE) $(BGM_FILE)
	rm -rf $(ALL_VOICE_FILES) $(ALL_BGM_FILES)
	rm -rf $(VOICE_INDEX_FILE) $(BGM_INDEX_FILE) $(VIDEO_INDEX_FILE)
	rm -rf $(TARGET)
