function [dims,iord]=dimsym(symmp,symmc)
mp=upper(strtrim(split(symmp,'+')));
dimss=regexp(mp,'^\d*','Match');
dims=zeros([1,length(dimss)]);
for isym=1:length(mp)
    if length(dimss{isym}) ~= 1
        error('Some symmetries dont have the corresponding number of functions!');
    end
    dims(isym)=str2double(dimss{isym}(1));
    mp(isym)=extractAfter(mp(isym),length(num2str(dims(isym))));
end
mc=upper(strtrim(split(symmc)));
if length(mp) ~= length(mc)
    error('Number of symmetries differ');
end
iord=zeros([1,length(mc)]);
for isym=1:length(mc)
    indx = find(ismember(mp,mc(isym)));
    if isempty(indx)
        error('Symmetries dont match!');
    end
    iord(isym) = indx;
end

end