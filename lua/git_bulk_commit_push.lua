local lfs = require("lfs")

local function display_help()
    print([[
Usage: lua git_bulk_commit_push.lua [options]

Options:
  -d, --directory   Directory to perform git operations (required)
  -m, --message     Commit message (required)
  -b, --branch      Branch name to push to (required)
  -h, --help        Display this help menu

Example:
  lua git_bulk_commit_push.lua -d /path/to/directory -m "Your commit message" -b branch_name
]])
end

local function prompt_user(prompt)
    io.write(prompt .. ": ")
    return io.read()
end

local function log_error(message)
    local log_file = io.open("git_push_errors.log", "a")
    log_file:write(message .. "\n")
    log_file:close()
end

local args = { ... }
local directory, message, branch

for i = 1, #args do
    if args[i] == "-d" or args[i] == "--directory" then
        directory = args[i + 1]
    elseif args[i] == "-m" or args[i] == "--message" then
        message = args[i + 1]
    elseif args[i] == "-b" or args[i] == "--branch" then
        branch = args[i + 1]
    elseif args[i] == "-h" or args[i] == "--help" then
        display_help()
        os.exit()
    end
end

if not directory then
    directory = prompt_user("Enter directory")
end
if not message then
    message = prompt_user("Enter commit message")
end
if not branch then
    branch = prompt_user("Enter branch name")
end

local success, err = lfs.chdir(directory)
if not success then
    print("Error changing directory: " .. err)
    os.exit(1)
end

os.execute("git add .")
os.execute('git commit -m "' .. message .. '"')
local push_result = os.execute("git push origin " .. branch)

-- Log failed push attempts
if push_result ~= 0 then
    log_error("Failed to push to branch " .. branch .. " in directory " .. directory)
end
