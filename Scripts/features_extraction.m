function features = features_extraction(easy,hard,hard_assistance,header,window_size,step_size)
    
    splitted_easy = split(easy,window_size,step_size);
    splitted_hard = split(hard,window_size,step_size);
    splitted_hard_assist = split(hard_assistance,window_size,step_size);
    
    FeatEasy = extract_feature_of_matrix(splitted_easy,windows_size,0);
    FeatHard = extract_feature_of_matrix(splitted_easy,windows_size,1);
    FeatHardAssist = extract_feature_of_matrix(splitted_easy,windows_size,2);
    
    