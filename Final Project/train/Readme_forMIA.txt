For each patient, the following MRI scans are provided:

1. T1.mhd:        3D T1-weighted scan registered to the T2 FLAIR (voxel size: 0.958mm x 0.958mm x 3.0mm)
2. T2_FLAIR.mhd:  Multi-slice FLAIR scan (voxel size: 0.958mm x 0.958mm x 3.0mm)

All scans are bias corrected, and scans 1-2 are aligned. This is done to eliminate the influence of different registration and bias correction algorithms on the segmentation results. The manual labeling is done on scans 1-2. The face of the patient is cut out of the 3D T1-weighted scan for the purpose of anonymization. 

For the training data, we also provided labels that can be used for testing (LabelsForTesting.mhd), in which only the following structures are labeled:

1. Cerebrospinal fluid (including ventricles)
2. Gray matter (cortical gray matter and basal ganglia)
3. White matter (including white matter lesions)

The brainstem and cerebellum are excluded from the evaluation and therefore labeled as background. This file can also be used as an example of what the results of your segmentation method should look like, when you submit your results. However, in your result file it does not matter whether the cerebellum and brainstem are labeled as background, white matter, gray matter or cerebrospinal fluid, because they will not be included in the evaluation. 

Notes on the manual segmentations:
-----------------------------------
* White matter lesions were segmented on the FLAIR scan
* The outer border of the CSF was segmented using the T1-weighted scan.  
* All other structures were segmented on the T1-weighted scan.
* Vessels were not segmented separately. The CSF segmentation therefore also includes the superior sagittal sinus and transverse sinuses. 
* The cerebral falx is also included in the CSF segmentation.


