% NAME : NARAYANA, VISHALI
% CWID : 11761023
% ASSIGNMENT # : PROGRAMMING ASSIGNMENT #2
% HMM MODEL TO FORECAST FUTURE TREND OF STOCK PRICES

% Place the dataset in the existing folder path
% Now, import the Close price column of the dataset into workspace
% Guess Transition and Emission matrices initially
GuessTR=[0.70,0.14,0.16;0.30,0.50,0.20;0.30,0.15,0.55];
GuessEM=[0.20,0.43,0.37;0.45,0.40,0.15;0.20,0.50,0.30];
% Calculate the Moving Average for Close Price
MovAvge=zeros(254,1);
for i=6:254
    MovAvge(i,1)=(Close(i,1)+Close(i-1,1)+Close(i-2,1)+Close(i-3,1)+Close(i-4,1))/5;
end
MovAvge(1:5)=[]; % Removing the first five empty rows
% Get the sequence of observables based on the below formula
OBS=zeros(249,1);
for i=1:249
    if 0.999*MovAvge(i,1)<Close(i,1) && Close(i,1)<1.001*MovAvge(i,1)
       OBS(i,1)=1;
    elseif Close(i,1)<0.999*MovAvge(i,1);
            OBS(i,1)=2;
        else
            OBS(i,1)=3;
    end
end
obseq=OBS'; % Transpose of observations values according to the dates

% Use hmmtrain to get the estimated transition and emission matrices
[estTR,estEM] = hmmtrain(obseq,GuessTR,GuessEM);
% Use hmmdecode to get the posterior probabilities of states
PStates = hmmdecode(obseq,estTR,estEM);
% Extract the last column of the PStates matrix into output
output = PStates(:,(end));
% Matrix initialization which stores the emitted symbols, previous and
% current states
index2=zeros(1,10);
for l = 1:10
for k = 1:3
    max =0;
    max_j=0;
    max_i=0;
    for j = 1:3
        for i = 1:3      
           temp = output(j,l)*estTR(j,k)*estEM(j,i);
           if temp > max
             max = temp;
             max_j=j;
             max_i=i;
           end
        end
    end  
    output(k,l+1) = max;
    if k > 1
       if output(k-1,l+1) < output(k,l+1) 
        index2(1,l)=max_j;
        index2(2,l)=max_i;
        index2(3,l)=k;
       end
    else
       index2(1,l)=max_j;  % previous state
       index2(2,l)=max_i;  % emission
       index2(3,l)=k;      % current state
    end
end
end
FuturePrice = zeros(15,1);
for n=1:5
   FuturePrice(n,1)= Close(249+n,1); % Assigning the last 5 Close price values to the start of Future price
end 
for x=1:10
     if index2(2,x)==1  % 1 = S
        FuturePrice(5+x,1)=((1-0.001)*mean(FuturePrice(x:(x+4),1))+(1+0.001)*mean(FuturePrice(x:(x+4),1)))/2;
     elseif index2(2,x)==2  % 2 = L
       FuturePrice(5+x,1)=(1-0.001)*mean(FuturePrice(x:(x+4),1));
     else % 3 = H
       FuturePrice(5+x,1)=(1+0.001)*mean(FuturePrice(x:(x+4),1));
     end
end
disp('The Future 10-day Prices  : ')
disp(FuturePrice(6:15,1)) % Displaying the forecasted closing price for the future 10 days

%Take the date column and closing price values from the old dataset and
%append the new forecasted closing price values with incrementing the dates
%and save the file in csv format
% Now, import the dataset into RStudio and plot the hidden markov model