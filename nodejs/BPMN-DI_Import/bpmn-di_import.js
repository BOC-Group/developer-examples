const axios = require("axios");
const fs = require("fs").promises;
const path = require("path");

const USERNAME = "%USERNAME%"; // Replace %USERNAME% with your username.
const PASSWORD = "%PASSWORD%"; // Replace %PASSWORD% with your password.
const REPO_ID = "%REPO_ID%"; // Replace %REPO_ID% with your repository's id. (e.g. %{16bcc961-f38b-482a-b056-8691f93e4eb8}% note that {} are optional.)
const GROUP_ID = "%GROUP_ID%"; // Replace %GROUP_ID% with the id of the group you want to import into. (e.g. %{ee4729e0-67ef-41e6-96ec-89844f93bea2}% note that {} are optional.)
const REST_BASE_URL = "%REST_BASE_URL%"; // Replace %REST_BASE_URL% with the path to your web client (e.g. http://server:port/ADOweb).
const FOLDER_PATH = "%FOLDER_PATH%"; // Replace %FOLDER_PATH% with the path to the folder of your .bpmn files. (e.g. assets\\bpmn)
const API_VERSION = "2.1"; // Replace %API_VERSION% if needed, default is 2.1

const restUrl = `${REST_BASE_URL}/rest/${API_VERSION}/repos/${REPO_ID}/modelgroups/${GROUP_ID}/actions?type=import`;
const base64Credentials = Buffer.from(`${USERNAME}:${PASSWORD}`).toString("base64");

async function generateHeaders() {
  const headers = {
    Authorization: `Basic ${base64Credentials}`,
    "Content-Type": "application/bpmn+xml",
  };
  return headers;
}

async function sendPostRequest(filePath, file) {
  try {
    const headers = await generateHeaders();
    const fileData = await fs.readFile(filePath);

    const response = await axios.post(restUrl, fileData, {
      headers,
    });

    const currentDate = new Date();
    const isoDate = currentDate.toISOString();
    const formattedDate = isoDate.replace("T", " ").slice(0, -1);
    const logData = `${formattedDate} [${response.data.validBPMNDIFile ? "SUCCESS" : "ERROR"}] [FORMAT ${response.data.validBPMNDIFile ? "OK" : "INVALID"}] [Response Code: ${response.status}] [${file}] [${response.data.importedModels[0].id}] [${response.data.importedModels[0].metaName}]\n`;

    if (response.status === 200) {
      if (response.data.validBPMNDIFile) {
        await fs.appendFile("logs\\import_success.log", logData);
      } else {
        await fs.appendFile("logs\\import_questionable.log", logData);
      }
    } else {
      await fs.appendFile("logs\\import_invalid.log", logData);
    }
    await fs.appendFile("logs\\import.log", logData);
    await fs.appendFile("logs\\import_raw.log", JSON.stringify(response.data, null, 2));
  } catch (error) {
    console.error("Axios Error:", error);
  }
}

async function main() {
  try {
    const files = await fs.readdir(FOLDER_PATH);

    for (const file of files) {
      const filePath = path.join(FOLDER_PATH, file);
      await sendPostRequest(filePath, file);
    }
  } catch (error) {
    console.error("File System Error:", error);
  }
}

main();
