%Xenon Data reduction
%test change
clear all
close all
clc
%look in folder for file names
cd('C:\Users\dhstuart\Documents\LabVIEW Data\xenon data')
file_str = cellstr(ls);                                               %list of all files in directory
file_cell = regexpi(file_str, '\w+(.csv)', 'match');                        %find cells that end in ".csv"
file_cell(cellfun(@isempty,file_cell)) = [];
% norm_values = [9.655 8.888 8.394 10.39 9.106 9.234 8.546 7.15 7.841 4.032 6.136 4.215 5.747 5.218 8.244 7.592 7.779 7.096 7.862 8.163 8.452 7.999 6.618 5.586 6.452 7 5.108 3.735 7.57 6.49 8.61 6.226];
temperature_indices = {(0:2);(3:5);(6:8);(9:11);(12:14);(15:17);(18:20);(21:24);(25:28);(29:32);(33:36);(37:40);(41:44);(45:48);49;50;51;52;53;54;55;56;57;58;59;60;61;62;63;64;65;66;67;68;69;70};

period_end = [3450232688.983]; %labview time at the end of the measurement period
period_end_hrs = [46842];

temp2=[];
for i = 1:length(file_cell)
    disp([num2str(i) '/' num2str(length(file_cell))])
    temp = csvread(char(file_cell{i}));
    temp2 = [temp2; temp];
end

%get time
%
data = temp2(:,2:end);
labviewtime = temp2(:,1);




%% manually fix data

% % % cut out collecting data at 3451771268.986, started again at 3451934702.471 (lights were on may 18 18:21 - may 20 15:45, 45.3981 hrs)
%this still cuts out 4 hours that shouldn't be because the lights were on during 4 off periods. needs to be fixed
time_temp  = (3451771269+60:60:3451934702-60)';
start_time = find(labviewtime == 3451771268.986);
end_time = find(labviewtime == 3451934702.471);
labviewtime = [labviewtime(1:start_time); time_temp; labviewtime(end_time:end)];
% current_level = data(start_time,1:32);
current_level = data(start_time,:);

% data = [data(1:start_time,:); repmat([norm_values 10*ones(1,71)],[length(time_temp),1]); data(end_time:end,:)];
% max_values = max(data(:,1:32));
% data = [data(1:start_time,:); repmat([current_level 10*ones(1,71)],[length(time_temp),1]); data(end_time:end,:)];
data = [data(1:start_time,:); repmat(current_level,[length(time_temp),1]); data(end_time:end,:)];


% % % cut out collecting data at 3453757329.273 started again at 3453812586.931 (10-Jun-2013 18:02:09 - 11-Jun-2013 09:23:06)
time_temp  = (3453757329+60:60:3453812587-60)';     %fill in the missing times with minute intervals
start_time = find(labviewtime == 3453757329.273);
end_time = find(labviewtime == 3453812586.931);
labviewtime = [labviewtime(1:start_time); time_temp; labviewtime(end_time:end)];
current_level = data(start_time,:);

data = [data(1:start_time,:); repmat(current_level,[length(time_temp),1]); data(end_time:end,:)];
%% -------------- change time from labview to matlab ----------------


time_days = LabviewTime2MatlabTime(labviewtime);
time = (time_days-time_days(1))*24;
% matlab_time = datestr(time_days); %formatted absolute time string

% ts = timeseries(data,datestr(time));


% %% ------------remove time when off------------
% average_light_level = zeros(1,size(data,2));
% temp = 24-(time_days(1)-floor(time_days(1)))*24;
% time_hrs = (time_days-time_days(1))*24-temp;
% time_end = time_hrs(end);
% total_index = logical(ones(size(time_hrs)));
% for i = 1:floor(time_end/12)
%     delete_index = time_hrs> 12*(i-1)+11 & time_hrs< 12*(i-1)+12.1;   %delete timesd after 11 and before 12
%     total_index = total_index & ~delete_index;
%     average_index = time_hrs> 12*(i-1) & time_hrs< 12*(i-1)+11;
%     average_light_level(i,:) = mean(data(average_index,:));
% %     average_time(i,:) = mean(time(average_index,:));
% %     figure;plot(time_hrs,delete_index)
% end
% average_time = (6:12:time_hrs(end)-12)';
% time_delete = time_hrs(total_index);
% data_delete = data(total_index,:);
% data = data_delete;
% time= time_delete;
% % time=(1:length(time_delete))/60;
% %need to remove between 11 and 12, but hide some portion just after startup, not delete


