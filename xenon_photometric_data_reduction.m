%xenon photometric data reduction
clc
clear all
close all


cd('..\Photometric tests')

hrs = [0 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000 11000];
manufactures_specs.lumensBI = 6600;
manufactures_specs.lumensBM = 6030;
manufactures_specs.lumensFI = 9306;
manufactures_specs.lumensFM = 8502;
manufactures_specs.CCT = 4300;
manufactures_specs.CRI = 80;
manufactures_specs.sp_ratio = 1.65;

linewdth = 2;

%% ---------- Read in Data ------------
file_str = cellstr(ls);                                               %list of all files in directory
file_cell = regexpi(file_str, '\w+(.xlsx)', 'match');                        %find cells that end in ".xlsx"
file_cell2 = regexpi(file_str, '~', 'match');                        %remove entries that begin with ~ because those are copies of open files
temp1 = ~cellfun(@isempty,file_cell) & cellfun(@isempty,file_cell2);
% file_cell(cellfun(@isempty,file_cell)) = [];
file_cell(~temp1) = [];
first = 2;
last = 33;

for i = 1:length(file_cell)
    [num, txt, raw] = xlsread(char(file_cell{i}),'Summary');
    %     raw_num =
    lumens(:,i) = cell2mat(raw(first:last,12));
    CRI(:,i) = cell2mat(raw(first:last,41));
    CRIchart(:,:,i) = cell2mat(raw(first:last,27:40));
    CCT(:,i) = cell2mat(raw(first:last,19));
    x(:,i) = cell2mat(raw(first:last,13));
    y(:,i) = cell2mat(raw(first:last,14));
    z(:,i) = cell2mat(raw(first:last,15));
    spectral_power(:,:,i) = cell2mat(raw(first:last,44:484));
    duv(:,i) = cell2mat(raw(first:last,18));
    power(:,i) = cell2mat(raw(first:last,8));
    
    % for j = 1:8
    % fixture(j).lumens = cell2mat(raw(8,first:last));
    % fixture(j).spectral_power = cell2mat(raw(42:end,first:last));
    % fixture(j).CRI =
    % fixture(j).CCT =
    % fixture(j).lumens =
    % fixture(j).CIE =
    % fixture(j).Duv =
    % end
    % for j = 1:8
    % bare(j).lumens = cell2mat(raw(8,first:last));
    % bare(j).spectral_power = cell2mat(raw(42:end,first:last));
    % bare(j).CRI = cell2mat(raw(39,first:last));
    % bare(j).CCT =
    % bare(j).lumens =
    % bare(j).CIE =
    % bare(j).Duv =
    % end
    % cell2mat(raw(42:end,first:last))
end
%% ----------Efficacy------------
for i = 1:size(lumens,2)
    for j = 1:32
        efficacy(j,i) = lumens(j,i)./power(j,i);
    end
end

%% ------------scotopic ratio-------------
for i = 1:size(lumens,2)
    for j = 1:32
        scotopic_lumens(j,i) = calc_lumens(spectral_power(j,:,i),'scotopic');
        sp_ratio(j,i) = scotopic_lumens(j,i)/lumens(j,i);
    end
end
%% -----------average between arc tube options -------------
indices = [
    2 1
    4 3
    5 6
    7 8
    9 10
    11 12
    13 14
    16 15
    17 18
    20 19
    22 21
    24 23
    25 26
    28 27
    30 29
    32 31];

for i = 1:length(hrs)
    for j = 1:length(indices)
        lumens_temp = [lumens(indices(j,1),i) lumens(indices(j,2),i)];
        lumens_avg(j,i) = mean(lumens_temp(lumens_temp~=0&~isnan(lumens_temp)));
        
        CRI_temp = [CRI(indices(j,1),i) CRI(indices(j,2),i)];
        CRI_avg(j,i) = mean(CRI_temp(CRI_temp~=0&~isnan(CRI_temp)));
        
        CCT_temp = [CCT(indices(j,1),i) CCT(indices(j,2),i)];
        CCT_avg(j,i) = mean(CCT_temp(CCT_temp~=0&~isnan(CCT_temp)));
        
        duv_temp = [duv(indices(j,1),i) duv(indices(j,2),i)];
        duv_avg(j,i) = mean(duv_temp(duv_temp~=0&~isnan(duv_temp)));
        
        power_temp = [power(indices(j,1),i) power(indices(j,2),i)];
        power_avg(j,i) = mean(power_temp(power_temp~=0&~isnan(power_temp)));
        
        sp_ratio_temp = [sp_ratio(indices(j,1),i) sp_ratio(indices(j,2),i)];
        sp_ratio_avg(j,i) = mean(sp_ratio_temp(sp_ratio_temp~=0&~isnan(sp_ratio_temp)));
    end
