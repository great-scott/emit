function [ outputString, error ] = decodeEmit( inputBinary )
%decodeEmit decode binary into string
%   Detailed explanation goes here

outputString = '';
error = '';
sum = 0;
%check the size
%Messages should be n 7-bit bytes

if mod(length(inputBinary),7) ~= 0 
    error = 'data length is not divisible by 7';
    return;
end

lengthMessage = length(inputBinary)-7;

%data portion of the message
for i = 1:7:lengthMessage
    
    %first digit alternates starting at 1
    if ~mod((i-1)/7, 2) ~= str2double(inputBinary(i))
        
        outputString = '';
        error = 'data did not alternate correctly';
        return
        
    else
      
       number = bin2dec(inputBinary(i+1:i+6));
       sum = sum + number;
       newChar = emitTableLookup(number);
       outputString = strcat(outputString, newChar);
       
    end
    
end

%mod 64 check
if ~mod((i)/7, 2) ~= str2double(inputBinary(i+1))
     outputString = '';
     error = 'data did not alternate correctly 2';
     return
     
else
    
   errorCheckDigit = bin2dec(inputBinary(i+1:1+6));
   if errorCheckDigit ~= mod(sum,64)
     outputString = '';
     error = 'message failed mod64 error check';
     return;
   end
   
end


end

