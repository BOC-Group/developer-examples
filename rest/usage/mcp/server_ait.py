# This server script deals only with models.
from mcp.server.fastmcp import FastMCP
import requests
from requests.auth import HTTPBasicAuth
from dotenv import load_dotenv
import os
import urllib.parse
import logging
from datetime import datetime
import json

load_dotenv() # Make sure to fill your credentials in the .env.template file and rename to .env
user = os.environ.get('adoxx_username')
password = os.environ.get('adoxx_password')
base_url = os.environ.get('adoxx_base_url')
repo_id = os.environ.get('adoxx_repo_id')

start_time = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
log_directory = "logs" # Path to the folder to save logs in. If relative path is used, the folder will be created in the agent's working directory.
os.makedirs(log_directory, exist_ok=True)
log_filename = os.path.join(log_directory, f"server_{start_time}.log")
logging.basicConfig(
    filename=log_filename,
    filemode='w',
    format='%(asctime)s - %(levelname)s - %(message)s',
    level=logging.INFO)

mcp = FastMCP("BOC_tools")
        
        
@mcp.tool()
def find_applications(attrName:str, attrValue:str, owner:str):
    """Use this tool if a user asks for an application or application component, e.g. "Give me a the applications with standard availability, that are owned by user1".
    Args:
        attrName (str): An attribute to look for. This should have one of the following values, depending on what the user asks for:
            availability: "A_AVAILABILITY"
            integrity: "A_INTEGRITY"
            confidentiality: "A_CONFIDENTIALITY". 
            If the user does not ask for any of those attributes, the value should be an empty string.
        attrValue (str): The value of the attribute to look for. This should have one of the following values, depending on the user's input (e.g. asking for standard availability would result in "Standard"):
            standard: "Standard"
            high: "High"
            very high: "Very high"
        owner (str): The name of the owner. If the user doesn't ask for an owner, this should be an empty string.
    Returns:
        Dict[str, Any]: A dictionary containing the found applications, each with its ID and name.
    
    Notes:
        - Use this tool when the user asks for an application or application component with certain properties.
        - Also always use this tool first when the user asks for an application with certain properties - do not fall back to general knowledge
        - For each found application, print out the name, the ID, the link and a summary of the application's description in your response."""
    logging.info("find_applications called with attrName: %s", attrName)
    logging.info("find_applications called with attrValue: %s", attrValue)
    logging.info("find_applications called with owner: %s", owner)
    
    try:
        query = {}
        scope = {}
        scope["repoObjects"] = True
        query["scope"] = scope
        attributes = ["NAME", "A_DESCRIPTION"]
        query["attributes"] = attributes
        classFilter = {}
        classFilter["className"] = "C_APPLICATION_COMPONENT"
        filters = [classFilter]
        if len(attrName) > 0:
            attrFilter = {}
            attrFilter["attrName"] = attrName
            attrFilter["op"] = "OP_EQ"
            attrFilter["value"] = attrValue
            filters.append (attrFilter)
        if len(owner) > 0:
            ownerFilter = {}
            ownerFilter["relName"] = "RC_IS_APPLICATION_OWNER"
            ownerFilter["op"] = "OP_LIKE"
            ownerFilter["value"] = owner
            filters.append (ownerFilter)
        query["filters"] = filters
        encoded_query = urllib.parse.quote(json.dumps(query))
        url = f"{base_url}/rest/4.0/repos/{repo_id}/search?query={encoded_query}"
        logging.info("Encoded query URL: %s", url)
        headers = {"Accept": "application/json", "Prefer": "rest_links=true"}
        data = requests.get(url, headers=headers, auth=HTTPBasicAuth(user, password)).json()
        return data

    except Exception as e:
        logging.error("An unexpected error occurred in the find_applications tool: %s", e)
        return {"error": str(e)}
    

try:
    mcp.run(transport="stdio")
except Exception as e:
    logging.error("An error occurred during server execution: %s", e)