import scipy.io as sio
import os
import numpy as np
from scipy.ndimage.filters import gaussian_filter1d
from glob import glob
import json
from twpca import TWPCA
import matplotlib.pyplot as plt
import pickle
#from joblib import Parallel, delayed


baseDir = "/Users/markplitt/Dropbox/Malcolms_VR_data/twPCA_Mats/"
files = glob(baseDir+"twPCA_*.mat")
cell_suffix = [i.split(baseDir+"twPCA_")[1] for i in files]
cell_suffix = [i.split(".mat")[0] for i in cell_suffix]


for i, f  in enumerate(files[0:1]):

    fdirectory = baseDir+cell_suffix[i]+"/"
    if not os.path.exists(fdirectory):
        os.makedirs(fdirectory)

    matDat = sio.loadmat(f)

    spikeMat = np.expand_dims(matDat['timeSpikeMat'],axis=2)
    spikeMat[np.isnan(spikeMat)]=0. # impute nans

    smoothSpikeMat = gaussian_filter1d(spikeMat,5,axis = 1)
    smoothSpikeMat[np.isnan(spikeMat)]=0.

    frMat_noSmooth = np.expand_dims(matDat['frTrialMat_noSmooth'],axis=2)
    frMat = np.expand_dims(matDat['frTrialMat'],axis=2)

    #DATA = [spikeMat,smoothSpikeMat, frMat_noSmooth, frMat]
    #modelName = ['spikeMat','smoothSpikeMat', 'frMat_noSmooth', 'frMat']
    DATA = [smoothSpikeMat, frMat_noSmooth, frMat]
    modelName = ['smoothSpikeMat', 'frMat_noSmooth', 'frMat']
    for gamma in [1,10,30]: #[.1,1,10,30]:
        for data, dstr in zip(DATA,modelName):
            model = TWPCA(n_components=1, smoothness=gamma)
            model.fit(data)
            aligned_data = model.soft_transform(data) # align to bary center
                                            # using soft_dtw

            fig, axarr = plt.subplots(3, 2)
            fig.set_figheight(15)
            fig.set_figwidth(15)


            axarr[0,0].imshow(np.squeeze(data),aspect='auto')
            axarr[0,1].imshow(np.squeeze(aligned_data),aspect='auto')


            axarr[1,0].plot(data.mean(axis=0).ravel())
            axarr[1,1].plot(aligned_data.mean(axis=0).ravel())


            axarr[2,0].plot(model._barycenter)


            for trial in model.hard_warps:
                axarr[2,1].plot(trial[:,0], trial[:,1])

            fig.show()
            fname_suffix = "%s_%g.png" % (modelName,gamma)
            fig.savefig(fdirectory+fname_suffix)

            modelDict = {'model':model,'data':data,'aligned_data':aligned_data,
            'gamma':gamma}

            fname_model = "%s_%g.pickle" % (dstr,gamma)
            with open(fdirectory+fname_model, 'wb') as handle:
                pickle.dump(modelDict, handle, protocol=pickle.HIGHEST_PROTOCOL)
