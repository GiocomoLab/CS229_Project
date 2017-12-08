import scipy.io as sio
import os
import numpy as np
from scipy.ndimage.filters import gaussian_filter1d
from glob import glob
import json
from twpca import TWPCA
import matplotlib.pyplot as plt
import pickle
from joblib import Parallel, delayed



def run_models(i,f,cell_suffix):
    fdirectory = baseDir+cell_suffix[i]+"/"
    if not os.path.exists(fdirectory):
        os.makedirs(fdirectory)

    matDat = sio.loadmat(f)

    #spikeMat = np.expand_dims(matDat['timeSpikeMat'],axis=2)
    #spikeMat[np.isnan(spikeMat)]=0. # impute nans

    #smoothSpikeMat = gaussian_filter1d(spikeMat,5,axis = 1)
    #smoothSpikeMat[np.isnan(spikeMat)]=0.

    #frMat_noSmooth = np.expand_dims(matDat['frTrialMat_noSmooth'],axis=2)
    frMat = np.expand_dims(matDat['frTrialMat'],axis=2)

    #DATA = [spikeMat,smoothSpikeMat, frMat_noSmooth, frMat]
    #modelName = ['spikeMat','smoothSpikeMat', 'frMat_noSmooth', 'frMat']
    DATA = [frMat]
    modelName = ['frMat']
    fig, axarr = plt.subplots(4, 3)
    fig.set_figheight(15)
    fig.set_figwidth(15)
    for g, gamma in enumerate([1,10]): #[.1,1,10,30]):

        for m, (data, dstr) in enumerate(zip(DATA,modelName)):
            model = TWPCA(n_components=1, smoothness=gamma)
            model.fit(data)
            aligned_data = model.soft_transform(data) # align to bary center
                                            # using soft_dtw


            axarr[g*2,m*3].imshow(np.squeeze(data),aspect='auto')
            if m == 0:
                axarr[g*2,m*3].set_title("%s: gamma=%f %s raw" % (cell_suffix[i],gamma,dstr))
            else:
                axarr[g*2,m*3].set_title("gamma=%f %s raw" % (gamma, dstr))
            axarr[g*2,m*3+1].imshow(np.squeeze(aligned_data),aspect='auto')
            axarr[g*2,m*3+1].set_title("%s aligned" % (dstr))


            axarr[g*2+1,m*3].plot(data.mean(axis=0).ravel())
            axarr[g*2+1,m*3+1].plot(model._barycenter)

            axarr[g*2,m*3+2].set_title("%s hard warps" % (dstr))
            for trial in model.hard_warps:
                axarr[g*2,m*3+2].plot(trial[:,0], trial[:,1])



            modelDict = {'model':model,'data':data,'aligned_data':aligned_data,
            'gamma':gamma}

            fname_model = "%s_%g.pickle" % (dstr,gamma)
            with open(fdirectory+fname_model, 'wb') as handle:
                pickle.dump(modelDict, handle, protocol=pickle.HIGHEST_PROTOCOL)
    fig.show()
    fname_suffix = "%s_rasters.png" % (dstr)
    fig.savefig(fdirectory+fname_suffix)


if __name__ == "__main__":
    baseDir = "/Users/markplitt/Dropbox/Malcolms_VR_data/twPCA_Mats/"
    files = glob(baseDir+"twPCA_*.mat")
    cell_suffix = [i.split(baseDir+"twPCA_")[1] for i in files]
    cell_suffix = [i.split(".mat")[0] for i in cell_suffix]

    for i, f  in enumerate(files):
        run_models(i,f,cell_suffix)


    #Parallel(n_jobs=2)(delayed(run_models)(i,f,cell_suffix) for i, f  in enumerate(files))
