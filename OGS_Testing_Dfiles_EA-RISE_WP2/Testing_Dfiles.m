%% Testing the new generated D-files
% update the working folder accordingly and write the WMO.
% contact: mpacciaroni@inogs.it, gnotarstefano@inogs.it, agallo@inogs.it
% OGS, Italy, June 2021.

clear all
close all

strCD='\.';
% addpath ([strCD,'work_oceano\med1\work_drifter'])
cd ([strCD,'work_oceano\DMQC_work\Dfile_generation']) %the working folder

float=6903230; %Write here the WMO

%The R-files directory
path1=[strCD,'storage\sire\dati\float\data\coriolis_profiles\',num2str(float),'\profiles\'];
R=dir([path1 '*',num2str(float),'*.nc']);
[~,I1]=sort({R.name});
R=R(I1);

%The D-files directory
path2=[strCD,'work_oceano\DMQC_work\Dfile_generation\',num2str(float),'\'];
D=dir([path2 'D',num2str(float),'*.nc']);
[~,I1]=sort({D.name});
D=D(I1);

%Handle function to operate with the flags
QC49=@(x1) (strcmpi(x1,'4') || strcmpi(x1,'9'));

% 1st a loop to check parameters
for t=1:numel(D)  
  clear str tmp1 tmp2
  disp(' ')
  str=['tmp1=ncread_coriolis(''',path1,R(t).name,''');'];
  eval(str)
  disp(str)
  
  str=['tmp2=ncread_coriolis(''',path2,D(t).name,''');'];
  eval(str)
  disp(str)
  
  clear R_sal* D_sal* tmp1_PRES_* tmp1_TEMP_*
  write_psal_adj_QC=false;
   
   for hh=1:length(tmp1.PSAL_QC)
       R_sal_QC(hh,1)=tmp1.PSAL_QC(hh,1);
       R_sal(hh,1)=tmp1.PSAL(hh,1);
       if isspace(R_sal_QC(hh,1)) && R_sal(hh,1)~=99999
         error('Error reading salinity R-file QC or value')
       end

% the adjusted values     
       D_sal_QC(hh,1)=tmp2.PSAL_ADJUSTED_QC(hh,1);
       D_sal(hh,1)=tmp2.PSAL_ADJUSTED(hh,1);
       if isspace(D_sal_QC(hh,1)) && D_sal(hh,1)~=99999
         error('Error reading salinity D-file QC or value')
       end     
     
%pressure     
%      if ~isspace(tmp1.PRES_QC(hh,1))
       tmp1_PRES_QC(hh,1)=tmp1.PRES_QC(hh,1);
%      else
%        error('Error reading pressure R-file QC or value')  
%      end
%temperature     
%      if ~isspace(tmp1.TEMP_QC(hh,1))
       tmp1_TEMP_QC(hh,1)=tmp1.TEMP_QC(hh,1);
%      else
%        error('Error reading temparature R-file QC or value')  
%      end
   end
   
%the size of variables
%   disp('R file vs D file comparison [PRES   PRES_ADJUSTED] ')  
%   [tmp2.PRES(:,1) tmp2.PRES_ADJUSTED(:,1)]
  if any(size(tmp2.PRES_ADJUSTED)~=size(tmp2.PRES_ADJUSTED_QC))
    error('Length of PRES_ADJUSTED and PRES_ADJUSTED_QC are not the same! ')
  end

%   disp('R file vs D file comparison [PSAL   PSAL_ADJUSTED] ')  
%   [tmp2.PSAL(:,1) tmp2.PSAL_ADJUSTED(:,1)]
  if any(size(tmp2.PSAL_ADJUSTED)~=size(tmp2.PSAL_ADJUSTED_QC))
    error('Length of PSAL_ADJUSTED and PSAL_ADJUSTED_QC are not the same! ')
  end
  
%   disp('R file vs D file comparison [TEMP   TEMP_ADJUSTED] ')  
%   [tmp2.TEMP(:,1) tmp2.TEMP_ADJUSTED(:,1)]
  if any(size(tmp2.TEMP_ADJUSTED)~=size(tmp2.TEMP_ADJUSTED_QC))
    error('Length of TEMP_ADJUSTED and TEMP_ADJUSTED_QC are not the same! ')
  end
  
%Displaying the QC data
%   disp('R file vs D file comparison [PRES_QC   PRES_ADJUSTED_QC] ')  
%   [tmp1.PRES_QC  tmp2.PRES_ADJUSTED_QC]
% 
%   disp('R file vs D file comparison [PSAL_QC   PSAL_ADJUSTED_QC] ')  
%   [tmp1.PSAL_QC  tmp2.PSAL_ADJUSTED_QC]
%   
%   disp('R file vs D file comparison [TEMP_QC   TEMP_ADJUSTED_QC] ')  
%   [tmp1.TEMP_QC  tmp2.TEMP_ADJUSTED_QC]


%% ===================== case NO CORRECTIONS by OWC
  for h=1:length(tmp2.PSAL_ADJUSTED_QC)
    
    if str2num(R_sal_QC(h))~=str2num(D_sal_QC(h))
      Mpause(['PSAL_QC= ',R_sal_QC(h),', PSAL_ADJUSTED_QC= ',D_sal_QC(h),', h=',num2str(h)])

      if str2num(R_sal_QC(h))==1
%         Mpause(['R-file QC=3, PSAL_ADJUSTED_QC= ',D_sal_QC(h),', h=',num2str(h)])
        hf1=figure;
        I=find(abs(tmp1.PRES(:,1))~=99999);
        plot(R_sal(I),-tmp1.PRES(I,1),'k.')
        hold on
        plot(R_sal(h),-tmp1.PRES(h),'ro')
        for ii=1:length(tmp2.PSAL_ADJUSTED_QC)
          text(double(R_sal(ii)),double(-tmp1.PRES(ii,1)),num2str(ii))
        end
        pause
        close(hf1)
      end
      

      if str2num(R_sal_QC(h))==3
        pause(['R-file QC=3, PSAL_ADJUSTED_QC= ',D_sal_QC(h),', h=',num2str(h)])
     
      end
      
      if str2num(R_sal_QC(h))==4
        pause(['R-file QC=4, PSAL_ADJUSTED_QC= ',D_sal_QC(h),', h=',num2str(h)])

      end
      
    end
    
  end
  
%% ======================
  
%Checking for differences in PSAL_QC and PSAL_ADJUSTED_QC
  for h=1:length(tmp2.PSAL_ADJUSTED_QC)
    if QC49(tmp2.PSAL_ADJUSTED_QC(h)) && tmp2.PSAL_ADJUSTED_ERROR(h)<=999
     pause('PSAL_ADJUSTED_QC=bad data, PSAL_ADJUSTED_ERROR~=99999, check!')
     tmp2.PSAL_ADJUSTED_ERROR(h)=99999;
     ncwrite([path2,D(t).name],'PSAL_ADJUSTED_ERROR',tmp2.PSAL_ADJUSTED_ERROR);
    end
    
    if QC49(tmp2.PSAL_ADJUSTED_QC(h)) && tmp2.PSAL_ADJUSTED(h)<=999
     pause('PSAL_ADJUSTED_QC=bad data, PSAL_ADJUSTED~=99999, check!')
     tmp2.PSAL_ADJUSTED(h)=99999;
     ncwrite([path2,D(t).name],'PSAL_ADJUSTED',tmp2.PSAL_ADJUSTED);
    end

    
    
    if tmp2.PSAL_ADJUSTED(h)>=999 && (~isspace(tmp2.PSAL_ADJUSTED_QC(h)) && ~QC49(tmp2.PSAL_ADJUSTED_QC(h)))
     pause('PSAL_ADJUSTED=99999, PSAL_ADJUSTED_QC not 4 or 9,  check!')
    end    
    
    
    
    if tmp2.PSAL_ADJUSTED_ERROR(h)>=999 && (~isspace(tmp2.PSAL_ADJUSTED_QC(h)) && ~QC49(tmp2.PSAL_ADJUSTED_QC(h)))
     pause('PSAL_ADJUSTED_ERROR=99999, PSAL_ADJUSTED_QC not 4 or 9,  check!')
    end    
    
    
    
    
  
% checking among QC  
    if ~isspace(R_sal_QC(h))
      if QC49(R_sal_QC(h)) && str2num(tmp2.PSAL_ADJUSTED_QC(h))<3
        pause(['Check QC case 1, is it ok? Bad in R-file good in D-file, h=',num2str(h),' Press any key to continue'])
      elseif str2num(R_sal_QC(h))<3 && str2num(tmp2.PSAL_ADJUSTED_QC(h))>2
        pause(['Check QC case 2, is it ok? Good in R-file bad in D-file, h=',num2str(h),' Press any key to continue'])
      end
    end
    
  end
 

% Checking the vertical profile QC
  clear str I N_perc
  str=cellstr(tmp2.PSAL_ADJUSTED_QC(:,1));
  T=~cellfun(@isempty,str); %deleting the empty lines
  str=str(T);
  n=1; %1st value and 1st column
  I=find(~cellfun(@isempty,strfind(str,'4')) | ~cellfun(@isempty,strfind(str,'3')) );
  N_perc=100-(length(I)/length(str)*100);
  if N_perc==100 && ~strcmp(tmp2.PROFILE_PSAL_QC(n),'A')
    error('Error in PROFILE_PSAL_QC, N_perc==100')
    tmp2.PROFILE_PSAL_QC(n)='A';
  elseif (N_perc>=75 && N_perc<100) && ~strcmp(tmp2.PROFILE_PSAL_QC(n),'B')
    error('Error in PROFILE_PSAL_QC, N_perc>=75 && N_perc<100')
    tmp2.PROFILE_PSAL_QC(n)='B';
  elseif (N_perc>=50 && N_perc<75) && ~strcmp(tmp2.PROFILE_PSAL_QC(n),'C')
    error('Error in PROFILE_PSAL_QC, N_perc>=50 && N_perc<75')
    tmp2.PROFILE_PSAL_QC(n)='C';
  elseif (N_perc>=25 && N_perc<50) && ~strcmp(tmp2.PROFILE_PSAL_QC(n),'D')
    error('Error in PROFILE_PSAL_QC, N_perc>=25 && N_perc<50')
    tmp2.PROFILE_PSAL_QC(n)='D';
  elseif (N_perc>0 && N_perc<25) && ~strcmp(tmp2.PROFILE_PSAL_QC(n),'E')
    error('Error in PROFILE_PSAL_QC, N_perc>0 && N_perc<25')
    tmp2.PROFILE_PSAL_QC(n)='E';
  elseif (N_perc==0) && ~strcmp(tmp2.PROFILE_PSAL_QC(n),'F')
    error('Error in PROFILE_PSAL_QC, N_perc==0')
    tmp2.PROFILE_PSAL_QC(n)='F';
  end



% Checking for unrealistic GPS POSITION_QC
  if any(isnan(tmp2.LATITUDE(1)) || (abs(tmp2.LATITUDE(1))>90))
    disp(['Found unrealistic LATITUDE, anyway this is the POSITION_QC: ',tmp2.POSITION_QC(1),'; press any key if ok'])
    pause
  end
  if any(isnan(tmp2.LONGITUDE(1)) || (abs(tmp2.LONGITUDE(1))>180))
    disp(['Found unrealistic LONGITUDE, anyway this is the POSITION_QC: ',tmp2.POSITION_QC(1),'; press any key if ok'])
    pause
  end  
  
  tmp2.SCIENTIFIC_CALIB_EQUATION(:,:,1)'
  tmp2.SCIENTIFIC_CALIB_COEFFICIENT(:,:,1)'
  tmp2.SCIENTIFIC_CALIB_COMMENT(:,:,1)'
  tmp2.SCIENTIFIC_CALIB_DATE(:,:,1)'

end






%% 2nd a loop to generate the figures (step of 11)
t0=1; close all
for t=t0:t0+11 %numel(D)
  clear str tmp1 tmp2
  disp(' ')
  str=['tmp1=ncread_coriolis(''',path1,R(t).name,''');'];
  eval(str)
  disp(str)
  
  str=['tmp2=ncread_coriolis(''',path2,D(t).name,''');'];
  eval(str)
  disp(str)
  
%   figure; hold on; set(gcf,'position',[336  223 1120 738]);grid on;set(gca,'Ylim',[-2100 0]);ylabel('Depth');xlabel('PSAL')
%   title(['WMO ',num2str(float),' File name: *',D(t).name(10:end)],'fontsize',20)
%   hp1=plot(tmp1.PSAL(:,1),-tmp1.PRES(:,1),'.');
  
  figure; hold on; set(gcf,'position',[336  30 1120 738]);grid on;ylabel('Depth');xlabel('PSAL  (any 999 are to the right)')
  title(['WMO ',num2str(float),' File name: *',D(t).name(10:end)],'fontsize',20)
  
  clear R_sal* D_sal*
   for hh=1:length(tmp1.PSAL_QC)
     if size(tmp1.PSAL_QC(hh,:),2)>1 && ~isspace(tmp1.PSAL_QC(hh,end))
       R_sal_QC(hh,1)=tmp1.PSAL_QC(hh,end);
       R_sal(hh,1)=tmp1.PSAL(hh,end);
     else
       R_sal_QC(hh,1)=tmp1.PSAL_QC(hh,1); 
       R_sal(hh,1)=tmp1.PSAL(hh,1);
     end

% the adjusted values     
     if size(tmp2.PSAL_ADJUSTED_QC(hh,:),2)>1 && ~isspace(tmp2.PSAL_ADJUSTED_QC(hh,end))
       D_sal_QC(hh,1)=tmp2.PSAL_ADJUSTED_QC(hh,end);
       D_sal(hh,1)=tmp2.PSAL_ADJUSTED(hh,end);
     elseif size(tmp2.PSAL_ADJUSTED_QC(hh,:),2)==1 && ~isspace(tmp2.PSAL_ADJUSTED_QC(hh,1))
       D_sal_QC(hh,1)=tmp2.PSAL_ADJUSTED_QC(hh,1); 
       D_sal(hh,1)=tmp2.PSAL_ADJUSTED(hh,1);
     else
       D_sal_QC(hh,1)=R_sal_QC(hh,1); 
       D_sal(hh,1)=R_sal(hh,1);
     end     
   end   
          
     if abs(D_sal(hh)-R_sal(hh))>.1
       disp([' ']);disp(['Found difference between PSAL_ADJUSTED and PSAL at profile ',D(t).name(10:end)])      
       disp(['Depth: ',num2str(tmp1.PRES(hh,1)),' PSAL_ADJUSTED: ',num2str(D_sal(hh)),' PSAL: ',num2str(R_sal(hh))])

       disp(['PSAL_ADJUSTED_QC: ',tmp2.PSAL_ADJUSTED_QC(hh)])
       disp(['PSAL_QC: ',tmp1_PSAL_QC])
       pause
     end

%Checking the corresponding 999 in D-file
     if abs(R_sal(hh))>=999 && (abs(D_sal(hh))~=abs(R_sal(hh)))
       error('Found 999 in R-file and not the corresponding in D-file')
     end
%Checking 999 and the corresponding PSAL_ADJUSTED_QC
     if ~isspace(tmp2.PSAL_ADJUSTED_QC(hh)) && (abs(R_sal(hh))>=999 && str2num(tmp2.PSAL_ADJUSTED_QC(hh))<=3)
       error('Found 999 in R-file and not the corresponding QC in D-file')
     end     

   
   T=find(R_sal>=999); %missing data in R file
   I=find(D_sal>=999); %missing data in D file
   if any(T) %|| any(I)

    for H=1:length(T)
     if isempty(find(T(H)==I)) %Searching inside the D file the missing values found in the R file
       error('Bad data in R-file is not found in D-file, check T and I indexes')
     end
    end
    
    R_sal(T)=NaN;
    
    hp1=plot(R_sal,-tmp1.PRES(:,1),'.');
    set(gca,'Ylim',[-2100 0]);
    xlim=get(gca,'Xlim');

    hp3=plot(xlim(2),-tmp1.PRES(T,1),'go','markersize',13);
    plot(xlim(2),-tmp1.PRES(T,1),'go','markersize',15)
    plot(xlim(2),-tmp1.PRES(T,1),'go','markersize',17)

    hp3=plot(NaN,NaN,'go'); %Used only for graphics
   else
    hp1=plot(R_sal,-tmp1.PRES(:,1),'.');
    hp3=plot(NaN,NaN,'go'); %Used only for graphics

   end

   
   
   if any(I) 
    if length(I)~=length(D_sal) %does not plot in case all 999999
      axis_lim=get(gca,'xlim');
      hp2=plot(axis_lim(2),-tmp2.PRES_ADJUSTED(I,1),'ro');
      I_comp=~ismember([1:length(D_sal)],I);
      hp2=plot(D_sal(I_comp),-tmp2.PRES_ADJUSTED(I_comp,1),'ro');
    end
%     hp2=plot(NaN,NaN,'ro'); %Used only for graphics
   else
    hp2=plot(D_sal,-tmp2.PRES_ADJUSTED(:,1),'ro');
    hp3=plot(NaN,NaN,'go'); %Used only for graphics
   
   end

   YL=get(gca,'ylim');if min(YL)<-2000;set(gca,'ylim',[-2000 0]);end
   legend([hp1,hp2,hp3],'R-file PSAL','D-file PSAL\_ADJUSTED','In case of 999 in R file','location','SouthWest')
    
  
  
%second figure with the subplots  
  figure;subplot(2,3,1);set(gcf,'position',[1537            1         1536        788.8])
  hp4=plot([1:length(tmp1.PSAL_QC(:,1))],str2num(tmp1.PSAL_QC(:,1)),'.');
  hold on;hp5=plot([1:length(tmp2.PSAL_ADJUSTED_QC)],str2num(tmp2.PSAL_ADJUSTED_QC),'ro');
  legend([hp4,hp5],'Blue - R file PSAL\_QC','Red - D file PSAL\_ADJ\_QC','location','SouthWest')
  xlabel('n° vertical points'); ylabel('Flag number')
  title(['WMO ',num2str(float),' File name: *.',D(t).name(10:end)],'fontsize',20)
  set(gca,'ytick',[0:1:9])
  
%   for h=1:length(tmp1.PSAL_QC)
%     if ~strcmpi(tmp1.PSAL_QC(h),tmp2.PSAL_ADJUSTED_QC(h))
%       disp('different PSAL_QC, check!')
%     end
%   end

  
  subplot(2,3,3);hp4=plot([1:length(tmp1.PRES_QC(:,1))],str2num(tmp1.PRES_QC(:,1)),'.');
  hold on;hp5=plot([1:length(tmp2.PRES_ADJUSTED_QC)],str2num(tmp2.PRES_ADJUSTED_QC),'ro');
  legend([hp4,hp5],'Blue - R file PRES\_QC','Red - D file PRES\_ADJ\_QC','location','SouthWest')
  xlabel('n° vertical points'); ylabel('Flag number')
%   title(['WMO ',num2str(float),' File name: *.',D(t).name(10:end)],'fontsize',20)
  set(gca,'ytick',[0:1:9])

%   for h=1:length(tmp1.PRES_QC)
%     if ~strcmpi(tmp1.PRES_QC(h),tmp2.PRES_ADJUSTED_QC(h))
%       disp('different PRES_QC, check!')
%     end
%   end

  
  subplot(2,3,2);hp4=plot([1:length(tmp1.TEMP_QC(:,1))],str2num(tmp1.TEMP_QC(:,1)),'.');
  hold on;hp5=plot([1:length(tmp2.TEMP_ADJUSTED_QC)],str2num(tmp2.TEMP_ADJUSTED_QC),'ro');
  legend([hp4,hp5],'Blue - R file TEMP\_QC','Red - D file TEMP\_ADJ\_QC','location','SouthWest')
  xlabel('n° vertical points'); ylabel('Flag number')
%   title(['WMO ',num2str(float),' File name: *.',D(t).name(10:end)],'fontsize',20)
  set(gca,'ytick',[0:1:9])
   
%   for h=1:length(tmp1.TEMP_QC)
%     if ~strcmpi(tmp1.TEMP_QC(h),tmp2.TEMP_ADJUSTED_QC(h))
%       disp('different TEMP_QC, check!')
%     end
%   end

  
  subplot(2,3,4);hp4=plot([1:length(tmp1.PSAL_ADJUSTED_ERROR(:,1))],[tmp1.PSAL_ADJUSTED_ERROR(:,1)],'.');
  hold on;hp5=plot([1:length([tmp2.PSAL_ADJUSTED_ERROR(:,1)])],[tmp2.PSAL_ADJUSTED_ERROR(:,1)],'ro');
  legend([hp4,hp5],'Blue - R file PSAL\_ADJ\_ERROR','Red - D file PSAL\_ADJ\_ERROR','location','SouthWest')
  xlabel('n° vertical points'); ylabel('PSAL\_ADJUSTED\_ERROR')
%   title(['WMO ',num2str(float),' File name: *.',D(t).name(10:end)],'fontsize',20)

  
  subplot(2,3,5);hp4=plot([1:length(tmp1.TEMP_ADJUSTED_ERROR(:,1))],[tmp1.TEMP_ADJUSTED_ERROR(:,1)],'.');
  hold on;hp5=plot([1:length([tmp2.TEMP_ADJUSTED_ERROR(:,1)])],[tmp2.TEMP_ADJUSTED_ERROR(:,1)],'ro');
  legend([hp4,hp5],'Blue - R file TEMP\_ADJ\_ERROR','Red - D file TEMP\_ADJ\_ERROR','location','SouthWest')
  xlabel('n° vertical points'); ylabel('TEMP\_ADJUSTED\_ERROR')
%   title(['WMO ',num2str(float),' File name: *.',D(t).name(10:end)],'fontsize',20)

  
  subplot(2,3,6);hp4=plot([1:length(tmp1.PRES_ADJUSTED_ERROR(:,1))],[tmp1.PRES_ADJUSTED_ERROR(:,1)],'.');
  hold on;hp5=plot([1:length([tmp2.PRES_ADJUSTED_ERROR(:,1)])],[tmp2.PRES_ADJUSTED_ERROR(:,1)],'ro');
  legend([hp4,hp5],'Blue - R file PRES\_ADJ\_ERROR','Red - D file PRES\_ADJ\_ERROR','location','SouthWest')
  xlabel('n° vertical points'); ylabel('PRES\_ADJUSTED\_ERROR')
%   title(['WMO ',num2str(float),' File name: *.',D(t).name(10:end)],'fontsize',20)


end


