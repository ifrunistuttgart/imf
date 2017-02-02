warning off all

tests = [];
tests{end+1} = 'inertia.m';
tests{end+1} = 'nameclash.m';
tests{end+1} = 'pendulum.m';
tests{end+1} = 'rotation.m';
tests{end+1} = 'spheric.m';
tests{end+1} = 'transformation_formulation.m';
tests{end+1} = 'two_mass_pendulum.m';

for i=1:length(tests)
    try
        disp(['Running ' tests{i} '...']);
        run(tests{i})
    catch 
        error(['Test ' tests{i} ' failed. Aborting.']);
    end
end

disp('Finished running all tests.');

warning on all