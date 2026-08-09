-- imports
import("core.base.option")

-- the options
local options =
{
    {'v', "verbose",   "k",  nil, "Enable verbose information."   }
,   {'D', "diagnosis", "k",  nil, "Enable diagnosis information." }
,   {nil, "addon",     "k",  nil, "Test the addon packages."      }
,   {nil, "addons",    "vs", nil, "The addon list."               }
}

-- get the modified addons from the git diff, e.g. addons/e/esp32-devel/xmake.lua
function get_modified_addons()
    local addons = {}
    local diff = try {function () return os.iorun("git --no-pager diff --name-only HEAD^") end}
    for _, file in ipairs(diff and diff:split("\n") or {}) do
        file = file:trim()
        if file:startswith("addons") then
            local addonname = path.filename(path.directory(file))
            if addonname and not table.contains(addons, addonname) then
                table.insert(addons, addonname)
            end
        end
    end
    return addons
end

-- test the given addon
--
-- it installs the addon from the local repository, the `on_test` script of the addon
-- will be run after installing it, and then we remove it again
--
function _test_addon(argv, addonname)
    print("testing addon(%s) ..", addonname)

    -- remove it first, we need to install and test it again
    try {function () os.execv(os.programfile(), {"addon", "--remove", "--force", addonname}) end}

    -- install it, `xrepo install --addon` will run the `on_test` script of the addon
    local install_argv = {"lua", "private.xrepo", "install", "--addon", "-y", "--force"}
    if argv.verbose then
        table.insert(install_argv, "-v")
    end
    if argv.diagnosis then
        table.insert(install_argv, "-D")
    end
    table.insert(install_argv, addonname)
    os.vexecv(os.programfile(), install_argv)

    -- and remove it, we should not pollute the environment
    os.vexecv(os.programfile(), {"addon", "--remove", "--force", addonname})
    print("testing addon(%s) ok!", addonname)
end

-- the main entry
function main(...)

    -- parse arguments
    local argv = option.parse({...}, options, "Test all the given or changed addons.")

    -- get addons
    local addons = argv.addons or {}
    if #addons == 0 then
        addons = get_modified_addons()
    end
    if #addons == 0 then
        print("no testable addons!")
        return
    end
    print(addons)

    -- add the local repository, we need to test the addons of the current working copy
    os.setenv("XMAKE_STATS", "false")
    os.execv(os.programfile(), {"repo", "--add", "local-repo", os.curdir()})

    -- test addons
    for _, addonname in ipairs(addons) do
        _test_addon(argv, addonname)
    end
end

return main