%% ------------remove time when off------------
average_light_level = zeros(1,size(data,2));
temp = 24-(time_days(1)-floor(time_days(1)))*24;
time_hrs = (time_days-time_days(1))*24-temp;
time_end = time_hrs(end);
total_index = logical(ones(size(time_hrs)));
time2 = time_hrs(1:194);    %first interval until 11pm
data2 = data(1:194,:);
indices_array = [];
for i = 1:floor(time_end/12)
    disp([num2str(i) '/' num2str(floor(time_end/12))])
    %     delete_logical = time_hrs> 12*(i-1)+11 & time_hrs< 12*(i-1)+12.1;   %delete timesd after 11 and before 12
    %     total_index = total_index & ~delete_logical;
    keep_logical = time_hrs> 12*(i-1)+0 & time_hrs< 12*(i-1)+11;   %keep times between 12 and 11 and count toward total hrs
    only_show_logical = time_hrs> 12*(i-1)+0.1 & time_hrs< 12*(i-1)+11;   %do not plot the first several minutes during warm up

    
    if sum(keep_logical)
        keep_index = find(keep_logical==1);
        time_diff = time(keep_index(end))-time(keep_index(1));
        indices_array = [indices_array; keep_index];
        %         time2 = [time2; time(keep_logical)-time(keep_index(1))+time2(end)];% time2(1:delete_index(1)-1); time2(delete_index(end)+1:end)-time_diff]; %initial time include the hour offset
        %         data2 = [data2; data(keep_logical,:)];
        time2 = [time2; time(only_show_logical)-time(keep_index(1))+time2(end)];% time2(1:delete_index(1)-1); time2(delete_index(end)+1:end)-time_diff]; %initial time include the hour offset
        data2 = [data2; data(only_show_logical,:)];
    else
        i
    end
    %     average_index = time_hrs> 12*(i-1) & time_hrs< 12*(i-1)+11;
    %     average_light_level(i,:) = mean(data(average_index,:));
    %     average_time(i,:) = mean(time(average_index,:));
    %     figure;plot(time_hrs,delete_index)
end
average_time = (6:12:time_hrs(end)-12)';
% time_delete = time_hrs(total_index);
% data_delete = data(total_index,:);
% data = data_delete;
% time= time_delete;
% time=(1:length(time_delete))/60;
%need to remove between 11 and 12, but hide some portion just after startup, not delete
time2 = time2-time2(1);
% figure;plot(time2,data2(:,1))


