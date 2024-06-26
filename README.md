![Image](https://github.com/xixiaofinland/sf.nvim/assets/13655323/454d4a3d-d455-43f6-b44b-506862106b66)
<p align="center">

<img src="https://img.shields.io/badge/Neovim-57A143?logo=neovim&logoColor=fff&style=for-the-badge" alt="Neovim" />

<img src="https://img.shields.io/badge/Made%20With%20Lua-2C2D72?logo=lua&logoColor=fff&style=for-the-badge" alt="made with lua" >

</p>

<h1 align="center">Sf.nvim</h1>
<p align="center">📸 Offer common functionalities for Salesforce development</p>

## ✨ Features

- 🔥 Push, retrieve, and create metadata files
- 💻 Integrated scratch terminal for on-the-fly commands
- 😎 Diff files between local and org environments
- 🤩 Display target org in the status line
- 👏 Access to a pre-downloaded list of metadata files
- 🤖 Facilitate quick Apex test runs

<br>

## 🎦 Video Intro (6 mins)

[![Feature Intro (6 min)](https://img.youtube.com/vi/MdqPgHIb1pw/0.jpg)](https://www.youtube.com/watch?v=MdqPgHIb1pw)

<br>

## 📝 Prerequisites

- 🌐 [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli)
- 📦 Nvim-treesitter with the Apex parser installed (ensure_installed = { "apex", "soql", "sosl" }), e.g., [in my settings](https://github.com/xixiaofinland/dotfiles/blob/main/.config/nvim/lua/plugins/nvim-tree-sitter.lua)
- 🔍 (Optional) fzf-lua plugin for executing `SFListMdToRetrieve()` and `SFListMdTypeToRetrieve()`


<br>


## ⚙️  Installation

Install using Lazy.nvim by adding the following configuration to your setup:

```lua
return {
  'xixiaofinland/sf.nvim',
  branch = 'dev',

  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'ibhagwan/fzf-lua', -- no need if you don't use listing metadata feature
  },

  config = function()
    require('sf').setup()  -- Important to call setup() to initialize the plugin!
  end
}
```

**Note.** The hotkeys and user commands are **ONLY** enabled in a sf project
folder (i.e. has `.forceignore` or `sfdx-project.json` in the root path).

<br>

## 🛠️ Configuration

Custom configuration can be passed into `setup()` Below are the default
settings:

```lua
require('sf').setup({
  -- Unless you want to customize, no need to copy-paste any of these
  -- They are applied automatically

  -- This plugin has both hotkeys and user commands supplied
  -- This flag enable/disable hotkeys rather than user commands
  enable_hotkeys = true,

  -- Metadata related hotkeys (e.g. push/retrieve Apex) are only enabled in
  -- these filetypes
  hotkeys_in_filetypes = {
    "apex", "sosl", "soql", "javascript", "html"
  },

  -- Define what metadata to be listed in `list_md_to_retrieve()` (<leader>ml)
  types_to_retrieve = {
    "ApexClass",
    "ApexTrigger",
    "StaticResource",
    "LightningComponentBundle"
  },
})
```

<br>


## 🎯 Display target_org

Upon starting Nvim, Sf.nvim executes `SfFetchOrgList` to fetch and save
authenticated org names. Display the target_org in your status line to
facilitate command execution against the target org.

Example configuration using lualine.nvim with target_org(`xixiao100`):

```lua
    sections = {
      lualine_c = { 'filename', {
        "require'sf'.get_target_org()",
      } },
```
![Image 012](https://github.com/xixiaofinland/sf.nvim/assets/13655323/645a6625-aec6-4593-931e-84534ad3ac4c)


<br>

## 🔑 Keys

### Often used

| Default key       | function name           |   User command     | Explain           |
| ----------| ------------------| ----------| ------------------|
| `<leader>ss`     | set_target_org           |SFSetTargetOrg      | set target_org |
| `<leader>sf`     | fetch_org_list              |SFFetchOrgList|fetch/refresh orgs info|
| `<leader><leader>`     |toggle_term|SFToggle|terminal toggle|
| `<leader>sp`     |save_and_push|SFSaveAndPush|push current file|
| `<leader>sr`     |retrieve|SFRetrieve|retrieve current file|
| `<leader>ta`     |run_all_tests_in_this_file|SFRunAllTestsInThisFile|run all Apex tests in current file|
| `<leader>tt`     |run_current_test|SFRunCurrentTest|test this under cursor|
| `<leader>to`     |repeat_last_tests|SFRunCurrentTest|repeat the last test|

Example:

- Press `<leader>s`, `:lua require'sf'.set_target_org()` to activate hotkeys as
  shown in the screenshot below. Remember that they are enabled only inside sf
  folder.
![Image 007](https://github.com/xixiaofinland/sf.nvim/assets/13655323/c0bc474c-3d2f-4fad-9bc0-5076cf4dd108)

Type `:Sf` in Ex mode will list all user commands:
![Image 005](https://github.com/xixiaofinland/sf.nvim/assets/13655323/d5e9b626-e75f-4ecb-befc-c8535da8f2d9)


<br>

## 📚 Full Document

Checking all features via `:h sf.nvim` or [help.txt file](https://github.com/xixiaofinland/sf.nvim/blob/dev/doc/sf.txt).


<br>

## 🚀 Feature: List/retrieve metadata and metadata types

Sometimes you don't know what metadata the target org contains, and you want to
list them and fetch specific ones.

1. Retrieve the metadata data by running the user command `SFPullMd`.
2. Run `SFListMdToRetrieve` (or `require('sf').list_md_to_retrieve()`) to show
   the list in a pop-up (requires the fzf-lua plugin) and select one to
   download to local.

The same applies to metadata types (like all Apex Classes, Apex Triggers, LWC,
Aura, etc.). You can list them and fetch all of a specific type.

1. Retrieve the metadata types by running the user command `SFPullMdType`.
2. Run `SFListMdTypeToRetrieve` (or `require('sf').list_md_type_to_retrieve()`) to show the
   list in a pop-up (requires the fzf-lua plugin) and select one to
   download all metadata of this type to local.

<br>

## 🖥️ Integrated terminal

The integrated terminal is a general purpose term.

you can pass any shell command into `run()` method to execute it in the integrate
terminal. For instance, `require('sf').run('ls -la')`.

<br>

## 🤝 Contributions

Thanks to the following people for contributing to this project:

- ![GitHub Profile Image](https://github.com/FedeAbella.png?size=50) [@FedeAbella](https://github.com/FedeAbella)
- ![GitHub Profile Image](https://github.com/waltonzt.png?size=50) [@waltonzt](https://github.com/waltonzt)

<br>

## 📜 License
MIT.
