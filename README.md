# Git Single

## Overview

`git-single` is a Powershell script that allows you to clone a single file or directory from a GitHub repository using sparse checkout. This minimizes unnecessary downloads and simplifies access to specific files.

## Features

- Clone a **single file** from a GitHub repository.
- Clone a **specific directory** without downloading the entire repo.
- Lightweight and fast.
- Simple to use with a single command.

## Installation

To install `git-single` globally, run:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/btigi/git-single/main/git-single.ps1" -OutFile "$env:ProgramFiles\git-single\git-single.ps1"
```

Now you can use `git-single` from anywhere in your terminal.

## Usage

### Clone a Single File

```powershell
git-single https://github.com/user/repo/blob/main/path/to/file.ts
```

This will download only `file.ts` and place it in the current directory.

### Clone a Specific Directory

```powershell
git-single https://github.com/user/repo/tree/main/path/to/directory
```

This will clone only `directory` inside the repository.

## Updating `git-single`

To update the script to the latest version, run:

```powershell
git-single ---update
```

## Uninstall `git-single`


To Unistall the script to the latest version, run:

```powershell
git-single ---uninstall
```

## License

This project is licensed under the MIT License. Feel free to use and contribute!

This script is a Powershell equivalent of [git-single](https://github.com/dha-aa/git-single) by Dhananjay.