%% ----------------- manually fix data ----------------------
% % % cut out collecting data at 3451771269, started again at 3451934702 (lights were on may 18 18:21 - may 20 15:45, 45.3981 hrs)
% % datestr(LabviewTime2MatlabTime(3451771269))
% % start_time = LabviewTime2MatlabTime(3451771269);
% % end_time = LabviewTime2MatlabTime(3451934702);
% % temp = ones((end_time-start_time)*24*60,1);
% % linspace(start_time
%
%
%
%
% % %cut out at 3452375342.831 turned back on at 3452609468 (LIGHTS OFF may 25 18:09-may 28 11:11, 65.035 hrs)
% % labviewtime = labviewtime(total_index);
% off_index = find(labviewtime == 3452375342.831);
% labviewtime = [labviewtime(1:off_index) ;labviewtime(off_index+1:end)-(labviewtime(off_index+1)-labviewtime(off_index))];
%
% temp_delete = find(indices_array == off_index);
% time3 = [time2(1:temp_delete); time2(temp_delete+1:end)-(time2(temp_delete+1)-time2(temp_delete))];
%
% % data = [data(1:off_index,:) ;zeros(1,103);data(off_index+1:end,:)];
%
% % %inspection between 3452818924 and 3453470529.657 (LIGHTS OFF may 30 21:22 - jun 7 10:22, inspection period )
% % off_index = find(labviewtime == 3452818924);
% % labviewtime = [labviewtime(1:off_index) ;labviewtime(off_index+1:end)-(labviewtime(off_index+1)-labviewtime(off_index))];
% % % labviewtime = [labviewtime(1:off_index) ;labviewtime(off_index)+.01;labviewtime(off_index+1:end)];
% % % data = [data(1:off_index,:) ;zeros(1,103);data(off_index+1:end,:)];
%
%
%
% time_days = LabviewTime2MatlabTime(labviewtime);
% time = (time_days-time_days(1))*24;
%
% % first_day
% % 24*(LabviewTime2MatlabTime(3448681150) - LabviewTime2MatlabTime(3448662721.455))-1
% % last day
% % 4.119 hrs
% % 24*(LabviewTime2MatlabTime(3452818924) - LabviewTime2MatlabTime(3452742005)) - 1
% % 20.366 hrs
%%



% % find average light level of each 11 hr period
% for i = 1:floor(time_end)
%     avg_index = time_hrs> i-1 & time_hrs< i;
%     time_hr_avg(i) = i;
%     for j= 1:size(data,2)
%         data_hr_avg(i,j) = mean(data(avg_index,j));
%     end
%     %     total_index = total_index & ~delete_index;
%     %     figure;plot(time_hrs,delete_index)
% end

% figure
% % hold on
% % for i = 101:104
% % time = temp2(:,1);
% plot(time,temp2(:,101),time,temp2(:,102),time,temp2(:,103),time,temp2(:,104))
% % plot(ts(100))
% title('ambient temps')
% legend('8-5','9-5','13-2','14-2')
% % end
%
%
% % normalize light level
% % norm_level = [];
numbins = 20;
% n = zeros(32,numbins);
% xout = n;b=n;ix = n;
% for i = 9:15
%     %     maxi(i) = max(temp2(:,i));
%     [n(i,:), xout(i,:)]=hist(temp2(:,i),numbins);
% %     hist(temp2(:,i),20);
%     [b(i,:), ix(i,:)] = sort(n(i,:));
%     norm(i) = xout(i,ix(i,end));
% end

%% ----------------- Separate using regression -----------------
% for i = 15%:23
% lower_limit = .6;
% number = i;
% tempx = time;
% tempy = data(:,number)/norm_values(number);
% % tempx = average_time;
% % tempy = average_light_level(:,number)/norm_values(number);
% p = polyfit(tempx,tempy,1);
% r = robustfit(tempx,tempy);
% tempy2= tempy-tempx.*(p(1)/2);
% no_zeros = tempy2>lower_limit;
% levels = statelevels(tempy2(no_zeros));
% upper = tempy2>mean(levels);
% lower = tempy2<mean(levels)&tempy2>lower_limit;
% figure
% hold all
% % plot(tempx(upper),tempy2(upper),'.',tempx(lower),tempy2(lower),'.')
% % plot(tempx(upper),tempy(upper),'.',tempx(lower),tempy(lower),'.')
% plot(tempx,tempy)
% plot(average_time+5.184,average_light_level(:,number)/norm_values(number),'rx')
% plot(tempx,r(1)+r(2)*tempx,'g','LineWidth',2)
% axis([0 900 0 1.1])
% title(i)
% % for j=0:12
% end

%% ------------segmented cluster search--------------
% number = 1
% search_length = 5000;
% num_clusters = 20;
% c=[];
% for i = 1%:size(data,1)/search_length
%     i
%     initial = (i-1)*search_length+1;
%     final = initial+search_length;
%     tempx = time(initial:final);
%     tempy = data(initial:final,number)/norm_values(number);
%     X = [tempx tempy];
% %     d = pdist();
%     Z = linkage(X);
%     ctemp = cluster(Z,num_clusters)%+num_clusters*(i-1);
% %     c = [c;ctemp];
%     [H,T] = dendrogram(Z,0);%'colorthreshold','default');
%     set(H,'LineWidth',2)
% end
% % g = unique(c)
% % figure;hold all;for i = 1:g(end);plot(time(c==i),data(c==i,number)/norm_values(number));end
%
% T = cluster(Z,'cutoff',15,'depth',100);
% [C,ia,ic] = unique(T)
% figure;hold all;for i = 1:C(end);plot(time(T==i),data(T==i,number)/norm_values(number));end %plot each unique cluster
% cluster_temp_index = (diff(ia))>50; %clusters we're interested in have lengths greater than 'x'
%
%
%
% dum=0;
% for i = 1:length(cluster_temp_index)
%     if cluster_temp_index(i) == 1
%         dum = dum+1;
%         cluster_index(dum,:) = [ia(i) ia(i+1)];
%     end
% end
% figure;hold all;for i = 1:size(cluster_index,1);plot(time(cluster_index(i,1):cluster_index(i,2)),data(cluster_index(i,1):cluster_index(i,2),number)/norm_values(number));
% % pause
% end

%% -------------- re-normalize ----------------------------
% index_at_end_of_period = find(labviewtime == period_end);
index_at_end_of_period = period_end_hrs;
t_length = 60*3;
average_last_light_reading = mean(data2(index_at_end_of_period-t_length:index_at_end_of_period,:));
average_new_light_reading = mean(data2(index_at_end_of_period+1:index_at_end_of_period+t_length,:));
%46843

%% --------------calc time on ----------------
for i = 1:32
    %     norm_level(:,i) = data2(:,i)/norm_values(i);
    multiplier(i) = average_last_light_reading(i)/average_new_light_reading(i);
    norm_level(:,i) = [data2(1:period_end_hrs,i)/max(data2(1:period_end_hrs,i)); data2(period_end_hrs+1:end,i)/max(data2(1:period_end_hrs,i))*multiplier(i)];

    if i == 26
        norm_level(:,i) = data2(:,i)/7; %manually fix B12 to show that it is off
    end
    
