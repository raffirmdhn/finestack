-- FineStack Clink Completion for cmd/cmder
-- Place this file where Clink can find it (see instructions below)

local finestack_root = "C:\\Users\\Raffi\\Programs\\FineStack"

-- Get PHP versions by scanning apps\php directory
local function get_php_versions()
    local versions = {}
    local php_dir = finestack_root .. "\\apps\\php"
    
    -- Try to open directory and list subdirectories
    local handle = io.popen('dir "' .. php_dir .. '" /b /ad 2>nul')
    if handle then
        for dir in handle:lines() do
            table.insert(versions, dir)
        end
        handle:close()
    end
    
    return versions
end

-- Get database types by scanning apps directory
local function get_db_types()
    local types = {}
    local apps_dir = finestack_root .. "\\apps"
    
    -- Check for mysql, mariadb, postgres
    local db_names = {"mysql", "mariadb", "postgres"}
    for _, db in ipairs(db_names) do
        local db_path = apps_dir .. "\\" .. db
        local handle = io.popen('if exist "' .. db_path .. '" echo ' .. db .. ' 2>nul')
        if handle then
            local result = handle:read("*a")
            handle:close()
            if result and result:match(db) then
                table.insert(types, db)
            end
        end
    end
    
    return types
end

-- Create argmatcher for 'dev' command
clink.argmatcher("dev")
    :addarg({
        "start" .. clink.argmatcher():addarg({"all", "nginx", "php", "mysql"}),
        "stop" .. clink.argmatcher():addarg({"all", "nginx", "php", "mysql"}),
        "restart" .. clink.argmatcher():addarg({"all", "nginx", "php", "mysql"}),
        "status",
        "list" .. clink.argmatcher():addarg({"php", "mysql", "all"}),
        "use" .. clink.argmatcher():addarg({
            "php" .. clink.argmatcher():addarg(get_php_versions),
            "db" .. clink.argmatcher():addarg(get_db_types)
        })
    })
