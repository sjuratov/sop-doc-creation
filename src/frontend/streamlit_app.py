import os
import time
import json
import streamlit as st
#import sys
from urllib.parse import urlparse
#from dotenv import find_dotenv, load_dotenv
from pytubefix import YouTube
from pytubefix.cli import on_progress

#sys.path.append('../')
from helpers import *

def main():

    VIDEO_DIR = "../data"
    os.makedirs(VIDEO_DIR, exist_ok=True)

    RESULTS_DIR = "../results"
    os.makedirs(RESULTS_DIR, exist_ok=True)

    FRAMES_DIR = f"{RESULTS_DIR}/frames"
    os.makedirs(FRAMES_DIR, exist_ok=True)

    # Language in the video for Azure Speech to Text
    language = "en-US"

    # Azure OpenAI GPT deployed model 
    # Defined in infra/main.bicep as '<model>-<version>'
    # Shall be defined in .env file?
    # model = "gpt-4o-2024-05-13"
    model = "gpt-4o-mini"

    st.title("SOP Document Generator")

    source_video_file = "https://raw.githubusercontent.com/retkowsky/samplesvideos/main/surgical_sop.mp4"
    src_video_file = st.text_input("Download following video file:", source_video_file)

    dst_video_folder = st.text_input("Save video file to:", VIDEO_DIR)

    if st.button("Download video file"):