end
% off_level = .035;
% % for i = 1:32
% run_time = (norm_level>off_level).*[repmat(diff(time),[1,32]);zeros(1,32)];
%
% sum(run_time)
% % end
hrs = [0 round(time2(end)/1000)*1000];

%% -------------  Plots ----------------------------
% light levels

figure
for i= 1:7
    subplot(4,2,i)
    plot(time2,norm_level(:,i))
    axis([hrs(1) hrs(end) 0 1])
    grid on
    title(sprintf('Fixture %d',i))
    xlabel('run hours')
    ylabel('relative light level')
end
set(gcf, 'Position', [0 0 700 900])

figure
for i= 15:23
    subplot(5,2,i-14)
    plot(time2,norm_level(:,i))
    axis([hrs(1) hrs(end) 0 1.1])
    grid on
    title(sprintf('Bare lamp %d',i-14))
    xlabel('run hours')
    ylabel('relative light level')
end
set(gcf, 'Position', [0 0 700 900])

% figure
% for i= 8:14
%     subplot(4,2,i-7)
%     plot(time2,norm_level(:,i))
%     axis([hrs(1) hrs(end) 0 1])
%     grid on
%     title(sprintf('Fixture %d',i))
%     xlabel('run hours')
%     ylabel('relative light level')
% end
% set(gcf, 'Position', [0 0 700 900])

% figure
% for i= 24:32
%     subplot(5,2,i-23)
%     plot(time2,norm_level(:,i))
%     axis([hrs(1) hrs(end) 0 1])
%     grid on
%     title(sprintf('Bare lamp %d',i-14))
%     xlabel('run hours')
%     ylabel('relative light level')
% end
% set(gcf, 'Position', [0 0 700 900])
%temperatures
figure
for i= 1:7
    subplot(4,2,i)
    hold all
    for j = 1:length(temperature_indices{i})
        plot(time2,data2(:,temperature_indices{i}(j)+33))
%         axis([0 1000 0.5 1])
        grid on
        title(sprintf('Fixture %d',i))
        xlabel('run hours')
        ylabel('Temperature (F)')
        legend('ballast 1','ballast 2','chamber','Location','SouthWest')
        xlim([0, time2(end)])
    end
end
set(gcf, 'Position', [0 0 700 900])

%
figure
for i= 15:23
    subplot(5,2,i-14)
    hold all
    for j = 1:length(temperature_indices{i})
        plot(time2,data2(:,temperature_indices{i}(j)+33))
        %         axis([0 1000 0.5 1])
        grid on
        title(sprintf('Bare lamp %d',i-14))
        xlabel('run hours')
        ylabel('Temperature (F)')
        legend('ballast','Location','SouthWest')
        xlim([0, time2(end)])
    end
end
set(gcf, 'Position', [0 0 700 900])

% figure
% for i= 8:14
%     subplot(4,2,i-7)
%     hold all
%     for j = 1:length(temperature_indices{i})
%         plot(time2,data2(:,temperature_indices{i}(j)+33))
% %         axis([0 1000 0.5 1])
%         grid on
%         title(sprintf('Fixture %d',i))
%         xlabel('run hours')
%         ylabel('Temperature (F)')
%         legend('balast 1','balast 2','balast 3','chamber')
%     end
% end
%
% figure
% for i= 24:32
%     subplot(5,2,i-23)
%     hold all
%     for j = 1:length(temperature_indices{i})
%         plot(time2,data2(:,temperature_indices{i}(j)+33))
%         %         axis([0 1000 0.5 1])
%         grid on
%         title(sprintf('Bare lamp %d',i-14))
%         xlabel('run hours')
%         ylabel('Temperature (F)')
%         legend('balast')
%     end
% end


% legend('8','9','10','11','12','13','14')

% figure
% hold all
% for i= [32+12:32+14]
%
% %     norm_level(:,i) = data(:,i)/norm_values(i);
%     plot(time, data(:,i))
% %     hold all
% end


% figure
% list_dummy = 0;
% clear temp_list
% for i= 15:23
%     list_dummy = list_dummy+1;
%     norm_level(:,i) = data(:,i)/norm_values(i);
%     temp_list{1,list_dummy} =time;
%     temp_list{2,list_dummy} =norm_level(:,i);
%     figure
%     plot(time, norm_level(:,i))
% %     hold all
% end
% figure
% Plot_pretty(1,50,temp_list{:})
% % Plot_pretty(1,1,temp_list{:})
% legend('b1','b2','b3','b4','b5','b6','b7','b8','b9')

% figure
% for i= 24:32
%     norm_level(:,i) = data(:,i)/norm_values(i);
%     plot(time, norm_level(:,i))
%     hold all
% end
% legend('b10','b11','b12','b13','b14','b15','b16','b17','b18')
