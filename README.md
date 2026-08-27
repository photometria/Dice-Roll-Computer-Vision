# 🎲 Computer Vision Dice Roll Detector

A MATLAB program that uses a webcam to detect a physical dice roll and determine the number rolled.

This was part of a group project where we worked together to build a physical board game. My main responsibility was the **dice detection system**, which allowed the game to automatically determine the result of a physical dice roll.

## Overview

The basic process is:

1. Take a picture using a USB webcam.
2. Crop the image to the area where the die is located.
3. Separate the image into its RGB channels.
4. Use color ratios and thresholds to find the dice pips.
5. Clean up the resulting image to remove noise.
6. Find the individual pip regions.
7. Count the regions to determine the dice roll.

There is also a separate calibration script that uses two green markers to help check the camera's position relative to the game board.

---

## System Overview

```text
┌──────────────┐
│  USB Webcam  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Image Capture│
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ ROI Cropping │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ RGB Analysis │
└──────┬───────┘
       │
       ▼
┌────────────────────┐
│ Color Thresholding │
└──────────┬─────────┘
           │
           ▼
┌────────────────────┐
│ Image Processing   │
│ • Hole Filling     │
│ • Noise Removal    │
└──────────┬─────────┘
           │
           ▼
┌────────────────────┐
│Connected Components│
└──────────┬─────────┘
           │
           ▼
┌────────────────────┐
│    Pip Count       │
└────────────────────┘
```

---

## How the Dice Detection Works

### 1. Cropping the Image

The webcam sees more than just the dice tray, so the program first crops the image to the area where the die is expected to be.

```matlab
diceRegion = [4.99999999999993 235 305 242];
diceImage = imcrop(frame, diceRegion);
```

This keeps the program from processing unnecessary parts of the camera image.

The crop coordinates were chosen based on the camera position used for the game board.

### 2. RGB Channel Analysis

The cropped image is split into red, green, and blue channels.

```matlab
redLayer = double(diceImage(:,:,1));
greenLayer = double(diceImage(:,:,2));
blueLayer = double(diceImage(:,:,3));
```

The program then compares the channels using ratios:

```matlab
greenToRed = greenLayer ./ redLayer;
greenToBlue = greenLayer ./ blueLayer;
```

These ratios help separate the dark pip areas from the rest of the die.

### 3. Finding the Pips

A threshold is used to create a binary image:

```matlab
dotMask = greenToBlue <= 0.05 & greenToRed <= 0.05;
```

Pixels that meet the threshold are treated as part of a potential pip.

The result is essentially an image containing the areas that the program thinks are dice pips.

### 4. Cleaning the Image

The binary image is cleaned before counting the pips.

```matlab
dotMask = imfill(dotMask, 'holes');
dotMask = bwareaopen(dotMask, 50);
```

`imfill` fills holes in detected regions, while `bwareaopen` removes small regions that are likely to be noise.

### 5. Counting the Pips

After the image has been cleaned, `regionprops` is used to find the individual connected regions.

```matlab
dotTable = regionprops('table', dotMask, 'BoundingBox');
rollValue = height(dotTable);
```

The number of detected regions is used as the dice result.

For example, if five separate pip regions are detected, the program reports:

```text
Number rolled: 5
```

---

## Calibration

The project also includes a calibration script that uses two green reference markers placed on the game board.

The calibration process:

- Finds the green markers using RGB ratios.
- Removes small regions that are likely to be noise.
- Finds the bounding box of each marker.
- Calculates the center of each marker.
- Calculates the distance between the two marker centers.

The distance is calculated using the Euclidean distance formula:

```text
d = √((x₂ - x₁)² + (y₂ - y₁)²)
```

This was used to check the camera's position relative to the game board.

---

## Files

### `CalibrateScript.m`

Handles the camera calibration process.

It is responsible for:

- Connecting to the webcam
- Capturing an image
- Cropping the calibration area
- Detecting the green markers
- Removing small regions
- Finding marker bounding boxes
- Calculating marker centers
- Measuring the distance between the markers

### `FinalDiceRollScript.m`

Handles the actual dice detection.

It is responsible for:

- Connecting to the webcam
- Capturing an image
- Cropping the dice area
- Analyzing the RGB channels
- Creating the binary pip mask
- Removing noise
- Finding connected regions
- Counting the detected pips

---

## Why I Used This Approach

### RGB ratios

I used RGB ratios instead of just checking individual color values because the relative values between the channels helped separate the pips from the surrounding area.

### Region of interest

The camera captures a larger area than the program needs. Cropping the image makes the detection process simpler and reduces the chance of detecting something outside the dice area.

### Morphological processing

The camera can produce small unwanted regions in the binary image. `imfill` and `bwareaopen` help clean these up before the program tries to count the pips.

### Connected components

Once the pips have been separated from the background, each pip can be treated as its own connected region. Counting those regions provides the dice result.

---

## Limitations

The current version was designed around the physical setup used for our board game, so it is not intended to work with every possible dice or camera setup.

Some limitations are:

- The region of interest is fixed.
- The segmentation thresholds are fixed.
- Changing the camera position can require changing the crop coordinates.
- Large changes in lighting can affect detection.
- The system works best when the dice are clearly visible.
- Overlapping or partially hidden pips may not be detected correctly.
- The system currently focuses on detecting a single die.

---

## Possible Improvements

Some things I would improve in a future version include:

- Automatically finding the dice region
- Automatically calibrating the camera
- Using adaptive thresholds
- Adding perspective correction
- Improving detection under different lighting conditions
- Supporting multiple dice
- Processing the camera feed in real time
- Using pip shape and size as additional detection criteria
- Adding a confidence value to each detected roll
- Supporting different dice colors and game-board setups

---

## What I Learned

This project gave me experience with:

- Working with a webcam in MATLAB
- Capturing and processing images
- RGB color analysis
- Image segmentation
- Binary image processing
- Morphological operations
- Connected-component analysis
- Bounding boxes
- Distance calculations
- Debugging a computer vision system
- Connecting software to a physical game system

It also gave me experience working as part of a team on a larger project while being responsible for one specific part of the overall system.