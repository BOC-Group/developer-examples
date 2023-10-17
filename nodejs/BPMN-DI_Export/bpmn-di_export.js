const axios = require("axios");
const fs = require("fs").promises;
const path = require("path");

const USERNAME = "%USERNAME%"; // Replace %USERNAME% with your username.
const PASSWORD = "%PASSWORD%"; // Replace %PASSWORD% with your password.
const REPO_ID = "%REPO_ID%"; // Replace %REPO_ID% with your repository's id. (e.g. %{16bcc961-f38b-482a-b056-8691f93e4eb8}% note that {} are optional.)
const REST_BASE_URL = "%REST_BASE_URL%"; // Replace %REST_BASE_URL% with the path to your web client (e.g. http://server:port/ADOweb).

const base64Credentials = Buffer.from(`${USERNAME}:${PASSWORD}`).toString("base64");

const jsonQuery = {
  filters: [
    {
      className: "MT_BUSINESS_PROCESS_DIAGRAM_BPMN_20",
    },
  ],
  scope: {
    models: true,
  },
};
const queryString = JSON.stringify(jsonQuery, null, 2);
const query = encodeURIComponent(queryString);

async function getModelIdsByRepoId(REPO_ID, query) {
  try {
    const apiVersion = "3.0";
    const apiUrl = `${REST_BASE_URL}/rest/${apiVersion}/repos/${REPO_ID}/search?query=${query}`;

    const headers = {
      Authorization: `Basic ${base64Credentials}`,
    };

    const response = await axios.get(apiUrl, { headers });

    const modelIds = response.data.items.map((element) => element.id);
    return modelIds;
  } catch (error) {
    console.error("Error in getModelIdsByRepoId:", error.message);
    throw error;
  }
}

async function getModelFilesByListOfIds(listOfModelIds) {
  try {
    for (const modelId of listOfModelIds) {
      const apiVersion = "2.1";
      const apiUrl = `${REST_BASE_URL}/rest/${apiVersion}/repos/${REPO_ID}/models/${modelId}`;

      const headers = {
        Authorization: `Basic ${base64Credentials}`,
        Accept: "application/bpmn+xml",
      };

      const response = await axios.get(apiUrl, { headers });
      const modelData = response.data;

      await fs.writeFile(`target/${modelId}.bpmn`, modelData);

      console.log(`Downloaded ${modelId}.bpmn`);
    }
  } catch (error) {
    console.error("Error in getModelFilesByListOfIds:", error.message);
  }
}

(async () => {
  try {
    const modelIds = await getModelIdsByRepoId(REPO_ID, query);
    console.log("Model IDs:", modelIds);
    await getModelFilesByListOfIds(modelIds);
  } catch (error) {
    console.error("Main Error:", error.message);
  }
})();
