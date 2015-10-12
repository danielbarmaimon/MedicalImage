function project2(fileName,maskName, groundT)
	%Add path for functions
	addpath(genpath('NIfTI_20140122'));  
	addpath(genpath('matlabFiles'));
    addpath(genpath('train'));
   
    %Load the mask and image
   	mask=load_nii_ours(maskName);
	image=load_nii_ours(fileName);
    ground=load_nii_ours(groundT);
	
    %Check the size of the mask
	if(~isequal(size(mask.img),size(image.img)))
		error('Size of mask and image should be same.')
    end
    
    %Remove the skull
	brain=mask.img.*image.img;
	brain_nii=make_nii(brain,image.hdr.dime.pixdim(2:4));
	
	% Getting the volume histogram
    numBins = 256;
    [histo3D, centers3D]= hist(double(brain_nii.img(:)'),numBins);
    [sortedHist3D indices3D]=sort(histo3D,'descend'); 
    background_idx = indices3D(1);
    histo3D(background_idx)=0;          % Remove background from histogram
    index3D = (1:numBins);
    subplot(2,2,3), pause;
    bar(index3D, histo3D,0);
    title('Volume Histogram');
    % Smooth the histogram of the 3D volume
    histo3D = smooth(histo3D,7);
    H=line(index3D,histo3D,'Color', 'r'); %Plot the smoothed line
     
    % Get the peaks with non-maximum supression
    [sortedHist3D indices3D]=sort(histo3D,'descend'); % Resort after removing background
    [ points3D ] = nonMaxSuppression(sortedHist3D, histo3D, 75);
    for j=1:size(points3D,2)
        line ([points3D(j),points3D(j)],[1, histo3D(points3D(1))+5], 'Color', 'g');
    end
    points3D=sort(points3D);
    
    % Finding the minimum of the valley. Finding threshold for region
    lowerLimits3D = zeros(1,3);
    upperLimits3D = zeros(1,3);
    greyLevel = 1;
    lowerLimits3D(1) = background_idx; % Threshold to remove background. CHANGE VARIABLE NAME SINCE THE BEGINNING
    imCopy = zeros(size(brain_nii.img(:)'));
    image1 = mat2gray(brain_nii.img(:)');
    for j = 1:3
       origin = points3D(j);
       if j<3
           final = points3D(j+1); 
       else
           final = numel(histo3D);
       end 
       [val, idx]=min(histo3D(origin:final));
       
       % The following constants were obtained empirically
       if j == 3
           const = 1;
           upperLimits3D(j)= 256 ;
       else
           const = 1;
           upperLimits3D(j)=origin+idx +const;
       end
       
       
       if j>1
           lowerLimits3D(j)=(upperLimits3D(j-1))+const;
       end
   
       % Setting labels for each region
       imCopy((lowerLimits3D(j)/256<image1)&(image1<=upperLimits3D(j)/256))=greyLevel;
       greyLevel = greyLevel + 1;  
    end
    
    % Changing the model into slices to apply morphological operations
    imCopy = reshape(imCopy,size(brain_nii.img,1),size(brain_nii.img,2),size(brain_nii.img,3));
 
    for i=1:size(brain_nii.img,3)
        currSlice = brain_nii.img(:,:,i);
        currCopy = imCopy(:,:,i);
        subplot(2,2,1), subimage(mat2gray(currSlice));
        se = strel('square',1); % Structural element for opening
        imCopy(:,:,i) = imclose(currCopy, se);
        title('Original Image');
        subplot(2,2,2), subimage(label2rgb(imCopy(:,:,i)));
        title('Segmented Image');
        subplot(2,2,4), subimage(label2rgb(ground.img(:,:,i)));
        title('Ground Truth');
        hold off;
        pause; 
    end
    imCopy_nii = make_nii(int16(imCopy),image.hdr.dime.pixdim(2:4));
    imCopy =mask.img.*imCopy_nii.img; % Just to be sure we remove the background
    save_nii(imCopy_nii,'3_5.nii');
    
    %Evaluate the segmentation of a given label.
    Jaccard=zeros(1,3);
    Dice=zeros(1,3);
    rfp=zeros(1,3);
    rfn=zeros(1,3);
    for label= 1:3
        [Jaccard(label), Dice(label), rfp(label), rfn(label)] = sevaluate(ground.img,imCopy_nii.img, label);
    end;
    Jaccard 
     Dice
     rfp
     rfn

end       

function [nii]=load_nii_ours(filename)
% Description: The function will load the image in format '.nii', returning
% a structure with the image an features needed to work. Modification of
% the function 'load_nii' inside the package 'NIfTI_20140122'.
% Inputs:
%           filename:   Fullpath and name of the file in format '.nii'
% Outputs:
%            nii: Structure for the image. It contents the header for the
%                 file, filetype, fileprefix(path inside workspace), machine,
%                 and image.
   %  Read the dataset header
   [nii.hdr,nii.filetype,nii.fileprefix,nii.machine] = load_nii_hdr(filename);

   %  Read the dataset body
   [nii.img,nii.hdr] = load_nii_img(nii.hdr,nii.filetype,nii.fileprefix, ...
		nii.machine);

end

function [ points ] = nonMaxSuppression(sortedValues, hist, interval)
% Description: The function will return the three indices of the three
% highst peaks for a given data set.
% Inputs:
%           sortedValues:   Sorted (descend) indexes of the original data
%           hist:           Original data to find the maxima
%           interval:       Odd number of size of neighbourhood to remove
% Outputs:
%           points:         Array with the indices of the three upper peaks 
%                           after suppresion
points = zeros(1,3);        % Three peaks values (the maximum)
n = size(hist,1);
A1 = hist;
counter = 1;
iterator = 1;
side = (interval - 1)/2;
while (counter<4)   
    maxValue=find((A1==sortedValues(iterator,1)),1,'first');
    if (isempty(sortedValues(maxValue))== 0)
        x = maxValue;
        points(:,counter)=x;
        minX = max(1, x - side);
        maxX = min(n, x + side);
        A1(minX:maxX)=0;
        counter = counter +1;
    end
    iterator = iterator +1;
end
end

