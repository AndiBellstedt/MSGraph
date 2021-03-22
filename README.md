![logo][]
# MSGraph - Interacting with Microsft Graph
| Plattform | Information |
| --------- | ----------- |
| PowerShell gallery | [![PowerShell Gallery](https://img.shields.io/powershellgallery/v/MSGraph?label=psgallery)](https://www.powershellgallery.com/packages/MSGraph) [![PowerShell Gallery](https://img.shields.io/powershellgallery/p/MSGraph)](https://www.powershellgallery.com/packages/MSGraph) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/MSGraph?style=plastic)](https://www.powershellgallery.com/packages/MSGraph) |
| GitHub  | [![GitHub release](https://img.shields.io/github/release/AndiBellstedt/MSGraph.svg)](https://github.com/AndiBellstedt/MSGraph/releases/latest) ![GitHub](https://img.shields.io/github/license/AndiBellstedt/MSGraph?style=plastic) <br> ![GitHub issues](https://img.shields.io/github/issues-raw/AndiBellstedt/MSGraph?style=plastic) <br> ![GitHub last commit (branch)](https://img.shields.io/github/last-commit/AndiBellstedt/MSGraph/master?label=last%20commit%3A%20master&style=plastic) <br> ![GitHub last commit (branch)](https://img.shields.io/github/last-commit/AndiBellstedt/MSGraph/Development?label=last%20commit%3A%20development&style=plastic) |
<br>
The MSGraph module is a wrapper around the Graph API of Microsoft.
It offers tools to interact with exchange online (more services planned and seamlessly supportable).

All cmdlets are build with
- powershell regular verbs
- mostly with pipeling availabilties
- comprehensive logging on verbose and debug channel

> Note: Project is still in its infancy, more to come

## Installation
Install the module from the PowerShell Gallery (systemwide):

    Install-Module MSGraph

or install it only for your user:

    Install-Module MSGraph -Scope CurrentUser




[logo]: assets/MSGraph_Banner.png