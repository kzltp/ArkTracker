# Getting Started

ArkTracker is errata parser. This Debian errata parser ArkTracker use the "Debian Security Announcements (DSA)" to give up to date Debian erratum information.


![Alt Text](https://media2.giphy.com/media/OIVBUiW2ejOUKqgeur/giphy.gif)
## Requirement
ArkTracker need ```jq```, ```wget``` library and internet connection.

```bash
apt-get install jq wget 
```
## Supported Operating Systems
* Debian 10 (Buster)
* Another Distros is gonna be add coming soon

## Installation

```bash
git clone https://github.com/kzltp/ArkTracker.git
cd ArkTracker && chmod +x ArkTracker.sh
```

## Usage

```bash
bash ArkTracker.sh
```

## Release Note
###### Beta v1
* ArkTracker gives only information current version.


## Future
* Ubuntu Support
* Update Option
* Mail Notification
* Create Service
