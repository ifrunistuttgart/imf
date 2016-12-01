global IMF_; IMF_=[];
IMF_.pwd = pwd;

IMF_.model = nan;
IMF_.transformations = imf.Transformation.empty;
IMF_.transformationChains = imf.TransformationChain.empty;
IMF_.count_vector = 0;
IMF_.count_matrix = 0;
IMF_.count_double = 0;