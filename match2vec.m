function ind = match2vec(vec1,vec2,tol)
% permute indices in vec1 to match vec2
% tolerance for uniqueness is tol
ind1=stablesort(vec1,tol);
ind2=stablesort(vec2,tol);
indt(ind2)=1:length(vec2);
ind=ind1(indt);

    