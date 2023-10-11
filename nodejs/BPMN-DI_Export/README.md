# BPMN DI Export

This script exports all models from a repository as .bpmn files. It uses the [BPMN DI Rest API](https://developer.boc-group.com/adoxx/en/rest-bpmn-di/)

How to use

- navigate to cloned local directory ( eg. "cd C:\Hg\BPMN-DI_Export")
- Install dependencies: `npm install`
- set up basic auth REST interface, create a local user which shall be used for REST API
- check if basic auth REST calls work, e.g  GET http://localhost:8080/ADOweb/rest/3.0/repos
- Edit the variables to suit your current projekt.
- adapt query (if necessary) - by default it will query all BPMN diagrams (all modelstates)
-- user and password
-- base url
-- repo id
- node bpmn-di_export.js


What the script does

- query all models of modeltype BPMN diagram
- get all bpmn di files for the queried models and download them into the "target" subfolder of the current "BPMN-DI_Export" folder