import os
import time
import streamlit as st
from modules.helpers import *
from urllib.parse import urlparse
from dotenv import find_dotenv, load_dotenv

load_dotenv(find_dotenv())

def main():

    VIDEO_DIR = "./data"
    os.makedirs(VIDEO_DIR, exist_ok=True)

    RESULTS_DIR = "./results"
    os.makedirs(RESULTS_DIR, exist_ok=True)

    FRAMES_DIR = f"{RESULTS_DIR}/frames"
    os.makedirs(FRAMES_DIR, exist_ok=True)

    # Language in the video for Azure Speech to Text
    language = "en-US"

    # Azure OpenAI GPT deployed model (choose your gpt4o deployed model name)
    model = "gpt-4o"

    st.title("SOP Document Generator")

    source_video_file = "https://raw.githubusercontent.com/retkowsky/samplesvideos/main/surgical_sop.mp4"
    src_video_file = st.text_input("Download following video file:", source_video_file)

    dst_video_file = st.text_input("Save video file to:", VIDEO_DIR)

    if st.button("Download video file"):

        if not os.path.isfile(dst_video_file):
            if "youtu" in src_video_file:
                video = download_youtube_video(src_video_file, dst_video_file)

                video_file = open(os.path.join(dst_video_file, video.default_filename), "rb")
                video_bytes = video_file.read()
                st.video(video_bytes)

            else:
                dst_video_file = os.path.join(VIDEO_DIR, os.path.basename(urlparse(src_video_file).path))
                download_file(src_video_file, dst_video_file)

                video_file = open(dst_video_file, "rb")
                video_bytes = video_file.read()
                st.video(video_bytes)

        # Display video file information
        file_name, file_size_mb, formatted_time = display_file_info(video_file.name)
        st.divider()
        st.markdown("### Video File Information")
        st.markdown(f"File: {file_name}")
        st.markdown(f"Size: {file_size_mb:.2f} MB")
        st.markdown(f"Last Modified: {formatted_time}")

        duration, total_frames, fps = get_video_info(video_file.name)
        hours = int(duration // 3600)
        minutes = int((duration % 3600) // 60)
        seconds = int(duration % 60)
        st.markdown(f"Duration: {duration:.0f} seconds".format(duration))
        st.markdown(f"Length of video: {hours:02}:{minutes:02}:{seconds:02}")
        st.markdown(f"Number of frames: {total_frames}")
        st.markdown(f"Frames per second (FPS): {fps:.0f}")

        # Display video file frames
        display_video_frames(video_file.name)

        # Extract audio from video file
        st.divider()
        st.markdown("### Audio file information")
        st.info("Extracting audio from video file")
        start = time.time()
        audio_file = get_audio_file(video_file.name, RESULTS_DIR)
        elapsed = time.time() - start
        st.markdown("Completed in " + time.strftime(
            "%H:%M:%S.{}".format(str(elapsed % 1)[2:])[:15], time.gmtime(elapsed)))
        # Display audio file information
        file_name, file_size_mb, formatted_time = display_file_info(audio_file)
        # st.markdown("### Audio File Information")
        st.markdown(f"File: {file_name}")
        st.markdown(f"Size: {file_size_mb:.2f} MB")
        st.markdown(f"Last Modified: {formatted_time}")
        st.markdown("#### Waveplot of audio file")
        display_amplitude(audio_file)

if __name__ == "__main__":
    main()