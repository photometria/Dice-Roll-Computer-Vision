```matlab
clear;
clc;

% locate all connected webcams
availableCameras = webcamlist;

% connect to the selected usb camera
camera = webcam("USB Camera");

% show a live preview before capturing the image
preview(camera);
pause(3);

% capture a single frame from the camera
frame = snapshot(camera);

% define the section of the tray that should be analyzed
trayCrop = [349 79 368 433];

% isolate the tray from the rest of the image
trayImage = imcrop(frame, trayCrop);

% separate the three rgb color channels
red = double(trayImage(:,:,1));
green = double(trayImage(:,:,2));
blue = double(trayImage(:,:,3));

% calculate color ratios used to identify the green markers
greenRed = green ./ red;
greenBlue = green ./ blue;

% replace undefined ratio values with zero
greenRed(isnan(greenRed)) = 0;
greenBlue(isnan(greenBlue)) = 0;

% create a binary mask for pixels matching the marker color
markerMask = greenRed >= 1.5;

% discard small regions that are unlikely to be markers
markerMask = bwareaopen(markerMask, 1000);

% close empty regions inside detected objects
markerMask = imfill(markerMask, 'holes');

% show the resulting marker mask
imshow(markerMask);

% obtain the bounding boxes of all detected marker regions
markerData = regionprops('table', markerMask, 'BoundingBox');
boxes = markerData{:,:};

% determine how many markers were found
markerCount = size(boxes, 1);

if markerCount == 1
    disp('System is calibrated.');

elseif markerCount == 2
    % calculate the center point of each detected marker
    markerCenters = zeros(2, 2);

    for k = 1:2
        left = boxes(k, 1);
        top = boxes(k, 2);
        boxWidth = boxes(k, 3);
        boxHeight = boxes(k, 4);

        markerCenters(k,:) = [left + boxWidth/2, ...
                              top + boxHeight/2];
    end

    % measure the straight-line distance between the marker centers
    horizontalDifference = markerCenters(2,1) - markerCenters(1,1);
    verticalDifference = markerCenters(2,2) - markerCenters(1,2);

    markerDistance = sqrt(horizontalDifference^2 + verticalDifference^2);

    % print the measured distance to the command window
    disp(['Distance between the two green squares: ', ...
          num2str(markerDistance)]);

else
    % report an unexpected marker count
    disp('Unexpected number of markers detected. Check the system.');
end
```