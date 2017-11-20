mp_prefix = '~/Dropbox/Malcolms_VR_Data/FeatureMats';
mc_prefix1 = '/Users/malcg/Dropbox/Work/Malcolms_VR_data/FeatureMats';
mc_prefix2 = '/Users/malcolmcampbell/Dropbox/Work/Malcolms_VR_data/FeatureMats';
if (exist(mc_prefix1,'dir')>0)
    datafolder = mc_prefix1;
elseif (exist(mc_prefix2,'dir')>0)
    datafolder = mc_prefix2;
elseif (exist(mp_prefix,'dir')>0)
    datafolder = mp_prefix;
end