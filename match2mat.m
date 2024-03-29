function ind = match2mat(mat1,mat2,tol)
% permute symmetric matrix mat1 to match mat2
% tolerance for uniqueness is tol

% presort
% sort each column
sortmat1=sort(mat1,1);
sortmat2=sort(mat2,1);
perm=zeros(size(mat1,1));
for i=1:size(mat1,1)
    %diff=vecnorm(sortmat1-sortmat2(i));
    diff=sqrt(sum((sortmat1-sortmat2(:,i)).^2,1));
    % in each row: which column looks similar to mat2(:,i)
    perm(i,:)=bsxfun(@lt,diff,tol);
end
% remove noise
repeat = true;
while repeat 
    oldperm=perm;
    for i=1:size(mat1,1)
        for j=i+1:size(mat1,1)
            if any(perm(i,:)&perm(j,:))
                perm(i,:)=perm(i,:)|perm(j,:);
                perm(j,:)=perm(i,:);
            end
        end
    end
    repeat=any(perm-oldperm);
end
%define first order
found=zeros([size(mat1,1),1]);
ind=zeros([size(mat1,1),1]);
for i=1:size(mat1,1)
    positions=find(perm(i,:));
    for j=1:length(positions)
        if found(positions(j)) == 0
            found(positions(j)) = 1;
            ind(i)=positions(j);
            break;
        end
    end
end
%set remaining
notset1=find(~found);
notset2=find(~ind);
if length(notset1) ~= length(notset2)
    error('Mismatch in sizes!');
end
for i=1:length(notset1)
    ind(notset2(i))=notset1(i);
end
minres=norm(mat1(ind,ind)-mat2);
%minres=1000;
%ind=1:size(mat1,1);
for iter=1:1
  for i=1:size(mat1,1)
    ind1=match2vec(mat1(ind,ind(i)),mat2(:,i),tol*10);
    res=norm(mat1(ind(ind1),ind(ind1))-mat2);
    if res < minres
        minres=res       
        ind=ind(ind1);
    end
    if res < tol
        return
    end
  end
end

