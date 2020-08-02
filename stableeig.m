function [V,D] = stableeig(Amat)
% calc eigenvalues and eigenvectors
% sorted and max value of eigenvectors is set to positive 
[V,D]=eig(Amat);
[~,ind]=sort(diag(D));
D=D(ind,ind);
V=V(:,ind);
for i=1:size(V,1)
  if abs(max(V(:,i))) < abs(min(V(:,i))) 
    V(:,i)=-V(:,i);
  end
end
