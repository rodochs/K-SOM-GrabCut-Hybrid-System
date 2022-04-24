function [i, h] = equalizer(f, t, a)
    h = imhist(f);
    p = (h/sum(h));
    for i = 2:numel(p), p(i,1) = p(i,1)+p((i-1),1); end;
    switch t
        case 'n'
            F = 255 * p;
        case 'e'
            aux = find(p==1);
            p(aux) = 254;
            F = -(1/a)*log(1-p);
        otherwise
            disp('entrada incorreta');
    end
    f2 = f;
    for i = 1:255
        t = find(f==(i-1));
        aux = isempty(t);
        if ~aux
            f2(t) = p(i);
        end
    end
        
    
    subplot(2,2,1), imshow(f);
    subplot(2,2,2), imshow(f2);
    subplot(2,2,3), imhist(f);
    subplot(2,2,4), imhist(f2);