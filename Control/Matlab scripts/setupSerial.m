function [ s,flag ] = setupSerial( comPort )

%Si aparece el error Open failed: Port: COM5 is not available.
%usar delete(instrfind)
flag=1;
s=serial(comPort);
set(s,'terminator',13);

fopen(s);

end

