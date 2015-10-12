%% Example use of the NIFTI file reader and evaluation
% Robert Martí (robert.marti@eia.ugd.edu)
% Medical Image Analysis, Master VIBOT 2014.
% Final Project.

close all;
% patient files: original, ground truth and segmentation.
gt_nii = load_untouch_nii('LabelsForTesting.nii', [],[]);
t1_nii = load_untouch_nii('T1.nii', [],[]);
t1_seg = t1_nii;
%% YOUR ALGORITHM WOULD GO HERE
% Here you would do your segmentation algorithm obtaining the 
% segmented image segIm (now externally read).

dimensions = size(t1_nii.img);
for (i=1:dimensions(3))
    se = strel('line',5,5);
    imatge = gt_nii.img(:,:,i); % 16 bits
    segmented = imerode(uint8(imatge),se);
    t1_seg.img(:,:,i) = uint16(segmented);
% 
%     figure; 
%     imshow(segmented, []);
%      figure;
%      imshow(t1_nii.img(:,:,i),[]);
%      figure;
%      imshow(gt_nii.img(:,:,i),[]);
%     pause();

end;

%% END OF YOUR ALGORITHM.

save_untouch_nii(t1_seg,'segmented.nii');

%Evaluate the segmentation of a given label.
label = 1;
for (label= 1:3)
    [Jaccard(label), Dice(label), rfp(label), rfn(label)] = sevaluate(gt_nii.img,t1_seg.img, label);
%    [Jaccard, Dice, rfp, rfn] = sevaluate(gt_nii.img,gt_nii.img, label)
end;
Jaccard 
Dice
rfp
rfn

