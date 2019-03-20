function Cmp = molprocas(coefmp,coefmc4S,coefmc,dimsym,symord)
%match molpro to molcas basis order
%dimsym: dimensions for each symmetry in molpro order
%symord: order for symmetries: symord(isym_molcas)=isym_molpro
tol=1.d-7;
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

Cmc4S=dlmread(coefmc4S);
Cmp=dlmread(coefmp);

Cmc=zeros(size(Cmp,1));
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
dlmwrite(coefmc,dimsym(symord));
for isymMC=1:length(dimsym)
    isym=symord(isymMC);
    Cmps=Cmp(offmp(isym):dimsym(isym)+offmp(isym)-1,1:dimsym(isym))';
    Cmc4Ss=Cmc4S(offmc(isym):dimsym(isym)+offmc(isym)-1,1:dimsym(isym));
    SAOmps=inv(Cmps'*Cmps);
    SAOmcs=inv(Cmc4Ss'*Cmc4Ss);
    %make small numbers zero
    SAOmcs0=SAOmcs;
    SAOmcs0(abs(SAOmcs0)<tol)=0;
    SAOmps0=SAOmps;
    SAOmps0(abs(SAOmps0)<tol)=0;

    ind=match2mat(SAOmps0,SAOmcs0,tol*10);
    norm(SAOmps(ind,ind)-SAOmcs)
    coef=Cmps(:,ind);
%    if isym == 1
%        dlmwrite(coefmc,coef,'precision','%-18.14e');
%    else
    dlmwrite(coefmc,coef,'precision','%-18.14e','-append');
%    end
    Cmc(offmc(isym):dimsym(isym)+offmc(isym)-1,1:dimsym(isym))=coef;
end

