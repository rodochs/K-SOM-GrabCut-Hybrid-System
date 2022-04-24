function s = KSOM(d, cS, iN, tF, dF, i, r)

    [m, n, p] = size(i);
    
    if p == 1
        i(:,:,2) = i(:,:,1);
        i(:,:,3) = i(:,:,1);
    end
    
    ir = i(:,:,1);
    ig = i(:,:,2);
    ib = i(:,:,3);

    x = zeros(3, numel(find(r == 1)));

    cont = 1;

    for j = 1:m
        for k = 1:n
            if r(j, k) == 1
                x(1,cont) = ir(j, k);
                x(2,cont) = ig(j, k);
                x(3,cont) = ib(j, k);
                cont = cont + 1;
            end   
        end
    end

    
    
    net = selforgmap(d, cS, iN, tF, dF);
    %net.trainParam.showWindow = false;
    %net.trainParam.showCommandLine = true;
    net = train(net, x);
    
    saida = net(x);

    s = zeros(m, n);
    cont = 1;

    for j = 1:m
        for k = 1:n
            if r(j,k) == 1
                s(j,k) = find(saida(:,cont)==1);
                cont = cont + 1;
            else
                s(j,k) = d(2);
            end
        end
    end
    
    if (net.IW{1,1}(1) > net.IW{1,1}(4))
        s = max(max(s))-s;
    end