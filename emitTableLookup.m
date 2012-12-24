function [ output ] = emitTableLookup( input )
%emitTableLookup - number/string lookup
%   Supply a number, get a string
%   Supply a string, get a number

% M = info bit
%indicies are augmented by 1
M(1) = '0'; % index 0, 000000 = 0
M(2) = '1'; % index 1, 000001 = 1
M(3) = '2'; % index 2, 000010 = 2
M(4) = '3';
M(5) = '4';
M(6) = '5';
M(7) = '6';
M(8) = '7';
M(9) = '8';
M(10) = '9';
M(11) = 'A';
M(12) = 'B';
M(13) = 'C';
M(14) = 'D';
M(15) = 'E';
M(16) = 'F';
M(17) = 'G';
M(18) = 'H';
M(19) = 'I';
M(20) = 'J';
M(21) = 'K';
M(22) = 'L';
M(23) = 'M';
M(24) = 'N';
M(25) = 'O';
M(26) = 'P';
M(27) = 'Q';
M(28) = 'R';
M(29) = 'S';
M(30) = 'T';
M(31) = 'U';
M(32) = 'V';
M(33) = 'W';
M(34) = 'X';
M(35) = 'Y';
M(36) = 'Z';

if isa(input,'numeric')
    output = M(input+1);
elseif isa(input,'char')
    output = find(M==input)-1;
end
    
end

