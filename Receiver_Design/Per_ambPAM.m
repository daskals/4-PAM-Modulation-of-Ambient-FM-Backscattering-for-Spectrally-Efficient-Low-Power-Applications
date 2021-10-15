function Pb = Per_ambPAM(Py0,Py1,Py2,Py3,Pn,L)
%
mu0 = Py0;
mu1 = Py1;
mu2 = Py2;
mu3 = Py3;
s02 = 2.*(mu0-L).*Pn./L; s0 = sqrt(s02);
s12 = 2.*(mu1-L).*Pn./L; s1 = sqrt(s12);
s22 = 2.*(mu2-L).*Pn./L; s2 = sqrt(s22);
s32 = 2.*(mu3-L).*Pn./L; s3 = sqrt(s32);
%
a01 = (s12.*mu0-s02.*mu1)./(s12-s02);
a02 = sqrt(s02.*s12.*( (mu1-mu0).^2 + (s12-s02).*log(s12./s02) ))./(s12-s02);
t01_p = a01 + a02;
t01_n = a01 - a02;
t01_1 = (s1.*mu0+s0.*mu1)./(s1+s0);
t01_2 = s1.*(s12-s02)./2./s0./(mu1-mu0);
t01_t = t01_1 + t01_2;
%
a11 = (s22.*mu1-s12.*mu2)./(s22-s12);
a12 = sqrt(s02.*s12.*( (mu2-mu1).^2 + (s22-s12).*log(s22./s12) ))./(s22-s12);
t12_p = a11 + a12;
t12_n = a11 - a12;
t12_1 = (s2.*mu1+s1.*mu2)./(s2+s1);
t12_2 = s2.*(s22-s12)./2./s1./(mu2-mu1);
t12_t = t12_1 + t12_2;
%
a21 = (s32.*mu2-s22.*mu3)./(s32-s22);
a22 = sqrt(s32.*s22.*( (mu3-mu2).^2 + (s32-s22).*log(s32./s02) ))./(s32-s22);
t23_p = a21 + a22;
t23_n = a21 - a22;
t23_1 = (s3.*mu2+s2.*mu3)./(s3+s2);
t23_2 = s3.*(s32-s22)./2./s2./(mu3-mu2);
t23_t = t21_1 + t21_2;
%
x0 = (t01-mu0)./s0;
x11 = (t12-mu1)./s1;
x12 = (t01-mu1)./s1;
x21 = (t23-mu2)./s2;
x22 = (t12-mu2)./s2;
x3 = (t23-mu3)./s3;
%
Pe0 = Qf(x0);
Pe1 = Qf(x11)+1-Qf(x12);
Pe2 = Qf(x21)+1-Qf(x23);
Pe3 = 1-Qf(x3);
Ps = 0.25.*(Pe0+Pe1+Pe2+Pe3);
Pb = Ps./2;