function [ binary ] = encodeEmit( inputString )
%encodeEmit - encode string into emit binary
%   Detailed explanation goes here

% byte consists of 1 error checking bit and 6 info carrying bits

binary = '';
sum = 0;

for i = 1:length(inputString)

    %Alternately tag odd and even bytes
    if mod(i,2)
        binary = strcat(binary, '1');
    else    
        binary = strcat(binary, '0');
    end  
    
    %table look up
    number = emitTableLookup(inputString(i));
    binary = strcat(binary, dec2bin(number, 6));
    
    
    %for use with mod 64 error checking
    sum = sum + number;
    
end

%error checking byte

   if mod(length(inputString)+1,2)
        binary = strcat(binary, '1');
    else    
        binary = strcat(binary, '0');
   end 

   errorCheckDigit = mod(sum,64);
   
   binary = strcat(binary, dec2bin(errorCheckDigit, 6));
   
end

