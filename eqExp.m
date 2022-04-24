function g = eqExp(f, a)
    F = (imhist(f)/sum(imhist(f)));
    for i = 2:numel(F), F(i,1) = F(i,1)+F((i-1),1); end;
    
    F(256) = F(255); %comando para evitar F(256)==1.
    
    F = -(1/a)*log(1-F);
    
    g = f;
    for i = 1:256
        t = find(f==(i-1));
        vazio = isempty(t);
        if ~vazio
            g(t) = F(i);
        end
    end
    
    subplot(2,2,1), imshow(f);
    title('Original');
    subplot(2,2,2), imshow(g);
    title('Exponencial');
    subplot(2,2,3), imhist(f);
    subplot(2,2,4), imhist(g);
    title(['Alfa = ', num2str(a)]);