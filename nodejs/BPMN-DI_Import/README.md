# BPMN DI Import

This script imports a bunch of .bpmn files into ADONIS. It uses the [BPMN DI Rest API](https://developer.boc-group.com/adoxx/en/rest-bpmn-di/)

How to use

- navigate to cloned local directory ( eg. "cd C:\Hg\BPMN-DI_Import")
- Install dependencies: `npm install`
- Edit the variables to suit your current projekt-
-- repoid
-- groupid
-- user
-- password
-- paste all bpmn di files that you want to import into the defined folder "assets\\validBPMNdata"
- node bpmn-di_import.js


What it does

- will import all BPMN DI files from the defined folder path into the defined grouü in the defined repository

