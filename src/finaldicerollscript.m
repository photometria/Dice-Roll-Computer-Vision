```matlab
clear;
clc;

% retrieve the webcams connected to the computer
cameraList = webcamlist;

% select the camera used for dice detection
camera = webcam("USB Camera");

% display the camera feed while the tray is positioned
preview(camera);
pause(3);

% take a snapshot for processing
frame = snapshot(camera);

% specify the portion of the image containing the dice tray
diceRegion = [4.99999999999993 235 305 242];

% crop the captured frame to the selected region
diceImage = imcrop(frame, diceRegion);

% extract the individual rgb channels
redLayer = double(diceImage(:,:,1));
greenLayer = double(diceImage(:,:,2));
blueLayer = double(diceImage(:,:,3));

% determine the color ratios used to locate the dice dots
greenToRed = greenLayer ./ redLayer;
greenToBlue = greenLayer ./ blueLayer;

% replace invalid ratio results with zero
greenToRed(isnan(greenToRed)) = 0;
greenToBlue(isnan(greenToBlue)) = 0;

% identify pixels that match the dark color of the dice dots
dotMask = greenToBlue <= 0.05 & greenToRed <= 0.05;

% fill enclosed gaps within detected regions
dotMask = imfill(dotMask, 'holes');

% remove small regions caused by image noise
dotMask = bwareaopen(dotMask, 50);

% locate each individual detected dot
dotRegions = regionprops(dotMask, 'BoundingBox');

if isempty(dotRegions)
    % indicate that no dice markings were found
    disp('No dice dots were detected.');

else
    % count the detected regions to determine the dice result
    dotTable = regionprops('table', dotMask, 'BoundingBox');
    rollValue = height(dotTable);

    disp(['Number rolled: ', num2str(rollValue)]);

    % display the binary detection image and calculated roll
    figure;
    imshow(dotMask);
    title(['Dice Roll Result: ', num2str(rollValue)]);
end
```
