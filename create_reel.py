import subprocess
import os

def create_reel():
    # Define paths
    base_dir = os.getcwd()
    logo_path = os.path.join(base_dir, 'assets/logo/BanjaraBio.png')
    about_path = os.path.join(base_dir, 'assets/reel_about_slide.png') # This will be the generated image
    output_path = os.path.join(base_dir, 'my_first_reel.mp4')
    
    # Check if files exist
    if not os.path.exists(logo_path):
        print(f"Error: Logo not found at {logo_path}")
        return
    
    # Wait for the about slide if it's being generated (though in this flow it should exist)
    if not os.path.exists(about_path):
        print(f"Warning: About slide not found at {about_path}. Using logo for second slide as fallback text.")
        about_path = logo_path 

    print("Generating Instagram Reel...")

    # FFmpeg command
    # 1. Input logo (loop 2 sec)
    # 2. Input about slide (loop 3 sec)
    # 3. Filter:
    #    - [0] Scale to 1080 width, keep aspect, pad to 1080x1920, set SAR to 1/1
    #    - [1] Scale to 1080 width, keep aspect, pad to 1080x1920, set SAR to 1/1
    #    - Concat n=2:v=1:a=0
    
    cmd = [
        'ffmpeg',
        '-y', # Overwrite output
        '-loop', '1', '-t', '2', '-i', logo_path,
        '-loop', '1', '-t', '3', '-i', about_path,
        '-filter_complex',
        '[0:v]scale=1080:-1:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=white,setsar=1[v0];'
        '[1:v]scale=1080:-1:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=white,setsar=1[v1];'
        '[v0][v1]concat=n=2:v=1:a=0[outv]',
        '-map', '[outv]',
        '-c:v', 'libx264',
        '-pix_fmt', 'yuv420p',
        '-r', '30',
        output_path
    ]

    try:
        subprocess.run(cmd, check=True)
        print(f"Success! Video created at: {output_path}")
    except subprocess.CalledProcessError as e:
        print(f"Error running ffmpeg: {e}")

if __name__ == "__main__":
    create_reel()
