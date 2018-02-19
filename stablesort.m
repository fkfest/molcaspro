function ind = stablesort(vec,tol)
% sort vec and place repeated values in the original order
% tolerance for uniqueness is tol
[~,ind]=sort(vec);

for i = 1:length(ind)-1
    if abs(vec(ind(i)) - vec(ind(i+1))) < tol
        if ind(i) > ind(i+1)
            tmp=ind(i);
            ind(i)=ind(i+1);
            ind(i+1)=tmp;
         end
    end
end