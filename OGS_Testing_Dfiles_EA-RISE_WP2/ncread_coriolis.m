% function M=ncread_coriolis(filename)
% returns a structured data corresponding to the file content.
% GB 15.07.2010
% AB 14.02.2012
function M=ncread_coriolis(filename)

ncid = netcdf.open(filename, 'NC_NOWRITE');

[~, nvars, natts, ~] = netcdf.inq(ncid);

globalConst=netcdf.getConstant('NC_GLOBAL');
for attID=0:natts-1.
    %if attID== 14 %AB colpa della variabile con i : dentro...
    %    ppp=0;
    %end
    
    attname  = netcdf.inqAttName(ncid,globalConst,attID  );
    attnamematlab  = strrep(attname,':','_'); %AB per problema nomi con :
    
    attvalue = netcdf.getAtt(    ncid,globalConst,attname);
    %ppp=['Global.' attname '=attvalue; '] %AB
    eval(['Global.' attnamematlab '=attvalue; ']); 
end

if globalConst<0
else
    M.Attributes.Global=Global;
end

for varID=0:nvars-1
%    disp (['varID=' num2str(varID)]); %debug
    [varname, ~, ~, numatts] = netcdf.inqVar(ncid,varID); 
%     if (strcmp('LATITUDE',varname))
%     ppp=0
%     end
    varname=cutname(varname,63); %AB 20131106

    Attributes=struct;%clear Attributes
    for attID=0:numatts-1,
%         disp (['varID=' num2str(varID) '   attID=' num2str(attID)]); %debug
%         if (varID==73  && attID==2)
%             qweqweqweqweqwe=0;
%         end
        attname  = netcdf.inqAttName(ncid,varID,attID  );
        attvalue = netcdf.getAtt(    ncid,varID,attname);
        if attname(1)=='_', attname(1)=[]; end
        eval(['Attributes.' attname '=attvalue; ']);

    end
    
    data=netcdf.getVar(ncid, varID);
    %data=strcat(netcdf.getVar(ncid, varID)'); 
    
    if strcmp(varname,'TECHNICAL_PARAMETER_NAME')
    %varname strutturata
        [qrighe qcolonne]=size(data);
        for i=1:qcolonne
            if i ==10
                BATTtrovato=1;
            else
            end
            varname1=strcat(data(:,i))'; %CURRENT_BatteryPark_mAMPS (id=10)
            varname1=cutname(varname1,63); %AB 20131106

            str=['M.' varname '.' varname1 '=data;']; eval(str);
            str=['M.Attributes.' varname '.' varname1 ' =Attributes;']; eval(str);
        end
    else
        str=['M.' varname '=data;']; eval(str); 
        str=['M.Attributes.' varname ' = Attributes;']; eval(str);
    end
    if strcmp(varname,'TECHNICAL_PARAMETER_VALUE')
        [qrighe qcolonne]=size(data);
        for i=1:qcolonne
            varvalue2=strcat(data(:,i))';
            if ischar(varvalue2)
                varvalue2=['''' varvalue2 ''''];
            end
            str=['M.' varname '.' varname1 '=' varvalue2 ';']; eval(str);
            str=['M.Attributes.' varname '.' varname1 ' = ' varvalue2 ';']; eval(str);
            %Attributes
        end
    else
    end
    %M=orderfields(M); %AB 20140922
end

netcdf.close(ncid); 
end

function out_var=cutname(invar,numchar)
    if (length(invar)>numchar)
        out_var=invar(1:numchar);
    else
        out_var=invar;
    end
end
% M=doubleAndFillvalue2NaN(M);
