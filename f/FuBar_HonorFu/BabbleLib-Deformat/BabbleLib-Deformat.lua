local MAJOR_VERSION = "Deformat 1.2"
local MINOR_VERSION = tonumber(string.sub("$Revision: 3860 $", 12, -3))

if BabbleLib and BabbleLib.versions[MAJOR_VERSION] and BabbleLib.versions[MAJOR_VERSION].minor >= MINOR_VERSION then
	return
end

local locale = GetLocale and GetLocale() or "enUS"
if locale ~= "frFR" and locale ~= "deDE" and locale ~= "zhCN" and locale ~= "koKR" then
	locale = "enUS"
end

-------------IRIEL'S-STUB-CODE--------------
local stub = {};

-- Instance replacement method, replace contents of old with that of new
function stub:ReplaceInstance(old, new)
   for k,v in pairs(old) do old[k]=nil; end
   for k,v in pairs(new) do old[k]=v; end
end

-- Get a new copy of the stub
function stub:NewStub()
  local newStub = {};
  self:ReplaceInstance(newStub, self);
  newStub.lastVersion = '';
  newStub.versions = {};
  return newStub;
end

-- Get instance version
function stub:GetInstance(version)
   if (not version) then version = self.lastVersion; end
   local versionData = self.versions[version];
   if (not versionData) then
      message("Cannot find library instance with version '" 
              .. version .. "'");
      return;
   end
   return versionData.instance;
end

-- Register new instance
function stub:Register(newInstance)
   local version,minor = newInstance:GetLibraryVersion();
   self.lastVersion = version;
   local versionData = self.versions[version];
   if (not versionData) then
      -- This one is new!
      versionData = { instance = newInstance,
         minor = minor,
         old = {} 
      };
      self.versions[version] = versionData;
      newInstance:LibActivate(self);
      return newInstance;
   end
   if (minor <= versionData.minor) then
      -- This one is already obsolete
      if (newInstance.LibDiscard) then
         newInstance:LibDiscard();
      end
      return versionData.instance;
   end
   -- This is an update
   local oldInstance = versionData.instance;
   local oldList = versionData.old;
   versionData.instance = newInstance;
   versionData.minor = minor;
   local skipCopy = newInstance:LibActivate(self, oldInstance, oldList);
   table.insert(oldList, oldInstance);
   if (not skipCopy) then
      for i, old in ipairs(oldList) do
         self:ReplaceInstance(old, newInstance);
      end
   end
   return newInstance;
end

-- Bind stub to global scope if it's not already there
if (not BabbleLib) then
   BabbleLib = stub:NewStub();
end

-- Nil stub for garbage collection
stub = nil;
-----------END-IRIEL'S-STUB-CODE------------

local function assert(condition, message)
	if not condition then
		local stack = debugstack()
		local first = string.gsub(stack, "\n.*", "")
		local file = string.gsub(first, "^(.*\\.*).lua:%d+: .*", "%1")
		file = string.gsub(file, "([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1")
		if not message then
			local _,_,second = string.find(stack, "\n(.-)\n")
			message = "assertion failed! " .. second
		end
		message = "BabbleLib-Deformat: " .. message
		local i = 1
		for s in string.gfind(stack, "\n([^\n]*)") do
			i = i + 1
			if not string.find(s, file .. "%.lua:%d+:") then
				error(message, i)
				return
			end
		end
		error(message, 2)
		return
	end
	return condition
end

local function argCheck(arg, num, kind, kind2, kind3, kind4)
	if tostring(type(arg)) ~= kind then
		if kind2 then
			if tostring(type(arg)) ~= kind2 then
				if kind3 then
					if tostring(type(arg)) ~= kind3 then
						if kind4 then
							if tostring(type(arg)) ~= kind4 then
								local _,_,func = string.find(debugstack(), "\n.-`(.-)'\n")
								assert(false, format("Bad argument #%d to `%s' (%s, %s, %s, or %s expected, got %s)", num, func, kind, kind2, kind3, kind4, type(arg)))
							end
						else
							local _,_,func = string.find(debugstack(), "\n.-`(.-)'\n")
							assert(false, format("Bad argument #%d to `%s' (%s, %s, or %s expected, got %s)", num, func, kind, kind2, kind3, type(arg)))
						end
					end
				else
					local _,_,func = string.find(debugstack(), "\n.-`(.-)'\n")
					assert(false, format("Bad argument #%d to `%s' (%s or %s expected, got %s)", num, func, kind, kind2, type(arg)))
				end
			end
		else
			local _,_,func = string.find(debugstack(), "\n.-`(.-)'\n")
			assert(false, format("Bad argument #%d to `%s' (%s expected, got %s)", num, func, kind, type(arg)))
		end
	end
end

local lib = {}

