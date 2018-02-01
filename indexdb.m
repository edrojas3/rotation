function [selected, data] = indexdb(id, spikeid)

db = 'eduardo\Documents\proyectos\rotacion\dbDewey.mat';
load(db)


%% 
index = zeros(size(dbDewey,1),1);
for i = 1:size(dbDewey,1)
   if strcmp(dbDewey{i,1},id) && strcmp(dbDewey{i,2},spikeid);
       index(i,1) = 1;
   end
       
end

selected = find(index == 1);
data = dbDewey(selected,:);