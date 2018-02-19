function coef = molcaspro(coefmc)
%match molcas to molpro basis order
tol=1.d-7;
smolpro='overlap.molpro';
%SAOmc=dlmread('overlap.molcas');
Cmc=dlmread(coefmc);
SAOmc=inv(Cmc'*Cmc);
SAOmp=dlmread(smolpro);
%make small numbers zero
SAOmc0=SAOmc;
SAOmc0(abs(SAOmc0)<tol)=0;
SAOmp0=SAOmp;
SAOmp0(abs(SAOmp0)<tol)=0;
ind=match2mat(SAOmc0,SAOmp0,tol*10);
norm(SAOmc(ind,ind)-SAOmp)
coef=Cmc(:,ind)';
%dlmwrite('molpro.orbdump',coef);

