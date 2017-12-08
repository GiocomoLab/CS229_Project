# load file names
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


baseDir = "/Users/markplitt/Dropbox/Malcolms_VR_data/twPCA_Mats/"
files = glob(baseDir+"twPCA_*.mat")
cell_suffix = [i.split(baseDir+"twPCA_")[1] for i in files]
cell_suffix = [i.split(".mat")[0] for i in cell_suffix]


for i, fname  in enumerate(files):
    print(fname)
    matDat = sio.loadmat(fname)
    bc = json.load(open(baseDir+"sdtw_"+cell_suffix[i]+".json"))
    #print(bc.keys())
    frMat = matDat['frTrialMat']
    bc = np.array(bc['firing_rate_mean_warp'])

    # get pairwise difference between individual trials and _barycenter
    d = []
    for x in frMat:
        d.append(np.power(x - bc,2).sum())
    d = np.array(d)
    d_norm = np.divide(d-d.min(),d.max())
    #print(d_norm)
    x = np.linspace(0,1,d.size)


    # fit line to vector
    slope, intercept, r_value, p_value, std_err = linregress(x,d_norm)
    #print(slope)
    #print(r_value)
    data = {'d':d,'slope':slope,'intercept':intercept,'r_value':r_value,
            'p_value':p_value,'std_err':std_err}
    # save vector, r^2 of fit and slope of fit
    regFeatFile = "bc_ls_%s.pickle" % (cell_suffix[i])
    with open(baseDir+regFeatFile,'wb') as handle:
        pickle.dump(data,handle,protocol=pickle.HIGHEST_PROTOCOL)