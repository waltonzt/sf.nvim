vim.filetype = on
vim.filetype.add({
    extension = {
        cls = 'apex',
        apex = 'apex',
        trigger = 'apex',
        soql = 'soql',
        sosl = 'sosl',
        page = 'html',
    }
})

-- autocmds
local sf_group = vim.api.nvim_create_augroup("Sf", { clear = true })

vim.api.nvim_create_autocmd({ 'FileType' }, {
    group = sf_group,
    pattern = 'apex',
    callback = function()
        vim.bo.commentstring = '//%s'
        vim.bo.fixendofline = false -- Salesforce doesn't like end of line
    end
})

vim.api.nvim_create_autocmd({ 'VimEnter' }, {
    group = sf_group,
    desc = "Run sf org cmd and store org info in the plugin",
    once = true,
    callback = function()
        require('sf.org').fetch_org_list()
    end,
})

local function set_keys()
    if not vim.tbl_contains({ "apex", "sosl", "soql", "javascript", "html" }, vim.bo.filetype) then
        return
    end

    if not pcall(require('sf.util').get_sf_root) then
        return vim.notify_once('File not in sf project folder, sf.nvim hotkeys not loaded.',
            vim.log.levels.WARN)
    end

    -- Set hotkeys

    local nmap = function(keys, func, desc)
        if desc then
            desc = '[Sf] ' .. desc
        end
        vim.keymap.set('n', keys, func, { buffer = true, desc = desc })
    end

    nmap('<leader>ss', require("sf.org").set_target_org, "[s]et target_org current workspace")
    nmap('<leader>sS', require("sf.org").set_global_target_org, "[S]et global target_org")

    nmap('<leader>sf', require("sf.org").fetch_org_list, "[F]etch orgs info")

    nmap('<leader>sd', require("sf.org").diff_in_target_org, "[d]iff in target_org")
    nmap('<leader>sD', require("sf.org").diff_in_org, "[D]iff in org...")

    -- nmap('<leader>mr', require("sf.md").pull_md_json, "[M]etadata json [R]etrieve")
    nmap('<leader>ml', require("sf.md").list_md_to_retrieve, "[M]etadata [L]isting")
    nmap('<leader>mL', require("sf.md").pull_and_list_md, "Force pull and list metadata")

    -- nmap('<leader>mtr', require("sf.md").pull_md_type_json, "[M]etadata-[T]ype json [R]etrieve")
    nmap('<leader>mtl', require("sf.md").list_md_type_to_retrieve, "[M]etadata-[T]ype [L]isting")
    nmap('<leader>mtL', require("sf.md").pull_and_list_md_type, "Force pull and list metadata types")

    nmap('<leader>ma', require("sf.md").retrieve_apex_under_cursor, "[A]pex under cursor retrieve")

    nmap('<leader><leader>', require("sf.term").toggle, "[T]erminal toggle")

    nmap('<leader>s-', require("sf.term").go_to_sf_root, "CD into [R]oot")
    nmap('<C-c>', require("sf.term").cancel, "[C]ancel current running command")

    nmap('<leader>sp', require("sf.term").save_and_push, "[P]ush current file")
    nmap('<leader>sr', require("sf.term").retrieve, "[R]etrieve current file")

    nmap('<leader>ta', require("sf.test").run_all_tests_in_this_file, "[T]est [A]ll")
    nmap('<leader>tt', require("sf.test").run_current_test, "[T]est [T]his under cursor")

    nmap('<leader>to', require("sf.test").open, "[T]est [O]pen Buf Select")
    nmap('<leader>tr', require("sf.test").repeat_last_tests, "[T]est [R]epeat")

    vim.keymap.set('n', '<leader>cc', require("sf").copy_apex_name, { desc = '[c]opy apex name' })

    -- user commands
    local org = require('sf.org')
    local term = require('sf.term')
    local md = require('sf.md')
    local test = require('sf.test')

    -- From SFOrg

    vim.api.nvim_create_user_command("SfFetchOrgList", function()
        org.fetch_org_list()
    end, {})

    vim.api.nvim_create_user_command("SfSetTargetOrg", function()
        org.set_target_org()
    end, {})

    vim.api.nvim_create_user_command("SfDiff", function()
        org.diff_in_target_org()
    end, {})

    vim.api.nvim_create_user_command("SfDiffInOrg", function()
        org.diff_in_org()
    end, {})

    -- From SFMd

    -- vim.api.nvim_create_user_command("SfPullMdJson", function()
    --     md.pull_md_json()
    -- end, {})

    vim.api.nvim_create_user_command("SfListMdToRetrieve", function()
        md.list_md_to_retrieve()
    end, {})

    vim.api.nvim_create_user_command("SfPullAndListMd", function()
        md.pull_and_list_md()
    end, {})

    -- vim.api.nvim_create_user_command("SfPullMdTypeJson", function()
    --     md.pull_md_type_json()
    -- end, {})

    vim.api.nvim_create_user_command("SfListMdTypeToRetrieve", function()
        md.list_md_type_to_retrieve()
    end, {})

    vim.api.nvim_create_user_command("SfPullAndListMdType", function()
        md.pull_and_list_md_type()
    end, {})

    -- From SFTerm

    vim.api.nvim_create_user_command("SfToggle", function()
        term.toggle()
    end, {})

    vim.api.nvim_create_user_command("SfSaveAndPush", function()
        term.save_and_push()
    end, {})

    vim.api.nvim_create_user_command("SfRetrieve", function()
        term.retrieve()
    end, {})

    vim.api.nvim_create_user_command("SfCancelCommand", function()
        term.cancel()
    end, {})

    -- From SFTest

    vim.api.nvim_create_user_command("SfRunAllTestsInThisFile", function()
        test.run_all_tests_in_this_file()
    end, {})

    vim.api.nvim_create_user_command("SfRunCurrentTest", function()
        test.run_current_test()
    end, {})

    vim.api.nvim_create_user_command("SfRepeatTest", function()
        test.repeat_last_tests()
    end, {})

    vim.api.nvim_create_user_command("SfOpenTestSelect", function()
        test.open()
    end, {})
end

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'FileType' }, {
    group = sf_group,
    callback = set_keys
})
