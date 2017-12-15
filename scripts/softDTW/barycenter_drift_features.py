# make a set of features from the barycenter average of the time series.
# calculate the distance of each trial from the bary center.
# give the distance a sign based on the center of mass of the single trial
# alignment matrix and fit a line to the resulting vector. Drift is
# presumed to accumulate over time
import scipy.io as sio
import os
import numpy as np
from glob import glob
import json
from twpca import TWPCA
import matplotlib.pyplot as plt
import pickle
from sdtw.distance import SquaredEuclidean
from scipy.stats import linregress
from scipy.signal import correlate


baseDir = "/Users/markplitt/Dropbox/Malcolms_VR_data/twPCA_Mats/"
files = glob(baseDir+"twPCA_*.mat")
cell_suffix = [i.split(baseDir+"twPCA_")[1] for i in files]
cell_suffix = [i.split(".mat")[0] for i in cell_suffix]


for i, fname  in enumerate(files):
    # load data
    print(fname)
    matDat = sio.loadmat(fname)
    fdirectory = baseDir+cell_suffix[i]+"/"
    fname_model = "frMat_10.pickle"
    with open(fdirectory+fname_model,'rb') as handle:
        modelDict = pickle.load(handle)
    frMat = matDat['frTrialMat']

    # get pairwise difference between individual trials and _barycenter
    d = []
    indexRow = np.matlib.repmat(np.linspace(0,199,num=200),200,1)
    for i,x in enumerate(frMat):
        if i>0:
            row_i = np.multiply(indexRow,modelDict['model'].soft_warps[i]).sum().sum()/200.
            column_i = np.multiply(indexRow.T,modelDict['model'].soft_warps[i]).sum().sum()/200.
            if row_i>column_i:
                d.append(-np.power(x - modelDict['model']._barycenter.ravel(),2).sum())
            else:
                d.append(np.power(x - modelDict['model']._barycenter.ravel(),2).sum())
    d = np.array(d)
    # normalize
    d_norm = np.divide(d-d.min(),d.max()-d.min())
    x = np.linspace(0,1,d.size)


    # fit line to vector
    slope, intercept, r_value, p_value, std_err = linregress(x,d_norm)
    mean_map = np.squeeze(frMat.mean(axis=0))
    autocorr = correlate(mean_map,mean_map)
    data = {'d':d,'slope':slope,'intercept':intercept,'r_value':r_value,
            'p_value':p_value,'std_err':std_err,'autocorr':autocorr,
            'bary_center':modelDict['model']._barycenter,'d_norm':d_norm}
    # save vector, r^2 of fit and slope of fit
    regFeatFile = "bc_ls_%s" % (cell_suffix[i])
    sio.savemat(baseDir+ regFeatFile+".mat",data)
