function Cmp = molcaspro(coefmc,coefmp,dimsym,symord)
%match molcas to molpro basis order
%dimsym: dimensions for each symmetry in molpro order
%symord: order for symmetries: symord(isym_molcas)=isym_molpro
way=1
tol=1.d-7;
smolpro='overlap.molpro';
nosym=false;
if nargin == 2
    nosym=true;
end
if nosym
    disp('Without symmetry');
else
    X=['Symmetry with dimensions ',num2str(dimsym)];
    disp(X);
    if length(dimsym) ~= length(symord)
        error('Mismatch in dimension and order arrays!');
    end
end
%do we have one or two input orbitals?
%if we have na cell array - first set of orbitals is to get the overlap
%and the second - to transform to molpro
twoorbs=false;
if iscellstr(coefmc) 
  disp('Two MOLCAS orbitals files');
  twoorbs=true;
  Cmc=dlmread(coefmc{1});
  Cmc2sort=dlmread(coefmc{2});
  if length(Cmc) ~= length(Cmc2sort)
    error('Mismatch in two MOLCAS orbitals sets!');
  end
else
  Cmc=dlmread(coefmc);
end

%SAOmc=dlmread('overlap.molcas');
Cmp=zeros(size(Cmc,1));
SAOmp=dlmread(smolpro);
if nosym
    dimsym=size(Cmc,1);
    symord=1;
end
offmp=zeros([length(dimsym),1]);
offmcx=offmp;
offmcx(1)=1;
offmp(1)=1;
for isym=1:length(dimsym)-1
    offmcx(isym+1)=offmcx(isym)+dimsym(symord(isym));
    offmp(isym+1)=offmp(isym)+dimsym(isym);
end
offmc(symord)=offmcx;

for isym=1:length(dimsym)
    Cmcs=Cmc(offmc(isym):dimsym(isym)+offmc(isym)-1,1:dimsym(isym));
    [V,D]=eig(Cmcs'*Cmcs);
    SAOmcs=V*inv(D)*V';
    %SAOmcs=inv(Cmcs'*Cmcs);
    SAOmps=SAOmp(offmp(isym):dimsym(isym)+offmp(isym)-1,1:dimsym(isym));
    fprintf('Max difference in eigenvalues of S: %e\n', max(abs(sort(eig(SAOmcs))- sort(eig(SAOmps)))));
    if isym == 1
      dlmwrite('molcas.overlap',SAOmcs,'precision','%-18.14e');
    else
      dlmwrite('molcas.overlap',SAOmcs,'precision','%-18.14e','-append');
    end
    if way == 1
      %sort
      %make small numbers zero
      SAOmcs0=SAOmcs;
      SAOmcs0(abs(SAOmcs0)<tol)=0;
      SAOmps0=SAOmps;
      SAOmps0(abs(SAOmps0)<tol)=0;
      ind=match2mat(SAOmcs0,SAOmps0,tol*10);
      norm(SAOmcs(ind,ind)-SAOmps)
      if twoorbs
        Cmcs2sort=Cmc2sort(offmc(isym):dimsym(isym)+offmc(isym)-1,1:dimsym(isym));
        coef=Cmcs2sort(:,ind)';
      else
        coef=Cmcs(:,ind)';
      end
    else
      %transform, doesn't work yet...
      [Vmc,Dmc]=eig(SAOmcs);
      [DD,ind]=sort(diag(Dmc));
      Vmc=Vmc(:,ind);
      [Vmp,Dmp]=eig(SAOmps);
      [DD,ind]=sort(diag(Dmp));
      Vmp=Vmp(:,ind);
      if twoorbs
        Cmcs2sort=Cmc2sort(offmc(isym):dimsym(isym)+offmc(isym)-1,1:dimsym(isym));
        coef=(Cmcs2sort*Vmc*Vmp')';
      else
        coef=(Cmcs*Vmc*Vmp')';
      end
      [V,D]=eig(coef*coef');
      SS=V*inv(D)*V';
      norm(SS-SAOmps)
    end
    if isym == 1
        dlmwrite(coefmp,coef,'precision','%-18.14e');
    else
        dlmwrite(coefmp,coef,'precision','%-18.14e','-append');
    end
    Cmp(offmp(isym):dimsym(isym)+offmp(isym)-1,1:dimsym(isym))=coef;
end

