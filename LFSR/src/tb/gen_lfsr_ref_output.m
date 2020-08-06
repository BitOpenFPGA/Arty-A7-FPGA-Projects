%Generates the correct reference values/output for the 8 bit LFSR implementation
polyVec = [1 0 1 1 0 1 0 0 1]; %Feedback Polynomial x^8+x^6+x^5+x^3+1
polyVec = flip(polyVec);
initStates = [ 1 0 1 1 1 1 1 0]; %0xBE in test
polySize = 8;
pnSequence = comm.PNSequence('Polynomial',polyVec,'InitialConditions',initStates, 'SamplesPerFrame',2*(2^polySize-1));
outSequence = pnSequence();
% save('LFSR_ref_values.txt','outSequence', '-ascii'); 
%save to file
fileID = fopen('LFSR_ref_values.txt','w');
fprintf(fileID, '%d\n',outSequence);
fclose(fileID);

