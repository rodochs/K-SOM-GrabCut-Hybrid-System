function uni = uniformidade(im)
    
    [m, n] = size(im);
    
    uni = 0;
    
    for i = 0:255
        k = find(im(:,:,1) == i);
        p = ((numel(k)) / (m*n))^2;
        uni = uni+p;
    end