end

%% -----------Determine when lamps burned out ------------------------
dum=0;
for i= 1:size(lumens_avg,1)
    hoursInd = find(isnan(lumens_avg(i,:)));
    if (length(hoursInd)==1 && hoursInd == size(lumens_avg,2)||(length(hoursInd)>1))
        dum=dum+1;
        offInd(dum,:) = [i,hoursInd(1)];
    end
end
%% -----------box plots---------
%boxplot ignors nan values for missing initial measurements
% % % initial_indices = [1 4 5 7 10 11 14];%

% % % initial_indices = [2 3 6 8 9 12 13]



% % figure;boxplot(CCT(1:16,:),hrs)
% % figure;boxplot(CCT(17:32,:),hrs)

%
% % figure;boxplot(CRI(1:16,:),hrs)
% % figure;boxplot(CRI(17:32,:),hrs)
% figure;boxplot(CRI(initial_indices,:),hrs)
%
% % figure;boxplot(lumens(1:16,:),hrs)
% % figure;boxplot(lumens(17:32,:),hrs)
% figure;boxplot(lumens(initial_indices,:),hrs)

colors = distinguishable_colors(20);

%% ---------------data Statistics-----------------
temp = logical(zeros(16,1));
bare = temp;
bare(8:16)=1;
fixtures = temp;
fixtures(1:7)=1;

b.lumens = lumens_avg;
b.CCT = CCT_avg;
b.CRI = CRI_avg;
b.duv = duv_avg;
parameter = {'lumens'
    'CCT'
    'CRI'
    'duv'};

for i = 1:length(parameter)
    a.(parameter{i}).bareInitial = mean(b.(parameter{i})(bare,1));
    a.(parameter{i}).fixturesInitial = mean(b.(parameter{i})(fixtures,1));
    noNan = ~isnan(b.(parameter{i})(:,end));
    a.(parameter{i}).bareFinal = mean(b.(parameter{i})(bare&noNan,end));
    a.(parameter{i}).fixturesFinal = mean(b.(parameter{i})(fixtures&noNan,end));
end

%% ------------------------------Plots------------------------------------------------------
%% -----------lumens---------
spec_color = [.5 .5 .5];
initial_indices = [16 17 20 22 24 25 28 30 32];
figure
hold all
plot([hrs(1) hrs(end)],[manufactures_specs.lumensBI,manufactures_specs.lumensBI],'Color',spec_color,'LineStyle','--')
plot([hrs(1) hrs(end)],[manufactures_specs.lumensBM,manufactures_specs.lumensBM],'LineStyle','-.','Color',spec_color)
% for i = 1:length(initial_indices)
%     plot(hrs,lumens(initial_indices(i),:),'Color',colors(i,:),'LineWidth', linewdth)
% end
for i = 8:16
    good = ~isnan(lumens_avg(i,:));
    plot(hrs(good),lumens_avg(i,good),'Color',colors(i-7,:),'LineWidth', linewdth)
end
legend('initial','mean','B1','B2','B3','B4','B5','B6','B7','B8','B9','Location','EastOutside')
title('Luminous Flux for Bare Lamps')
ylabel('Luminous Flux (lms)')
xlabel('Time (hours)')
for i = 8:16
    lampInd = find(offInd(:,1)==i);
    if ~isempty(lampInd)
        plot(hrs(offInd(lampInd,2)-1),lumens_avg(i,offInd(lampInd,2)-1),'Color',colors(i-7,:),'LineWidth', linewdth,'Marker','x','MarkerSize',12)
    end
end
grid on
xlim([0 hrs(end)])

