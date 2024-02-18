--- *SFMd* The module dealing with metadata
--- *Sf md*
---
--- Features:
---
--- - Retrieve metadata from target_org
--- - Retrieve metadata-type from target_org

local S = require('sf');
local T = require('sf.term')
local U = require('sf.util');

local H = {}
H.types_to_retrieve = {
  "ApexClass",
  "ApexTrigger",
  "StaticResource",
  "LightningComponentBundle"
}

local Md = {}

--- Choose a specific metadata file to retrieve.
--- Its popup list depends on data retrieved by |retrieve_metadata_lists| in prior.
function Md.select_md_to_retrieve()
  H.select_md_to_retrieve()
end

--- Download metadata name list(without file content), e.g. Apex names, LWC names, StaticResource names, etc. as Json files into the the project root path "md" folder.
function Md.pull_metadata_lists()
  H.pull_metadata_lists()
end

--- Use the word under the cursor and attempt to retrieve as a Apex name from target_org.
function Md.retrieve_apex_under_cursor()
  H.retrieve_apex_under_cursor()
end

--- Download metadata-type list, e.g. ApexClass, LWC, Aura, FlexiPage, etc. as a Json file into the project root path "md" folder.
function Md.pull_metadata_type_list()
  H.pull_metadata_type_list()
end

--- Select a specific metadata-type to download all files. For example, download all ApexClass files.
--- Its popup list depends on data retrieved by |pull_metadata_type_list| in prior.
function Md.select_md_type_to_retrieve()
  H.select_md_type_to_retrieve()
end

-- Helper --------------------

H.select_md_to_retrieve = function()
  U.is_empty(S.target_org)

  local md_to_display = {}
  local md_folder = U.get_sf_root() .. '/md'

  for _, type in pairs(H.types_to_retrieve) do
    local md_file = string.format('%s/%s_%s.json', md_folder, type, S.target_org)

    if vim.fn.filereadable(md_file) == 0 then
      vim.notify('%s not exist! Pulling now...' .. md_file, vim.log.levels.WARN)
      H.pull_metadata(type)
    else
      local metadata = vim.fn.readfile(md_file)
      local md_tbl = vim.json.decode(table.concat(metadata), {})

      for _, v in ipairs(md_tbl) do
        if v["manageableState"] == 'unmanaged' then
          table.insert(md_to_display, v)
        end
      end
    end
  end

  U.is_table_empty(md_to_display)

  H.tele_metadata(md_to_display, {})
end

H.tele_metadata = function(source, opts)
  opts = opts or {}
  pickers.new({}, {
    prompt_title = 'Org: ' .. S.target_org,

    finder = finders.new_table {
      results = source,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry["fullName"] .. ' | ' .. entry["type"],
          ordinal = entry["fullName"] .. ' | ' .. entry["type"],
        }
      end
    },

    sorter = conf.generic_sorter(opts),

    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local md = action_state.get_selected_entry().value

        H.retrieve_md(md["type"], md["fullName"])
      end)
      return true
    end,
  }):find()
end

H.retrieve_apex_under_cursor = function()
  local current_word = vim.fn.expand('<cword>')
  print(current_word)
  H.retrieve_md('ApexClass', current_word)
end

H.retrieve_md = function(type, name)
  U.is_empty(S.target_org)
  U.get_sf_root()

  local cmd = string.format('sf project retrieve start -m %s:%s -o %s', type, name, S.target_org)
  T.run(cmd)
end

H.pull_metadata_lists = function()
  for _, type in pairs(H.types_to_retrieve) do
    H.pull_metadata(type)
  end
end

H.pull_metadata = function(type)
  U.is_empty(S.target_org)

  local md_folder = U.get_sf_root() .. '/md'
  if vim.fn.isdirectory(md_folder) == 0 then
    local result = vim.fn.mkdir(md_folder)
    if result == 0 then
      return vim.notify('md folder creation failed!', vim.log.levels.ERROR)
    end
  end

  local md_file = string.format('%s/%s_%s.json', md_folder, type, S.target_org)

  local cmd = string.format('sf org list metadata -m %s -o %s -f %s', type, S.target_org, md_file)
  local msg = string.format('%s retrieved', type)
  local err_msg = string.format('%s retrieve failed: %s', type, md_file)

  U.job_call(cmd, msg, err_msg);
end

H.pull_metadata_type_list = function()
  U.is_empty(S.target_org)

  local md_folder = U.get_sf_root() .. '/md'
  local metadata_types_file = string.format('%s/%s.json', md_folder, 'metadata-types')

  if vim.fn.isdirectory(md_folder) == 0 then
    local result = vim.fn.mkdir(md_folder)
    if result == 0 then
      return vim.notify('md folder creation failed!', vim.log.levels.ERROR)
    end
  end

  local cmd = string.format('sf org list metadata-types -o %s -f %s', S.target_org, metadata_types_file)
  local msg = 'Metadata-type file retrieved'
  local err_msg = string.format('Metadata-type retrieve failed: %s', metadata_types_file)

  U.job_call(cmd, msg, err_msg);
end

H.select_md_type_to_retrieve = function()
  U.is_empty(S.target_org)

  local md_folder = U.get_sf_root() .. '/md'
  local metadata_types_file = string.format('%s/%s.json', md_folder, 'metadata-types')

  if vim.fn.filereadable(metadata_types_file) == 0 then
    return vim.notify('Metadata-type file not exist! Failed to pull?', vim.log.levels.WARN)
  end

  local file_content = vim.fn.readfile(metadata_types_file)
  local tbl = vim.json.decode(table.concat(file_content), {})
  local md_types = tbl["metadataObjects"]

  H.tele_metadata_type(md_types, {})
end

H.tele_metadata_type = function(source, opts)
  opts = opts or {}
  pickers.new({}, {
    prompt_title = 'metadata-type: ' .. S.target_org,

    finder = finders.new_table {
      results = source,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry["xmlName"],
          ordinal = entry["xmlName"],
        }
      end
    },

    sorter = conf.generic_sorter(opts),

    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local md_type = action_state.get_selected_entry().value

        H.retrieve_md_type(md_type["xmlName"])
      end)
      return true
    end,
  }):find()
end

H.retrieve_md_type = function(type)
  U.is_empty(S.target_org)
  U.get_sf_root()

  local cmd = string.format('sf project retrieve start -m \'%s:*\' -o %s', type, S.target_org)
  T.run(cmd)
end

return Md