do
	local sequences = {
		["%d*d"] = "%%d+",
		["s"] = ".+",
		["[fg]"] = "%%d+%%.%%d+",
		["%.%d[fg]"] = "%%d+%%.%%d+",
		["c"] = ".",
	}
	local curries = {}
	
	local function doNothing(item)
		return item
	end
	local v = {}
	
	local function concat(a1, a2, a3, a4)
		local left, right
		if not a2 then
			return a1
		elseif not a3 then
			left, right = a1, a2
		elseif not a4 then
			return concat(concat(a1, a2), a3)
		else
			return concat(concat(concat(a1, a2), a3), a4)
		end
		if not string.find(left, "%%1%$") and not string.find(right, "%%1%$") then
			return left .. right
		elseif not string.find(right, "%%1%$") then
			local i
			for j = 9, 1, -1 do
				if string.find(left, "%%" .. j .. "%$") then
					i = j
					break
				end
			end
			while true do
				local first
				local firstPat
				for x, y in pairs(sequences) do
					local i = string.find(right, "%%" .. x)
					if not first or (i and i < first) then
						first = i
						firstPat = x
					end
				end
				if not first then
					break
				end
				i = i + 1
				right = string.gsub(right, "%%(" .. firstPat .. ")", "%%" .. i .. "$%1")
			end
			return left .. right
		elseif not string.find(left, "%%1%$") then
			local i = 1
			while true do
				local first
				local firstPat
				for x, y in pairs(sequences) do
					local i = string.find(left, "%%" .. x)
					if not first or (i and i < first) then
						first = i
						firstPat = x
					end
				end
				if not first then
					break
				end
				i = i + 1
				left = string.gsub(left, "%%(" .. firstPat .. ")", "%%" .. i .. "$%1")
			end
			return concat(left, right)
		else
			local i
			for j = 9, 1, -1 do
				if string.find(left, "%%" .. j .. "%$") then
					i = j
					break
				end
			end
			local j
			for k = 9, 1, -1 do
				if string.find(right, "%%" .. k .. "%$") then
					j = k
					break
				end
			end
			for k = j, 1, -1 do
				right = string.gsub(right, "%%" .. k .. "%$", "%%" .. k + i .. "%$")
			end
			return left .. right
		end
	end
	
	local function Curry(a1, a2, a3, a4)
		local pattern = concat(a1, a2, a3, a4)
		if not string.find(pattern, "%%1%$") then
			local unpattern = string.gsub(pattern, "([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1")
			local f = {}
			local i = 0
			while true do
				local first
				local firstPat
				for x, y in pairs(sequences) do
					local i = string.find(unpattern, "%%%%" .. x)
					if not first or (i and i < first) then
						first = i
						firstPat = x
					end
				end
				if not first then
					break
				end
				unpattern = string.gsub(unpattern, "%%%%" .. firstPat, "(" .. sequences[firstPat] .. ")", 1)
				i = i + 1
				if firstPat == "c" or firstPat == "s" then
					table.insert(f, doNothing)
				else
					table.insert(f, tonumber)
				end
			end
			unpattern = "^" .. unpattern .. "$"
			local _,alpha, bravo, charlie, delta, echo, foxtrot, golf, hotel, india
			if i == 0 then
				return
			elseif i == 1 then
				return function(text)
					_,_,alpha = string.find(text, unpattern)
					if alpha then
						return f[1](alpha)
					end
				end
			elseif i == 2 then
				return function(text)
					_,_,alpha, bravo = string.find(text, unpattern)
					if alpha then
						return f[1](alpha), f[2](bravo)
					end
				end
			elseif i == 3 then
				return function(text)
					_,_,alpha, bravo, charlie = string.find(text, unpattern)
					if alpha then
						return f[1](alpha), f[2](bravo), f[3](charlie)
					end
				end
			elseif i == 4 then
				return function(text)
					_,_,alpha, bravo, charlie, delta = string.find(text, unpattern)
					if alpha then
						return f[1](alpha), f[2](bravo), f[3](charlie), f[4](delta)
					end
				end
			elseif i == 5 then
				return function(text)
					_,_,alpha, bravo, charlie, delta, echo = string.find(text, unpattern)
					if alpha then
						return f[1](alpha), f[2](bravo), f[3](charlie), f[4](delta), f[5](echo)
					end
				end
			elseif i == 6 then
				return function(text)
					_,_,alpha, bravo, charlie, delta, echo, foxtrot = string.find(text, unpattern)
					if alpha then
						return f[1](alpha), f[2](bravo), f[3](charlie), f[4](delta), f[5](echo), f[6](foxtrot)
					end
				end
			elseif i == 7 then
				return function(text)
					_,_,alpha, bravo, charlie, delta, echo, foxtrot, golf = string.find(text, unpattern)
					if alpha then
						return f[1](alpha), f[2](bravo), f[3](charlie), f[4](delta), f[5](echo), f[6](foxtrot), f[7](golf)
					end
				end
			elseif i == 8 then
				return function(text)
					_,_,alpha, bravo, charlie, delta, echo, foxtrot, golf, hotel = string.find(text, unpattern)
					if alpha then
						return f[1](alpha), f[2](bravo), f[3](charlie), f[4](delta), f[5](echo), f[6](foxtrot), f[7](golf), f[8](hotel)
					end
				end
			else
				return function(text)
					_,_,alpha, bravo, charlie, delta, echo, foxtrot, golf, hotel, india = string.find(text, unpattern)
					if alpha then
						return f[1](alpha), f[2](bravo), f[3](charlie), f[4](delta), f[5](echo), f[6](foxtrot), f[7](golf), f[8](hotel), f[9](india)
					end
				end
			end
		else
			local o = {}
			local f = {}
			local unpattern = string.gsub(pattern, "([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1")
			local i = 1
			while true do
				local pat
				for x, y in pairs(sequences) do
					if not pat and string.find(unpattern, "%%%%" .. i .. "%%%$" .. x) then
						pat = x
						break
					end
				end
				if not pat then
					break
				end
				unpattern = string.gsub(unpattern, "%%%%" .. i .. "%%%$" .. pat, "(" .. sequences[pat] .. ")", 1)
				if pat == "c" or pat  == "s" then
					table.insert(f, doNothing)
				else
					table.insert(f, tonumber)
				end
				i = i + 1
			end
			i = 1
			string.gsub(pattern, "%%(%d)%$", function(w) o[i] = tonumber(w); i = i + 1; end)
			v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9] = nil
			for x, y in pairs(f) do
				v[x] = f[y]
			end
			for x, y in pairs(v) do
				f[x] = v[x]
			end
			unpattern = "^" .. unpattern .. "$"
			i = i - 1
			if i == 0 then
				return function(text)
					return
				end
			elseif i == 1 then
				return function(text)
					_,_,v[1] = string.find(text, unpattern)
					if v[1] then
						return f[1](v[1])
					end
				end
			elseif i == 2 then
				return function(text)
					_,_,v[1],v[2] = string.find(text, unpattern)
					if v[1] then
						return f[1](v[o[1]]), f[2](v[o[2]])
					end
				end
			elseif i == 3 then
				return function(text)
					_,_,v[1],v[2],v[3] = string.find(text, unpattern)
					if v[1] then
						return f[1](v[o[1]]), f[2](v[o[2]]), f[3](v[o[3]])
					end
				end
			elseif i == 4 then
				return function(text)
					_,_,v[1],v[2],v[3],v[4] = string.find(text, unpattern)
					if v[1] then
						return f[1](v[o[1]]), f[2](v[o[2]]), f[3](v[o[3]]), f[4](v[o[4]])
					end
				end
			elseif i == 5 then
				return function(text)
					_,_,v[1],v[2],v[3],v[4],v[5] = string.find(text, unpattern)
					if v[1] then
						return f[1](v[o[1]]), f[2](v[o[2]]), f[3](v[o[3]]), f[4](v[o[4]]), f[5](v[o[5]])
					end
				end
			elseif i == 6 then
				return function(text)
					_,_,v[1],v[2],v[3],v[4],v[5],v[6] = string.find(text, unpattern)
					if v[1] then
						return f[1](v[o[1]]), f[2](v[o[2]]), f[3](v[o[3]]), f[4](v[o[4]]), f[5](v[o[5]]), f[6](v[o[6]])
					end
				end
			elseif i == 7 then
				return function(text)
					_,_,v[1],v[2],v[3],v[4],v[5],v[6],v[7] = string.find(text, unpattern)
					if v[1] then
						return f[1](v[o[1]]), f[2](v[o[2]]), f[3](v[o[3]]), f[4](v[o[4]]), f[5](v[o[5]]), f[6](v[o[6]]), f[7](v[o[7]])
					end
				end
			elseif i == 8 then
				return function(text)
					_,_,v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8] = string.find(text, unpattern)
					if v[1] then
						return f[1](v[o[1]]), f[2](v[o[2]]), f[3](v[o[3]]), f[4](v[o[4]]), f[5](v[o[5]]), f[6](v[o[6]]), f[7](v[o[7]]), f[8](v[o[8]])
					end
				end
			else
				return function(text)
					_,_,v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9] = string.find(text, unpattern)
					if v[1] then
						return f[1](v[o[1]]), f[2](v[o[2]]), f[3](v[o[3]]), f[4](v[o[4]]), f[5](v[o[5]]), f[6](v[o[6]]), f[7](v[o[7]]), f[8](v[o[8]]), f[9](v[o[9]])
					end
				end
			end
		end
	end
	
	function lib:Deformat(text, a1, a2, a3, a4)
		argCheck(text, 2, "string")
		argCheck(a1, 3, "string")
		local pattern = a1
		if a4 then
			pattern = string.format("%s%s%s%s", a1, a2, a3, a4)
		elseif a3 then
			pattern = string.format("%s%s%s", a1, a2, a3)
		elseif a2 then
			pattern = a1 .. a2
		end
		if curries[pattern] == nil then
			curries[pattern] = Curry(a1, a2, a3, a4)
		end
		return curries[pattern](text)
	end
end

function lib:GetLibraryVersion()
	return MAJOR_VERSION, MINOR_VERSION
end

function lib:LibActivate(stub, oldLib, oldList)
	local mt = getmetatable(self) or {}
	mt.__call = self.Deformat
	setmetatable(self, mt)
end

function lib:LibDeactivate()
end

BabbleLib:Register(lib)
lib = nil
