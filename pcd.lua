alias{
    pcd = function (arg)
        local command
        local path
        if arg[1] then
            command = arg[1]
        end
        if arg[2] then
            path = arg[2]
        end
        if command == "add" then
            pathchanger(path)
        elseif command == "list" then
            pecoli()
        elseif command == "help" then
            print("pcd\n")
            print("   add [path] : 'Add path favorite list.'\n")
            print("     * [path] use can direct directory name or full path :)\n")
            print("   list : 'Call favorite list use peco.'\n")
            print("   help : 'this.'")
        elseif command == nil or "" then
            pcdorigin()
        else
            print("pcd: "..command.." is not a pcd command. Plz See 'pcd help'")
        end
    end
}

-- .pcd_listファイルを探す関数
function pathchanger(path)
    local current = path
    local cpath = cpathAddSlash(slashChanger(nyagos.getwd()))
    if current == nil then
        current = nyagos.getwd()
    end
    current = cpathAddSlash(slashChanger(current))
    if string.match(current, "("..cpath..")") then
        existsDirectory(current)
    else
        current = cpath..current
        existsDirectory(current)
    end
end

-- ディレクトリの存在チェック
function existsDirectory(current)
    local f = io.open(current.."/.test", "w+")
    if f then
        io.output(f):write("test")
        addfolder(current)
        io.close(f)
        os.remove(current.."/.test")
    else
        print("'"..current.."' no such directory. ")
    end
end

-- .pcd_listファイルがなければ生成し、リストに追加する関数
function addfolder(current)
    local home = nyagos.getenv('USERPROFILE')
    local f = io.open(home.."/.pcd_list", "r+")
    if f then -- ファイルの存在チェック
        if string.find(f:read("*a"), current.."\n") then -- 既にお気に入りに登録されているか調べる
            print("'"..current.."' is already exists in '"..home.."\\.pcd_list' .")
        else
            io.output(f):write(current.."\n")
            print("'"..current.."' add '"..home.."\\'.pcd_list' .")
        end
        io.close(f)
    else
        f = io.open(home.."/.pcd_list", "w+")
        if io.output(f):write(current.."\n") then
            print("Success! pcd create '"..home.."\\.pcd_list' .")
            print("'"..current.."' add '"..home.."'\\.pcd_list' .")
        else
            print("Fail! pcd cant create '.pcd_list' file")
        end
        io.close(f)
    end
end

-- favlistでpecoる関数
function pecoli()
    set "PCD_CONFIG=%USERPROFILE%\\.pcd_list"
    local dir = nyagos.eval('type "%PCD_CONFIG%" | peco')
    if (dir ~= nil) then
        nyagos.exec("cd " .. '"' .. chomp(dir) .. '"')
    end
end

-- \→/に変換する
function slashChanger(str)
    return string.gsub(str, "\\", "/")
end

-- 末尾にスラッシュがあるか調べる
function cpathAddSlash(str)
    if string.find(str, "/", "-1") == nil then
        str = str.."/"
    end
    return str
end

-- code from 'https://gist.github.com/nocd5/1add5bd3e0c6e73f9d0d'
function pcdorigin ()
    local line = nyagos.eval("ls -la") -- nyagos組み込みの`ls`
    local complst = split(line, "[\r\n]")
    local directories = ""
    for i, e in ipairs(complst) do
        -- 末尾が'/'ならディレクトリって事で決め打ち
        if (e:match('.+/$')) then
            -- ls -lの結果が
            -- <パーミション> <サイズ> <日付> <時間> <ファイル名 or ディレクトリ名>
            -- と出力されるので、スペースで区切られた5つ目の要素を取得
            directories = directories .. '\n' .. e:gsub(".-%s+", "", 4)
        end
    end
    if (directories == "") then
        -- print ("Could not find any directory.")
        nyagos.exec("ls -oa")
    else
        local dir = nyagos.eval("echo " .. directories ..  " | peco")
        if (dir ~= nil) then
            nyagos.exec("cd " .. '"' .. chomp(dir) .. '"')
        end
    end
end


-- code from 'http://lua-users.org/wiki/SplitJoin'
function split(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t,cap)
        end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end

function chomp(src)
    return string.gsub(src, "[\r\n]+$", "")
end