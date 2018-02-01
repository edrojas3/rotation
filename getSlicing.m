function slicing = getSlicing(n,selection)

slicing = zeros(n,1);

selectedSlicing = strsplit(selection,',');

if length(selectedSlicing) > 1
    for s = 1:length(selectedSlicing);
        rangestr = strsplit(selectedSlicing{s},'-');
        rangenum = [str2num(rangestr{1}):str2num(rangestr{2})];
        slicing(rangenum) = 1;
    end
else
    rangestr = strsplit(selectedSlicing{1},'-');
    rangenum = [str2num(rangestr{1}):str2num(rangestr{2})];
    slicing(rangenum) = 1;
end