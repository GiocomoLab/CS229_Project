import scipy.io as sio
import os
import numpy as np
from scipy.ndimage.filters import gaussian_filter1d
from scipy.stats import pearsonr
from glob import glob
import json
from twpca import TWPCA
import matplotlib.pyplot as plt
import matplotlib.gridspec as gs
import pickle
from joblib import Parallel, delayed


baseDir = "/Users/markplitt/Dropbox/Malcolms_VR_data/twPCA_Mats/"
files = glob(baseDir+"twPCA_*.mat")
cell_suffix = [i.split(baseDir+"twPCA_")[1] for i in files]
cell_suffix = [i.split(".mat")[0] for i in cell_suffix]

for i, f  in enumerate(files):
    fdirectory = baseDir+cell_suffix[i]+"/"
    matDat = sio.loadmat(f)
    frMat = np.expand_dims(matDat['frTrialMat'],axis=2)
    bc_ls = sio.loadmat(baseDir+"bc_ls_" + cell_suffix[i] +".mat")
    fig, axarr = plt.subplots(3, 2)
    plt.subplots_adjust(hspace=.5)
    fig.set_figheight(10)
    fig.set_figwidth(10)

    fname_model = "frMat_10.pickle"

    with open(fdirectory+fname_model,'rb') as handle:
        modelDict = pickle.load(handle)

    print(modelDict.keys())


    axarr[0,0].imshow(np.squeeze(frMat),aspect='auto')
    #axarr[0,1].set_title(cell_suffix[i])
    axarr[1,0].plot(np.squeeze(frMat.mean(axis=0)),color='red')

    axarr[0,1].imshow(np.squeeze(modelDict['aligned_data']),aspect = 'auto')
    axarr[1,1].plot(modelDict['model']._barycenter)

    axarr[2,0].scatter(np.linspace(0,1,num=bc_ls['d_norm'].size),bc_ls['d_norm'])
    axarr[2,0].plot(np.linspace(0,1,num=bc_ls['d_norm'].size),
        bc_ls['slope'][0][0]*np.linspace(0,1,num=bc_ls['d_norm'].size)
        + bc_ls['intercept'][0][0],color='red')
    axarr[2,0].set_title("r^2 = %f" % bc_ls['r_value'].ravel()[0]**2)


    #autocorr = np.correlate(frMat.mean(axis=0).ravel(),frMat.mean(axis=0).ravel())
    axarr[2,1].plot(bc_ls['autocorr'].ravel())
    #print(bc_ls['autocorr'].ravel())


    plt.suptitle(cell_suffix[i])
    #plt.show()
    fig.savefig(baseDir+'timeWarpFeats_'+cell_suffix[i]+'.png')
    #fig.close()
