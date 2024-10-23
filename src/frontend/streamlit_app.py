'''
Streamlit app for VANTAGE Genie Accelerator
'''
import os
import time
import json
from urllib.parse import urlparse
import streamlit as st
import helpers
import pandas as pd

def main():

    VIDEO_DIR = "../data"
    os.makedirs(VIDEO_DIR, exist_ok=True)

    RESULTS_DIR = "../results"
    os.makedirs(RESULTS_DIR, exist_ok=True)

    FRAMES_DIR = f"{RESULTS_DIR}/frames"
    os.makedirs(FRAMES_DIR, exist_ok=True)

    # Language in the video for Azure Speech to Text
    language = "en-US"

    st.title("VANTAGE Genie Accelerator")
    st.markdown("#### (Video Analysis, Notation, Transcription, and Generation Engine)")

    source_video_file = "https://raw.githubusercontent.com/retkowsky/samplesvideos/main/forklift_checklist.mp4"
    src_video_file = st.text_input("Process video file from:", source_video_file)
    dst_video_folder = st.text_input("Save video file to:", VIDEO_DIR)

    if st.button("Start processing"):
        st.divider()
        
        # Download YouTube video
        if "youtu" in src_video_file:
            st.info(f"It seems you are trying to download file from YouTube. That is currently not supported. Please select different video file.")
            st.stop()

        # Download video from direct link
        else:
            dst_video_file = os.path.join(dst_video_folder, os.path.basename(urlparse(src_video_file).path))
            if not os.path.isfile(dst_video_file):
                st.info(f"Downloading {src_video_file}")
                start = time.time()
                helpers.download_file(src_video_file, dst_video_file)
                elapsed = time.time() - start
                st.info("Completed in " + time.strftime(
                    "%H:%M:%S.{}".format(str(elapsed % 1)[2:])[:15], time.gmtime(elapsed)))
            else:
                st.info(f"Using local copy because {src_video_file} has already been previously downloaded")

        video_file = open(dst_video_file, "rb")
        video_bytes = video_file.read()
        st.video(video_bytes)

        # Display video file information
        file_name, file_size_mb, formatted_time = helpers.display_file_info(video_file.name)
        duration, total_frames, fps = helpers.get_video_info(video_file.name)
        hours = int(duration // 3600)
        minutes = int((duration % 3600) // 60)
        seconds = int(duration % 60)
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

        # Extract audio from video file
        st.divider()
        audio_file = os.path.join(
            RESULTS_DIR,
            os.path.splitext(os.path.basename(video_file.name))[0] + ".wav"
            )
        if not os.path.isfile(audio_file):
            st.info("Extracting audio from video file")
            start = time.time()
            audio_file = helpers.get_audio_file(video_file.name, RESULTS_DIR)
            elapsed = time.time() - start
            st.info("Completed in " + time.strftime(
                "%H:%M:%S.{}".format(str(elapsed % 1)[2:])[:15], time.gmtime(elapsed)))
        else:
            st.info(f"Using local copy because {audio_file} has already been extracted")

        # Transcribe audio file using Azure Speech to Text
        st.divider()
        st.info("Transcribing audio file to text")
        start = time.time()
        transcript, confidence, words = helpers.azure_text_to_speech(audio_file, language)
        elapsed = time.time() - start
        st.info("Completed in " + time.strftime(
            "%H:%M:%S.{}".format(str(elapsed % 1)[2:])[:15], time.gmtime(elapsed)))
        df = pd.DataFrame(words, columns=["Word", "Offset", "Duration", "Confidence"])
        df["Offset_in_secs"] = df["Offset"] / 10_000_000
        df["Duration_in_secs"] = df["Duration"] / 10_000_000
        transcript_file = os.path.join(
            RESULTS_DIR,
            os.path.splitext(os.path.basename(video_file.name))[0] + ".txt"
            )
        df.to_csv(transcript_file)

        # Create SOP document structure using Azure AI
        st.divider()
        st.info("Creating SOP document structure")
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
        completion = helpers.ask_gpt4o(prompt, sop_text)
        elapsed = time.time() - start
        st.info("Completed in " + time.strftime(
            "%H:%M:%S.{}".format(str(elapsed % 1)[2:])[:15], time.gmtime(elapsed)))

        # Create SOP document in Microsoft Word format
        st.divider()
        st.info("Creating SOP document in Microsoft Word format")
        json_data = json.loads(completion)["Steps"]
        start = time.time()
        docx_file = helpers.checklist_docx_file(video_file.name, json_data, RESULTS_DIR, 1)
        elapsed = time.time() - start
        st.info("Completed in " + time.strftime(
            "%H:%M:%S.{}".format(str(elapsed % 1)[2:])[:15], time.gmtime(elapsed)))

        # Download SOP document
        @st.fragment
        def download_sop_document(docx_file):
            with open(docx_file, 'rb') as f:
                st.download_button('Download SOP document', f, file_name=os.path.basename(docx_file)) 
        download_sop_document(docx_file)
        
if __name__ == "__main__":
    main()