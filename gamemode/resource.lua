local path = GM.FolderName
files, dir = file.Find(path.."/content/icons/*","LUA")
for k,v in pairs(files) do
	resource.AddFile("icons/"..v)
end

files, dir = file.Find(path.."/content/perks/*","LUA") 
for k,v in pairs(files) do 
	resource.AddFile("perks/"..v) 
end 
  
files, dir = file.Find("resources/fonts/*", "LUA")  
for k,v in pairs(files) do
	resource.AddFile("fonts/"..v) 
end  

resource.AddWorkshop("110286060")
resource.AddWorkshop("594591746")
resource.AddWorkshop("315810701")  
resource.AddWorkshop("579630935") 
resource.AddWorkshop("349050451")
resource.AddWorkshop("409949459")