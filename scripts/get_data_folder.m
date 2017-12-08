mp_prefix = '~/Dropbox/Malcolms_VR_Data/';
mc_prefix1 = '/Users/malcg/Dropbox/Work/Malcolms_VR_data/';
mc_prefix2 = '/Users/malcolmcampbell/Dropbox/Work/Malcolms_VR_data/';
mc_prefix3 = '/Users/malcolmc/Dropbox/Work/Malcolms_VR_data/';
if (exist(mc_prefix1,'dir')>0)
    datafolder = mc_prefix1;
elseif (exist(mc_prefix2,'dir')>0)
    datafolder = mc_prefix2;
elseif (exist(mc_prefix3,'dir')>0)
    datafolder = mc_prefix3;
elseif (exist(mp_prefix,'dir')>0)
    datafolder = mp_prefix;
end