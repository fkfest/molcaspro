function Cmp = molcaspro(coefmc,coefmp,dimsym,symord)
%match molcas to molpro basis order
%dimsym: dimensions for each symmetry in molpro order
%symord: order for symmetries: symord(isym_molcas)=isym_molpro
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
%SAOmc=dlmread('overlap.molcas');
Cmc=dlmread(coefmc);
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
    SAOmcs=inv(Cmcs'*Cmcs);
    SAOmps=SAOmp(offmp(isym):dimsym(isym)+offmp(isym)-1,1:dimsym(isym));
    %make small numbers zero
    SAOmcs0=SAOmcs;
    SAOmcs0(abs(SAOmcs0)<tol)=0;
    SAOmps0=SAOmps;
    SAOmps0(abs(SAOmps0)<tol)=0;
    ind=match2mat(SAOmcs0,SAOmps0,tol*10);
    norm(SAOmcs(ind,ind)-SAOmps)
    coef=Cmcs(:,ind)';
    if isym == 1
        dlmwrite(coefmp,coef,'precision','%-18.14e');
    else
        dlmwrite(coefmp,coef,'precision','%-18.14e','-append');
    end
    Cmp(offmp(isym):dimsym(isym)+offmp(isym)-1,1:dimsym(isym))=coef;
end

