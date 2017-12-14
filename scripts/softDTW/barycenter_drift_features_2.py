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

# get bary center
baseDir = "/Users/markplitt/Dropbox/Malcolms_VR_data/twPCA_Mats/"
files = glob(baseDir+"twPCA_*.mat")
cell_suffix = [i.split(baseDir+"twPCA_")[1] for i in files]
cell_suffix = [i.split(".mat")[0] for i in cell_suffix]


# find cell that shows convincing drift
cell = "Biggie102_0710_gainmanip_rm1_2_t4C1"
matDat = sio.loadmat(baseDir+'twPCA_'+cell+'.mat')
bc_ls = sio.loadmat(baseDir+"bc_ls_" + cell +".mat")
fdirectory = baseDir+cell+"/"
fname_model = "frMat_10.pickle"

with open(fdirectory+fname_model,'rb') as handle:
    modelDict = pickle.load(handle)


# calculate peak of cross correlation
ccorr = []
fig,  axarr  = plt.subplots(2,1);
for x in matDat['frTrialMat']:
    c = np.correlate(x,modelDict['model']._barycenter.ravel(),mode='same')
    #print(c)
    axarr[0].plot(c)
    ccorr.append(np.argmax(np.correlate(x,c,mode='same')))

#print(modelDict['model'].soft_warps[0])

indexRow = np.matlib.repmat(np.linspace(0,199,num=200),200,1)
#indexColumn = indexRow.trans

for i, mat in enumerate(modelDict['model'].soft_warps):
    row_i = np.multiply(indexRow,mat).sum().sum()/200.
    column_i = np.multiply(indexRow.T,mat).sum().sum()/200.
    fig2 = plt.figure()
    plt.title("%f %f" % (row_i,column_i))
    print(row_i)
    print(column_i)
    plt.imshow(np.squeeze(mat),aspect='auto')

#print(ccorr)
axarr[1].plot(ccorr[1:])
plt.show()

# calculate center of mass of individual trials
