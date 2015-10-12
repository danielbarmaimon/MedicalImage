% Read info from dicom file
info = dicominfo('04534601.dcm');

% Storage the image of a dicom file
img = dicomread('04534601.dcm');

% Conversion of image from 'uint' to 'double'
% and reshape into column array
imgTotal = (double(img(:)'));

% Volume histogram
figure
hist(imgTotal, 400);
title('Volume histogram');

% Slice analysis
slice1=img(:,:,:,1);
figure(2)
imshow(slice1);