# GitHub Upload Guide — Step by Step

## STEP 1 — Create GitHub Account
Go to https://github.com and sign up if you don't have account.

## STEP 2 — Create New Repository
1. Click the + button top right
2. Click "New repository"
3. Repository name: fpga-image-processing
4. Description: Real-time image processing on FPGA — Cyclone V, VHDL, 800x480 LCD
5. Set to PUBLIC
6. Check "Add a README file" = NO (we have our own)
7. Click "Create repository"

## STEP 3 — Install Git on Windows
Go to https://git-scm.com/download/win
Download and install. Use all default settings.

## STEP 4 — Open Git Bash
Press Windows key, search "Git Bash", open it.

## STEP 5 — Configure Git (first time only)
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

## STEP 6 — Clone your empty repository
git clone https://github.com/YOUR_USERNAME/fpga-image-processing.git
cd fpga-image-processing

## STEP 7 — Copy all project files into the cloned folder
Copy these folders into E:\fpga-image-processing\
- src\         (all VHDL files)
- scripts\     (convert_to_mif.py)
- docs\        (pin_assignments.md, timing_parameters.md)
- README.md
- .gitignore

## STEP 8 — Add all files to Git
git add .
git status

## STEP 9 — Commit
git commit -m "Initial commit: FPGA image processing system with LCD display"

## STEP 10 — Push to GitHub
git push origin main

## STEP 11 — Check your GitHub page
Open https://github.com/YOUR_USERNAME/fpga-image-processing
You will see your professional project page!