initial_indices = [2 4 5 7 9 11 13];%
% initial_indices = [1 3 6 8 10 12 14];%
figure
hold all
plot([hrs(1) hrs(end)],[manufactures_specs.lumensFI,manufactures_specs.lumensFI],'LineStyle','--','Color',spec_color)
plot([hrs(1) hrs(end)],[manufactures_specs.lumensFM,manufactures_specs.lumensFM],'LineStyle','-.','Color',spec_color)
% for i = 1:length(initial_indices)
%     plot(hrs,lumens(initial_indices(i),:),'Color',colors(i,:),'LineWidth', linewdth)
% end
for i = 1:7
    good = ~isnan(lumens_avg(i,:));
    plot(hrs(good),lumens_avg(i,good),'Color',colors(i,:),'LineWidth', linewdth)
end
legend('initial','mean','1','2','3','4','5','6','7','Location','EastOutside')
title('Luminous Flux for Fixtures')
ylabel('Luminous Flux (lms)')
xlabel('Time (hours)')

for i = 1:7
    lampInd = find(offInd(:,1)==i);
    if ~isempty(lampInd)
        plot(hrs(offInd(lampInd,2)-1),lumens_avg(i,offInd(lampInd,2)-1),'Color',colors(i,:),'LineWidth', linewdth,'Marker','x','MarkerSize',12)
    end
end
grid on
xlim([0 hrs(end)])
% figure;boxplot(lumens(initial_indices,:),hrs)

%%  -------- Scotopic ratio
initial_indices = [2 4 5 7 9 11 13 16 17 20 22 24 25 28 30 32];
figure
hold all
plot([hrs(1) hrs(end)],[manufactures_specs.sp_ratio,manufactures_specs.sp_ratio],'LineStyle','--','Color',spec_color)
% for i = 1:length(initial_indices)
%     plot(hrs,sp_ratio(initial_indices(i),:),'Color',colors(i,:),'LineWidth', linewdth)
% end
for i = 1:length(indices)
    good = ~isnan(sp_ratio_avg(i,:));
    plot(hrs(good),sp_ratio_avg(i,good),'Color',colors(i,:),'LineWidth', linewdth)
end
legend('spec','1','2','3','4','5','6','7','B1','B2','B3','B4','B5','B6','B7','B8','B9','Location','EastOutside')
title('Scotopic/Photopic Ratio')
ylabel('S/P Ratio')
xlabel('Time (hours)')
% figure;boxplot(lumens(initial_indices,:),hrs)
for i = 1:16
    lampInd = find(offInd(:,1)==i);
    if ~isempty(lampInd)
        plot(hrs(offInd(lampInd,2)-1),sp_ratio_avg(i,offInd(lampInd,2)-1),'Color',colors(i,:),'LineWidth', linewdth,'Marker','x','MarkerSize',12)
    end
end
grid on
xlim([0 hrs(end)])

initial_indices = [2 4 5 7 9 11 13 16 17 20 22 24 25 28 30 32];
%%  --------CRI------------
figure
hold all
plot([hrs(1) hrs(end)],[manufactures_specs.CRI,manufactures_specs.CRI],'LineStyle','--','Color',spec_color)
% for i = 1:length(initial_indices)
%     plot(hrs,CRI(initial_indices(i),:),'Color',colors(i,:),'LineWidth', linewdth)
% end
for i = 1:length(indices)
    good = ~isnan(CRI_avg(i,:));
    plot(hrs(good),CRI_avg(i,good),'Color',colors(i,:),'LineWidth', linewdth)
end
h = gca;
set(h,'YLim',[0,100])
title('Color Rendering Index')
ylabel('CRI (Ra)')
xlabel('Time (hours)')
% legend('spec','B1','B2','B3','B4','B5','B6','B7','B8','B9','1','2','3','4','5','6','7','Posistion','EastOutside')
legend('spec','1','2','3','4','5','6','7','B1','B2','B3','B4','B5','B6','B7','B8','B9','Location','EastOutside')
for i = 1:16
    lampInd = find(offInd(:,1)==i);
    if ~isempty(lampInd)
        plot(hrs(offInd(lampInd,2)-1),CRI_avg(i,offInd(lampInd,2)-1),'Color',colors(i,:),'LineWidth', linewdth,'Marker','x','MarkerSize',12)
    end
end
grid on
xlim([0 hrs(end)])

