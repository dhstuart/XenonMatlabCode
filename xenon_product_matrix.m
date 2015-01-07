%xenon product matrix
clc
close all
clear all


tabs = {
    'Less than 100 W'
    '100 W Comparison'
    '150 W Comparison'
    '200 W Comparison'
    '250 W Comparison'};

scotopic_correction_factor = [
    1.96	%Induction		5000k fluorescent
    1.49	%Metal Halide
    0.62	%HPS
    2.14	%LED	cool white
    1.5	    %LED	warm white
    1.96	%Fluorescent    5000k
    1.65	];    %Xenon	(manufacturer's lit)




for j = 1:length(tabs);   %loop over technologies (different sheets in each workbook)
    [num,txt,raw] = xlsread('Xenon Product Comp 2012_09_11.xlsx',tabs{j});
    %         a.(company{i}).(technology{j}).data = raw;
    %     new = raw(2:end,1:end);      %extract only pertinent data
    %             new = [new num2cell([new{:,2}]'./[new{:,1}]') num2cell([new{:,4}]'./[new{:,1}]')]; %calculate luminous efficacy and candle power efficacy, add to database
    %             for i = 2:length(raw)
    
    %initial deli/vered lumens 17
    lumens_index = 15;
    %luminaire efficacy scotopic 23
    
    labels = raw(4:end,1);
    lamp_type_temp = raw(2,cell2mat(raw(1,:))==1);
    data_temp = raw(4:end,cell2mat(raw(1,:))==1);
    
    if j==1
        lamp_type = [lamp_type_temp];
        data = [data_temp];
    else
        lamp_type = [lamp_type lamp_type_temp];
        data = [data data_temp];
    end
    
end

data=data';
lamp_type = lamp_type';

both = [lamp_type data];

ranges = [2500 5000
    5000 7500
    7500 12500
    12500 17500
    17500 22500];


for i = 1:length(ranges)
    ranges_names{i} = ['r' num2str(ranges(i,1)) '_' num2str(ranges(i,2))];
    index.(ranges_names{i}) = cell2mat(both(:,lumens_index))>ranges(i,1)&cell2mat(both(:,lumens_index))<ranges(i,2);
end
tech_type = unique(both(:,1));
tech_type_names =strrep(tech_type, ' ', '_');
tech_type_names =strrep(tech_type_names, ',', '');
tech_type_names =strrep(tech_type_names, '(', '');
tech_type_names =strrep(tech_type_names, ')', '');
for i = 1:length(tech_type)
    index.(tech_type_names{i}) = strcmp(both(:,1), tech_type(i));
end

%calculate stats
photopic_index = 20;
lumens_index = 15;
scotopic_index = 21;
cri_index = 7;
lifetime_index = 10;
for i = 1:length(ranges)
    for j = 1:length(tech_type)
        %         photopic_table(i,j) =
        temp_photopic_efficacy = both(index.(tech_type_names{j})&index.(ranges_names{i}),photopic_index);
        temp_lumens = both(index.(tech_type_names{j})&index.(ranges_names{i}),lumens_index);
        temp_scotopic_efficacy = both(index.(tech_type_names{j})&index.(ranges_names{i}),scotopic_index);
        temp_cri = both(index.(tech_type_names{j})&index.(ranges_names{i}),cri_index);
        temp_lifetime = both(index.(tech_type_names{j})&index.(ranges_names{i}),lifetime_index);
        
        if length(temp_photopic_efficacy)==0
        elseif length(temp_photopic_efficacy)==1
            photopic_table(i,j) = cell2mat(temp_photopic_efficacy);
        else
            photopic_table(i,j) = mean(cell2mat(temp_photopic_efficacy));
        end
        
        if length(temp_lumens)==0
        elseif length(temp_lumens)==1
            lumens_table(i,j) = cell2mat(temp_lumens);
        else
            lumens_table(i,j) = mean(cell2mat(temp_lumens));
        end
        
        if length(temp_scotopic_efficacy)==0
        elseif length(temp_scotopic_efficacy)==1
            scotopic_table(i,j) = cell2mat(temp_scotopic_efficacy);
        else
            scotopic_table(i,j) = mean(cell2mat(temp_scotopic_efficacy));
        end
        
        if length(temp_cri)==0
        elseif length(temp_cri)==1
            cri_table(i,j) = cell2mat(temp_cri);
        else
            cri_table(i,j) = mean(cell2mat(temp_cri));
        end
        
        if length(temp_lifetime)==0
        elseif length(temp_lifetime)==1
            lifetime_table(i,j) = cell2mat(temp_lifetime);
        else
            lifetime_table(i,j) = mean(cell2mat(temp_lifetime));
        end
        
        
    end
end


tech_type = {
'HPS'
'Induction'
'LED'
'CMH'
'MH pulse'
'MH probe'
'xenon'};


b=mean(ranges')';

marker_size = 30;
line_style = 'none';

photopic_table(photopic_table == 0) = NaN;
figure
clear bb
for i = 1:size(photopic_table,2)
    
    no_nan_index = ~isnan(photopic_table(:,i));
    bb{i} = [lumens_table(no_nan_index,i) photopic_table(no_nan_index,i)];
    hold all
    plot(bb{i}(:,1),bb{i}(:,2),'marker','.','MarkerSize',marker_size,'LineStyle',line_style)
    
end
ylim2 = get(gca, 'Ylim');
set(gca,'Ylim',[0 ylim2(2)])
xlabel('luminous flux (lm)');
ylabel('photopic luminous efficacy (lms/W)');
grid on
legend(tech_type)




scotopic_table(scotopic_table == 0) = NaN;
figure
for i = 1:size(scotopic_table,2)
    
    no_nan_index = ~isnan(scotopic_table(:,i));
    bb{i} = [lumens_table(no_nan_index,i) scotopic_table(no_nan_index,i)];
    hold all
    plot(bb{i}(:,1),bb{i}(:,2),'Marker','.','MarkerSize',marker_size,'LineStyle',line_style)
    
end
ylim2 = get(gca, 'Ylim');
set(gca,'Ylim',[0 ylim2(2)])
xlabel('luminous flux (lm)');
ylabel('scotopic luminous efficacy (lm/W)');
grid on
legend(tech_type)



cri_table(cri_table == 0) = NaN;
figure
clear bb
for i = 1:size(cri_table,2)
    
    no_nan_index = ~isnan(cri_table(:,i));
    hold all
    bb{i} = [lumens_table(no_nan_index,i) cri_table(no_nan_index,i)];
    plot(bb{i}(:,1),bb{i}(:,2),'marker','.','MarkerSize',marker_size,'LineStyle',line_style)
    
%         bb{i} = [photopic_table(no_nan_index,i) cri_table(no_nan_index,i)];
%         scatter(bb{i}(:,1),bb{i}(:,2),'filled')

    
end
ylim2 = get(gca, 'Ylim');
set(gca,'Ylim',[0 ylim2(2)*1.1])
xlabel('luminous flux (lm)');
% xlabel('luminous efficacy (lm/W)');
ylabel('CRI (R_a)');
grid on
legend(tech_type)



lifetime_table(lifetime_table == 0) = NaN;
figure
clear bb
for i = 1:size(lifetime_table,2)
    
    no_nan_index = ~isnan(lifetime_table(:,i));
    hold all
    bb{i} = [lumens_table(no_nan_index,i) lifetime_table(no_nan_index,i)];
    plot(bb{i}(:,1),bb{i}(:,2),'marker','.','MarkerSize',marker_size,'LineStyle',line_style)

%     bb{i} = [photopic_table(no_nan_index,i) lifetime_table(no_nan_index,i)];
%     scatter(bb{i}(:,1),bb{i}(:,2),'filled')
    
end
ylim2 = get(gca, 'Ylim');
set(gca,'Ylim',[0 ylim2(2)*1.1])
xlabel('luminous flux (lm)');
% xlabel('luminous efficacy (lm/W)');
ylabel('lifetime (h)');
grid on
legend(tech_type)


avg_incumbent_efficacy = mean(nanmean(photopic_table(:,[1 5 6])));
avg_incumbent_scotopic_efficacy = mean(nanmean(scotopic_table(:,[1 5 6])));
avg_incumbent_lifetime = mean(nanmean(lifetime_table(:,[1 5 6])));
avg_incumbent_CRI  = mean(nanmean(cri_table(:,[5 6])));