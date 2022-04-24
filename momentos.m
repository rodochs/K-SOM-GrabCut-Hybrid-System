function [m, u1, u2, u3, U, R, e] = momentos(s)

%   m = Média
%   u1, u2, u3 =  Momentos 1, 2 e 3, respectivamente
%   U = Uniformidade
%   R = Suavidade Relativa
%   E = Entropia
%   p = Probabilidade

    img = imread(s);

    img = img(:,:,1);
    if max(max(img)) <= 1
        img = img*256;
    end
    
%    if min(min(img)) == 0
%        img = img+1;
%    end
    
    im = round(img);
    
    p = zeros(256,1);
    m = 0;
    
    for i = 1:256
        p(i) = numel(find(im == i-1))/numel(im);
        m = m + i*p(i);
    end

    u1 = 0;
    u2 = 0;
    u3 = 0;
    e = 0;
    U = 0;
    
    for i = 1:256
        u1 = u1 + abs((i-m))*p(i);
        u2 = u2 + ((i-m)^2)*p(i);
        u3 = u3 + ((i-m)^3)*p(i);
        if p(i) > 0
            e = e + p(i) * log2(p(i));
        end
        U = U + (p(i))^2;
    end
    e = e*(-1);
    R = 1 - 1/(1-u2^2); 
end