% figure;boxplot(CRI(initial_indices,:),hrs)
%% --------CCT------------
figure
hold all
plot([hrs(1) hrs(end)],[manufactures_specs.CCT,manufactures_specs.CCT],'LineStyle','--','Color',spec_color)
% for i = 1:length(initial_indices)
%     plot(hrs,CCT(initial_indices(i),:),'Color',colors(i,:),'LineWidth', linewdth)
% end
for i = 1:length(indices)
    good = ~isnan(CCT_avg(i,:));
    plot(hrs(good),CCT_avg(i,good),'Color',colors(i,:),'LineWidth', linewdth)
end
h1 = gca;
set(h1,'YLim',[0,6500])
title('Correlated Color Temperature')
ylabel('CCT (Kelvin)')
xlabel('Time (hours)')
legend('spec','1','2','3','4','5','6','7','B1','B2','B3','B4','B5','B6','B7','B8','B9','Location','EastOutside')
% figure;boxplot(CCT(initial_indices,:),hrs)
for i = 1:16
    lampInd = find(offInd(:,1)==i);
    if ~isempty(lampInd)
        plot(hrs(offInd(lampInd,2)-1),CCT_avg(i,offInd(lampInd,2)-1),'Color',colors(i,:),'LineWidth', linewdth,'Marker','x','MarkerSize',12)
    end
end
grid on
xlim([0 hrs(end)])

%% --------Duv------------
figure
hold all
% for i = 1:length(initial_indices)
%     plot(hrs,duv(initial_indices(i),:),'Color',colors(i,:),'LineWidth', linewdth)
% end
for i = 1:length(indices)
    good = ~isnan(duv_avg(i,:));
    plot(hrs(good),duv_avg(i,good),'Color',colors(i,:),'LineWidth', linewdth)
end
h1 = gca;
set(h1,'YLim',[-0.02 0.02])
title('Deviation From the Black Body Locus')
ylabel('Duv')
xlabel('Time (hours)')
legend('1','2','3','4','5','6','7','B1','B2','B3','B4','B5','B6','B7','B8','B9','Location','EastOutside')
% figure;boxplot(duv(initial_indices,:),hrs)
for i = 1:16
    lampInd = find(offInd(:,1)==i);
    if ~isempty(lampInd)
        plot(hrs(offInd(lampInd,2)-1),duv_avg(i,offInd(lampInd,2)-1),'Color',colors(i,:),'LineWidth', linewdth,'Marker','x','MarkerSize',12)
    end
end
grid on
xlim([0 hrs(end)])

%% --------power------------
figure
hold all
% for i = 1:length(initial_indices)
%     plot(hrs,duv(initial_indices(i),:),'Color',colors(i,:),'LineWidth', linewdth)
% end
for i = 1:length(indices)
    good = ~isnan(power_avg(i,:));
    plot(hrs(good),power_avg(i,good),'Color',colors(i,:),'LineWidth', linewdth)
end
h1 = gca;
% set(h1,'YLim',[-0.02 0.02])
title('Deviation From the Black Body Locus')
ylabel('Duv')
xlabel('Time (hours)')
legend('1','2','3','4','5','6','7','B1','B2','B3','B4','B5','B6','B7','B8','B9','Location','EastOutside')
figure;boxplot(duv(initial_indices,:),hrs)
for i = 1:16
    lampInd = find(offInd(:,1)==i);
    if ~isempty(lampInd)
        plot(hrs(offInd(lampInd,2)-1),power_avg(i,offInd(lampInd,2)-1),'Color',colors(i,:),'LineWidth', linewdth,'Marker','x','MarkerSize',12)
    end
end
grid on
xlim([0 hrs(end)])


%%
% % temp2=[];
% % for i = 1:length(file_cell)
% %     temp = csvread(char(file_cell{i}));
% %     temp2 = [temp2; temp];
% % end
%
%
% % first = 25;
% % last = 33;
% wavelengths = cell2mat(raw(1,44:484));
% % spectral_power = cell2mat(raw(42:end,first:last));
% % lumens = cell2mat(raw(8,first:last));
% % colors = hsv(length(lumens(:,1)));
% figure
% hold all
% for i = 1:length(initial_indices)
%     plot(wavelengths,spectral_power(initial_indices(i),:,2)/trapz(wavelengths,spectral_power(initial_indices(i),:,2)), 'Color', colors(i,:))
% end
% xlabel('nm')
% ylabel('W/W')