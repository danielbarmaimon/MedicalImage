function project(fileName,maskName, groundT)
	%Add path for functions
	addpath('NifTI_20140122'); % :)
	addpath('matlabFiles');
	%Load the mask and image
	mask=load_nii_ours(maskName);
	image=load_nii_ours(fileName);
    ground=load_nii_ours(groundT);
	%Check the size of the mask
	if(~isequal(size(mask.img),size(image.img)))
		error('Size of mask and image should be same! Learn something first you idiot!')
	end
	%Remove the skull
	brain=mask.img.*image.img;
	brain_nii=make_nii(brain,image.hdr.dime.pixdim(2:4));
	
	%Perform segmentation here
    
    % Getting the volume histogram
     [histo3D, centers3D]= hist(double(brain_nii.img(:)'),255);
     [sortedHist3D indices3D]=sort(histo3D,'descend');     
     histo3D(indices3D(1))=0;          % Remove background from histogram
     len3D = size(histo3D,2);
     index3D = zeros(1, len3D);
     for j=1:len3D
         index3D(j)=j; 
     end
     subplot(2,2,3), bar(index3D, histo3D,0);
    
     % Smooth the histogram of the 3D volume
     histo3D = smooth(histo3D,5);
     H=line(index3D,histo3D,'Color', 'r'); %Plot the smoothed line
     
    % Get the peaks with non-maximum supression
    [sortedHist3D indices3D]=sort(histo3D,'descend'); % To be sure that background doesn't appear
    [ points3D ] = nonMaxSuppression(sortedHist3D, histo3D, 75)
    for j=1:size(points3D,2)
        line ([points3D(j),points3D(j)],[1, histo3D(points3D(1))+5], 'Color', 'g');
    end
    points3D=sort(points3D)
    
    % Finding the minimum of the valley. Finding threshold for region
    lowerLimits3D = zeros(1,3);
    upperLimits3D = zeros(1,3);
    greyLevel = 1;
    lowerLimits3D(1) = 1; % Threshold to remove background. CHANGE VARIABLE NAME SINCE THE BEGINNING
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
       upperLimits3D(j)=origin+idx;            
       if j>1
           lowerLimits3D(j)=upperLimits3D(j-1);
       end
   
       % Setting labels for each region
       %if(greyLevel==1)
       % upperLimits3D(j)=upperLimits3D(j);
       % lowerLimits3D(j+1)=lowerLimits3D(j+1);
       imCopy((lowerLimits3D(j)/255<image1)&(image1<=upperLimits3D(j)/255))=greyLevel;
       
       %else
       %imCopy((lowerLimits3D(j)/255<image1)&(image1<=upperLimits3D(j)/255))=greyLevel;
           
       %end
       greyLevel = greyLevel + 1;  
    end
    
    % Changing the model into slices to apply morphological operations
    imCopy = reshape(imCopy,size(brain_nii.img,1),size(brain_nii.img,2),size(brain_nii.img,3));
    imCopy_nii = make_nii(int16(imCopy),image.hdr.dime.pixdim(2:4));
    imCopy =mask.img.*imCopy_nii.img; % Just to be sure we remove the background
    pause;
    for i=1:size(brain_nii.img,3)
        currSlice = brain_nii.img(:,:,i);
        currCopy = imCopy(:,:,i);
        subplot(2,2,1), subimage(mat2gray(currSlice));
        se = strel('square',2); % Structural element for opening
        imCopy(:,:,i) = imclose(currCopy, se);
        subplot(2,2,2), subimage(label2rgb(imCopy(:,:,i)));
        subplot(2,2,4), subimage(label2rgb(ground.img(:,:,i)));
        hold off;
        pause; 
    end
    
    
    %save_untouch_nii(imCopy_nii,'segmented.nii');

    %Evaluate the segmentation of a given label.
    label = 1;
    for (label= 1:3)
        [Jaccard(label), Dice(label), rfp(label), rfn(label)] = sevaluate(ground.img,imCopy_nii.img, label);
    %    [Jaccard, Dice, rfp, rfn] = sevaluate(gt_nii.img,gt_nii.img, label)
    end;
    Jaccard 
    Dice
    rfp
    rfn

end       

function [nii]=load_nii_ours(filename)
	%Load mask
   %  Read the dataset header
   [nii.hdr,nii.filetype,nii.fileprefix,nii.machine] = load_nii_hdr(filename);

   %  Read the header extension
   %
	%   nii.ext = load_nii_ext(filename);

   %  Read the dataset body
   %
   [nii.img,nii.hdr] = load_nii_img(nii.hdr,nii.filetype,nii.fileprefix, ...
		nii.machine);

end

function [histo]=plot_hist(img,ploton)
	if(nargin==1)
		ploton=false;
	end
   img = double(img(:));

   if length(unique(round(img))) == length(unique(img))
      is_integer = 1;
      range = max(img) - min(img) + 1;
      if(ploton)
      	figure; hist(img, range);
      	histo=[];
      	set(gca, 'xlim', [-range/5, max(img)]);
      	xlabel('Voxel Intensity');
   		ylabel('Voxel Numbers for Each Intensity');
   		set(gcf, 'NumberTitle','off','Name','Histogram Plot');
      else
      	histo=hist(img,range);
      end
      
   else
      is_integer = 0;
      if(ploton)
      	figure; hist(img);
      	histo=[];
      	xlabel('Voxel Intensity');
   		ylabel('Voxel Numbers for Each Intensity');
   		set(gcf, 'NumberTitle','off','Name','Histogram Plot');
      else
		histo=hist(img);
      end

   end
end

function [ points ] = nonMaxSuppression(sortedValues, hist, interval)
% interval should be and odd number to remove what it surrounding maximum

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

