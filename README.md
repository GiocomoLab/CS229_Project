# CS229_Project

This library was used to try to predict functional cell types in mouse medial entorhinal cortex using VR tetrode recordings of extracellular action potentials. 

To run code start to finish run Run_LOOCV_*.m in various folders. Make sure to edit the variables at the top of the scripts to get the desired comparisons and classifiers

Comparisons in base directory and data_augmentation all fail to predict above chance. gain_manip and drifty_bursters contain further experiments that do separate these cell classes with ~70% accuracy. Soft_DTW contains code to perform soft dynamic time warping and visualization of the results
