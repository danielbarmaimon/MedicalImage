clear all
clc
tic;
%% Read the images
dataFilePathGT1 = fullfile(pwd,'images','gt','expert_1');
dataFilePathGT2 = fullfile(pwd,'images','gt','expert_2');
dataFilePathGT3 = fullfile(pwd,'images','gt','expert_3');

dataFilePathOriginal = fullfile(pwd,'images','original');

fileNamesGT1 = dir(fullfile(dataFilePathGT1,'*.png'));
fileNamesGT2 = dir(fullfile(dataFilePathGT2,'*.png'));
fileNamesGT3 = dir(fullfile(dataFilePathGT3,'*.png'));

fileNamesOriginal = dir(fullfile(dataFilePathOriginal,'*.JPG'));

% get number of images
N = numel(fileNamesGT1);
height = 387;                 
width = 632;
% read all images
data = zeros(height, width, 3*N);
for i=1:N    
    img = imread(fullfile(dataFilePathGT1,fileNamesGT1(i).name));
    data(:,:,i) = img;
end
for i=1:N 
    img = imread(fullfile(dataFilePathGT2,fileNamesGT2(i).name));
    data(:,:,i+N) = img;
end
for i=1:N 
    img = imread(fullfile(dataFilePathGT3,fileNamesGT3(i).name));
    data(:,:,i+2*N) = img;
end

%% Weight the images and fusion the masks
fusion = zeros(height, width, N);
for i=1:N
    fusion(:,:,i)=(data(:,:,i).*data(:,:,i+N))+(data(:,:,i).*data(:,:,i+2*N))+...
        (data(:,:,i+N).*data(:,:,i+2*N));
    A = fusion(:,:,i);
    %imwrite(A,strcat(fileNamesGT1(i).name));
    figure;
    imshow(A);
end
time = toc    