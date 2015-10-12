function [ imgOut ] = postSegmentation( img )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
im = img;
im(:,:,:)=0;
im(10:end-10,10:end-10) = 0; % Remove the borders
[ imOut,numRegions, time ] = regionGrowing(im,0.5,8)    % Get the regions
[counts, x] = imhist(imOut);
[maxValue, maxIndex]= find(max(counts));
im=(im==(x(maxIndex)));
%counts(maxIndex)=0;
%[maxValue maxIndex]= find(max(counts));
imgOut = im;
end

