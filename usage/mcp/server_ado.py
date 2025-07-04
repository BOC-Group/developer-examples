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
def get_model_id(text:str):
    """This tool searches for models by name and returns a list of potential matches along with their IDs.
    Args:
        text (str): The name or partial name of the model to search for.
    
    Returns:
        Dict[str, Any]: A dictionary containing possible model candidates, each with its ID and name.
    
    Notes:
        - Use this tool when the user mentions a model by name but you need its ID.
        - Also always use this tool first when the user asks for a certain task or a process - do not fall back to general knowledge
        - Always choose the most relevant match based on the user's intent or context.
        - Never ask the user to choose a model, even if multiple models are possible.
        - Always print out the name of the model you chose, even if there is only one result.
        - If you think that none of the found models matches the user's request, state that no matching model was found and fall back to general knowledge"""
    logging.info("get_model_id called with text: %s", text)
    
    try:
        query = f"""{{
        scope:
        {{
            models:true
        }},
        attributes:["NAME"],
        filters:
        [
            {{
                className:"MT_BUSINESS_PROCESS_DIAGRAM_BPMN_20"
            }},
            {{
                attrName:"NAME",
                op:"OP_LIKE",
                value:"{text}"
            }}
        ]
        }}"""
        encoded_query = urllib.parse.quote(query)
        url = f"{base_url}/rest/4.0/repos/{repo_id}/search?query={encoded_query}"
        logging.debug("Encoded query URL: %s", url)
        headers = {"Accept": "application/json"}
        data = requests.get(url, headers=headers, auth=HTTPBasicAuth(user, password)).json()
        return data

    except Exception as e:
        logging.error("An unexpected error occurred in the get_model_id tool: %s", e)
        return {"error": str(e)}


@mcp.tool()
def get_model_information(text: str):
    """This tool retrieves detailed information about a specific model using its ID.
    
    Args:
        text (str): The ID of the model to retrieve.
    
    Returns:
        Dict[str, Any]: A dictionary containing the model's metadata, structure, and contents.
    
    Notes:
        - If the user provides a model name instead of an ID, use the tool 'get_model_id' first to retrieve the correct ID.
        - If the user is asking a very general question or a question about a certain task or a process, they are referring to a specific model. In such cases, use the tool 'get_model_tool' first to retrieve the correct ID - do not fall back to general knowledge.
        - When using this tool, in the response to the user, also give information about the exact number of contained tasks
        - Alwas answer in the same structure: 
        -- First 'Metadata', then underneath: 
        --- 'Name': The model's name
        --- 'ID': The model's ID
        --- 'URL': The link to the model
        --- 'Number of tasks': The exact number of tasks within the model
        -- Then 'Summary': Your own summary of the model."""
    
    logging.info("get_model_information called with ID: %s", text)
    try:
        url = f"{base_url}/rest/4.0/repos/{repo_id}/models/{text}?attribute=NAME&relation= "
        logging.debug("Model information URL: %s", url)
        headers = {"Accept": "application/json"}
        data = requests.get(url, headers=headers, auth=HTTPBasicAuth(user, password)).json()
        return data
    
    except Exception as e:
        logging.error("An unexpected error occurred in get_model_information tool: %s", e)
        return {"error": str(e)}
        

try:
    mcp.run(transport="stdio")
except Exception as e:
    logging.error("An error occurred during server execution: %s", e)