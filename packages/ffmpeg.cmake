# AUDIO_ONLY (-DAUDIO_ONLY=ON) builds FFmpeg for music playback only: every decoder, demuxer, parser, protocol,
# encoder, muxer and hardware accelerator is disabled and then only the audio ones (plus the image decoders needed for
# embedded cover art) are switched back on. The default (AUDIO_ONLY off) is the full build used by Auren and is unchanged.
if(AUDIO_ONLY)
    set(ffmpeg_variant_flags
        --disable-hwaccels
        --disable-encoders
        --disable-muxers
        --disable-decoders
        --disable-demuxers
        --disable-parsers
        --disable-protocols
        --enable-decoder=flac,alac,mp3,mp3float,mp2,mp2float,aac,aac_latm,vorbis,opus,libopus,wmav1,wmav2,wmalossless,wmapro,ape,wavpack,tta,tak,mpc7,mpc8,dsd_lsbf,dsd_msbf,dsd_lsbf_planar,dsd_msbf_planar,pcm_s8,pcm_u8,pcm_s16le,pcm_s16be,pcm_s24le,pcm_s24be,pcm_s32le,pcm_s32be,pcm_f32le,pcm_f32be,pcm_f64le,pcm_f64be,pcm_alaw,pcm_mulaw,adpcm_ima_wav,adpcm_ms,mjpeg,png
        --enable-demuxer=mp3,flac,ogg,matroska,mov,aac,ape,wav,w64,asf,wv,tta,tak,mpc,mpc8,dsf,dsdiff,aiff,caf,pcm_s16le,pcm_s16be,libopenmpt,libmodplug
        --enable-parser=aac,aac_latm,flac,mpegaudio,opus,vorbis,mjpeg,png
        --enable-protocol=file,pipe,cache,tcp,tls,http,https,crypto
    )
    # Hardware decoders/encoders, video codec libraries and the other video-only wrappers are left out of the audio build.
    set(ffmpeg_hw_flags "")
    set(ffmpeg_video_libs "")
    set(ffmpeg_audio_libs
        --enable-libmodplug
        --enable-libopenmpt
        --enable-libopus
        --enable-libsoxr
        --enable-libvorbis
        --enable-libbs2b
        --enable-lcms2
        --enable-libzimg
        --enable-libxml2
        --enable-libmysofa
        --enable-libplacebo)
    set(ffmpeg_uavs3d_cmd "")
else()
    set(ffmpeg_variant_flags "")
    set(ffmpeg_hw_flags
        --enable-cuda-llvm
        --enable-cuvid
        --enable-nvdec
        --enable-nvenc
        --enable-amf
        --enable-openal
        --enable-vaapi
        --enable-libvpl)
    set(ffmpeg_video_libs
        --enable-vapoursynth
        --enable-libass
        --enable-libbluray
        --enable-libvpx
        --enable-libwebp
        --enable-libaom
        --enable-libsvtav1
        --enable-libdav1d
        --enable-libjxl
        --enable-libaribcaption)
    set(ffmpeg_audio_libs
        --enable-libmodplug
        --enable-libopenmpt
        --enable-libmp3lame
        --enable-lcms2
        --enable-libopus
        --enable-libsoxr
        --enable-libspeex
        --enable-libvorbis
        --enable-libbs2b
        --enable-libzimg
        --enable-libxml2
        --enable-libmysofa
        --enable-libplacebo)
endif()

ExternalProject_Add(ffmpeg
    DEPENDS
        amf-headers
        nvcodec-headers
        bzip2
        lame
        lcms2
        openssl
        libass
        libbluray
        libmodplug
        libpng
        libsoxr
        libbs2b
        libvpx
        libwebp
        libzimg
        libmysofa
        fontconfig
        harfbuzz
        opus
        speex
        vorbis
        libxml2
        libvpl
        libopenmpt
        libjxl
        libplacebo
        libaribcaption
        aom
        svtav1
        dav1d
        vapoursynth
        ${ffmpeg_uavs3d}
        libva
        openal-soft
    GIT_REPOSITORY https://github.com/FFmpeg/FFmpeg.git
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_CLONE_FLAGS "--sparse --filter=tree:0"
    GIT_CLONE_POST_COMMAND "sparse-checkout set --no-cone /* !tests/ref/fate"
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} CONF=1 <SOURCE_DIR>/configure
        --cross-prefix=${TARGET_ARCH}-
        --prefix=${MINGW_INSTALL_PREFIX}
        --arch=${TARGET_CPU}
        --target-os=mingw32
        --pkg-config-flags=--static
        --enable-cross-compile
        --enable-runtime-cpudetect
        --enable-version3
        --enable-libfreetype
        --enable-libfribidi
        --enable-libfontconfig
        --enable-libharfbuzz
        --enable-openssl
        ${ffmpeg_video_libs}
        ${ffmpeg_audio_libs}
        ${ffmpeg_uavs3d_cmd}
        ${ffmpeg_hw_flags}
        --disable-doc
        --disable-ffplay
        --disable-ffprobe
        --disable-vdpau
        --disable-videotoolbox
        --disable-decoder=libaom_av1
        ${ffmpeg_variant_flags}
        ${ffmpeg_lto}
        --extra-cflags='-Wno-error=int-conversion'
        "--extra-libs='${ffmpeg_extra_libs}'" # -lstdc++ / -lc++ needs by libjxl and shaderc
    BUILD_COMMAND ${MAKE}
    INSTALL_COMMAND ${MAKE} install
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

force_rebuild_git(ffmpeg)
cleanup(ffmpeg install)
