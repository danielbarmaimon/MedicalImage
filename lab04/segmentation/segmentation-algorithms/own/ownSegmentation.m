function [ outIm ] = ownSegmentation(imIn)
%Data Initialization
if size(imIn,3)>1 
  im=rgb2gray(imIn);
end

% Mask creation
mask = zeros(size(im));
mask(100:end-100,100:end-100) = 1;

bw = activecontour(im,mask,200);

% Find the largest componenent
[segImg, ~] = getLargestCc( logical( bw ), 4, 1);

% Fill holes just in case
segImg = imfill( segImg, 'holes' );

% Show the image
figure, imshow(segImg);
title('Segmented Image');
outIm = segImg;
end