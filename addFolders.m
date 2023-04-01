function addFolders(folderList, addSubs)

currFolder = pwd;
switch nargin
case 0
    folderList = {'utiltis\', 'funcutil\', 'buildtools\'};
    addSubs = 1;
case 1
    assert(iscell(folderList) || ischar(folderList));
    if ischar(folderList); folderList = cell({folderList}); end
    addSubs = 1;
case 2
    % Do nothing
end
        
function addNextLevelFolders(folder, addSelf)
if nargin<2 || addSelf
    addpath(folder);
end
flist = dir(folder); flist = flist(3:end);
for i = 1:length(flist)
    subFolder = flist(i);
    if (subFolder.isdir==0) || isequal(subFolder.name, '.') || isequal(subFolder.name, '..')
        continue
    end
    addpath(fullfile(folder, subFolder.name));
end
end

for folder=folderList
thisFolder = fullfile(currFolder, folder{:});
if addSubs
addNextLevelFolders(thisFolder);
else
addpath(thisFolder);    
end
end
end