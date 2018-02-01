file = id;
spikes = [11,13,31];
clasif = {{'contacto,i'; 'rotacion,e'}};

for s = 1:length(spikes)
    spkid = ['spike', num2str(spikes(s))];
    dewey.(file) = struct(spkid, clasif{1});
end

