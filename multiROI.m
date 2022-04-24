function handles = multiROI()

    hax = axes('ButtonDownFcn', @(src,evnt)buttondown(evnt))

    handles = [];

    % Keep this function open until we right click
    %waitfor(gca, 'UserData')
    figure, imshow(imread('3096.jpg'));
    function buttondown(evnt)
        switch evnt.Button
            case 1      
                % On a left click draw a new ROI
                handles = cat(1, handles, imfreehand(gca, 'closed', 0));
            case 3
                % On a right click, remove empty ROIs and return
                handles = handles(isvalid(handles));
                set(gca, 'UserData', 'done')
        end
    end
end