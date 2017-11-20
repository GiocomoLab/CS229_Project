mp_prefix = '~/Dropbox/Malcolms_VR_Data/FeatureMats';
mc_prefix = '/Users/malcolmcampbell/Dropbox/Work/Malcolms_VR_data/FeatureMats';
if (exist(mc_prefix,'dir')>0)
    datafolder = mc_prefix;
elseif (exist(mp_prefix,'dir')>0)
    datafolder = mp_prefix;
end