#        if not os.path.isfile(dst_video_file):
        if "youtu" in src_video_file:
            youtube = YouTube(src_video_file, on_progress_callback = on_progress)
            video = youtube.streams.get_highest_resolution()
            dst_video_file = os.path.join(dst_video_folder, video.default_filename)
            if not os.path.isfile(dst_video_file):
                video = download_youtube_video(src_video_file, dst_video_folder)

            video_file = open(dst_video_file, "rb")
            video_bytes = video_file.read()
            st.video(video_bytes)

        else:
            dst_video_file = os.path.join(dst_video_folder, os.path.basename(urlparse(src_video_file).path))
            if not os.path.isfile(dst_video_file):
                download_file(src_video_file, dst_video_file)

            video_file = open(dst_video_file, "rb")
            video_bytes = video_file.read()
            st.video(video_bytes)

        # Display video file information
        file_name, file_size_mb, formatted_time = display_file_info(video_file.name)
        duration, total_frames, fps = get_video_info(video_file.name)
        hours = int(duration // 3600)
        minutes = int((duration % 3600) // 60)
        seconds = int(duration % 60)

        st.divider()
        video_file_info = f"""
        ### Video File Information \n
        Source: <{src_video_file}>  \n
        Destination: {file_name} \n
        Size: {file_size_mb:.2f} MB \n
        Last Modified: {formatted_time} \n
        Duration: {duration:.0f} seconds \n
        Length of video: {hours:02}:{minutes:02}:{seconds:02} \n
        Number of frames: {total_frames} \n
        Frames per second (FPS): {fps:.0f}
        """
        st.info(video_file_info)
        # st.markdown("### Video File Information")
        # st.markdown(f"File: {file_name}")
        # st.markdown(f"Size: {file_size_mb:.2f} MB")
        # st.markdown(f"Last Modified: {formatted_time}")
        # st.markdown(f"Duration: {duration:.0f} seconds".format(duration))
        # st.markdown(f"Length of video: {hours:02}:{minutes:02}:{seconds:02}")
        # st.markdown(f"Number of frames: {total_frames}")
        # st.markdown(f"Frames per second (FPS): {fps:.0f}")

        # Display video file frames
        # display_video_frames(video_file.name)

        # Extract audio from video file
        st.divider()
        #st.markdown("### Audio file information")
        st.info("Extracting audio from video file")
        start = time.time()
        audio_file = get_audio_file(video_file.name, RESULTS_DIR)
        elapsed = time.time() - start
        st.info("Completed in " + time.strftime(
            "%H:%M:%S.{}".format(str(elapsed % 1)[2:])[:15], time.gmtime(elapsed)))
        # Display audio file information
        #file_name, file_size_mb, formatted_time = display_file_info(audio_file)
        # st.markdown("### Audio File Information")
        #st.markdown(f"File: {file_name}")
        #st.markdown(f"Size: {file_size_mb:.2f} MB")
        #st.markdown(f"Last Modified: {formatted_time}")
        #st.markdown("#### Waveplot of audio file")
        #display_amplitude(audio_file)

        # Transcribe audio file using Azure Speech to Text
        st.divider()
        #st.markdown("### Extract text from audio file")
        st.info("Transcribing audio file")
        start = time.time()
        transcript, confidence, words = azure_text_to_speech(audio_file, language)
        elapsed = time.time() - start
        st.info("Completed in " + time.strftime(
            "%H:%M:%S.{}".format(str(elapsed % 1)[2:])[:15], time.gmtime(elapsed)))
        #transcript_text = ' '.join(transcript)
        #st.markdown(f"Transcript text lenght: {len(transcript_text)}")
        #st.markdown(f"Transcript: {transcript_text}")

        #st.markdown("#### Text transcript with confidence level")
        df = pd.DataFrame(words, columns=["Word", "Offset", "Duration", "Confidence"])
        df["Offset_in_secs"] = df["Offset"] / 10_000_000
        df["Duration_in_secs"] = df["Duration"] / 10_000_000
        #st.dataframe(df, use_container_width=True)

        transcript_file = os.path.join(
            RESULTS_DIR,
            os.path.splitext(os.path.basename(video_file.name))[0] + ".txt"
            )

        df.to_csv(transcript_file)
        #st.info(f"Transcript saved to {transcript_file}")

        # Create SOP structure using Azure OpenAI
        st.divider()
        #st.markdown("### Create SOP structure using Azure OpenAI")
        st.info("Processing transcribed text using LLM ...")
        sop_text = df.to_json(orient="records")
        prompt = """
        Describe the main steps of this checklist document.
        Extract all the specific steps. Please be precise and concise.

        ### Output must have following properties:
        - Step: step number
        - Title: Generate a simple summary of the step
        - Summary: Generate a summary of the step in 2 or 3 lines
        - Keywords: generate some keywords to explain the step
        - Offset: offset
        - Offset_in_secs: offset in seconds

        ### Here is an example:
        {
            "Steps": [
                {
                    "Step": 1,
                    "Title": "Introduction",
                    "Summary": "Provide an overview of the checklist document, including its purpose and scope.",
                    "Keywords": [
                        "overview",
                        "purpose",
                        "scope"
                    ],
                    "Offset": 5900000,
                    "Offset_in_secs": 0.59
                },
                {
                    "Step": 2,
                    "Title": "Preparation",
                    "Summary": "Outline the necessary preparations before starting the main tasks, such as gathering materials and setting up the environment.",
                    "Keywords": [
                        "preparation",
                        "materials",
                        "setup"
                    ],
                    "Offset": 183300000,
                    "Offset_in_secs": 18.33
                }
            ]
        }
        """

        start = time.time()
        completion = ask_gpt4o(prompt, sop_text, model)
        elapsed = time.time() - start
        st.info("Completed in " + time.strftime(
            "%H:%M:%S.{}".format(str(elapsed % 1)[2:])[:15], time.gmtime(elapsed)))
        #st.markdown(f"Completion: {completion}")
        #df = pd.DataFrame.from_dict(json.loads(completion)['steps'])
        #st.dataframe(df, use_container_width=True)

        # Create SOP in Microsoft Word format
        st.divider()
        #st.markdown("### Create SOP in Microsoft Word format")
        st.info("Processing transcribed text and video ...")
        json_data = json.loads(completion)["Steps"]
        start = time.time()
        docx_file = checklist_docx_file(video_file.name, json_data, RESULTS_DIR, model, 1)
        elapsed = time.time() - start
        st.info("Completed in " + time.strftime(
            "%H:%M:%S.{}".format(str(elapsed % 1)[2:])[:15], time.gmtime(elapsed)))
        st.info(f"SOP saved to {docx_file}")
        

if __name__ == "__main__":
    main()