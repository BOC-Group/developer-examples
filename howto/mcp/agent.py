import asyncio
import json
import base64
from openai import AsyncOpenAI
from mcp import ClientSession
from mcp.client.streamable_http import streamablehttp_client
from dotenv import load_dotenv
import logging
import os
from datetime import datetime

load_dotenv() # Make sure to fill your credentials in the .env.template file and rename to .env
ADOXX_URL = os.environ.get("adoxx_url")

start_time = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
log_directory = "logs"
os.makedirs(log_directory, exist_ok=True)
log_filename = os.path.join(log_directory, f"agent_{start_time}.log")
messages_filename = os.path.join(log_directory, f"messages_{start_time}.json")
 
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
file_handler = logging.FileHandler(log_filename)
file_handler.setFormatter(formatter)
 
# root logger
root_logger = logging.getLogger()
root_logger.setLevel(logging.INFO) # Change logging level here
root_logger.addHandler(file_handler)


async def main():
    try:
        username = os.environ.get("adoxx_username");
        password = os.environ.get("adoxx_password");
        token = base64.b64encode(f"{username}:{password}".encode()).decode()
        
        headers = {"Authorization": f"Basic {token}"}
        openai_client = AsyncOpenAI()
    except Exception as e:
        logging.error("Error during initializing the client: %s", e)
        print(f"Error during initializing the client: {e}")
 
    try:
        async with streamablehttp_client(
            f"{ADOXX_URL}/mcp/message",
            headers=headers
        ) as (reader, writer, get_session_id):
            logging.info("Connected to server")
            try:
                async with ClientSession(reader, writer) as session:
                    await session.initialize()
    
                    tools_response = await session.list_tools()
                    tools = tools_response.tools
    
                    functions = []
                    for tool in tools:
                        function = {
                            "name": tool.name,
                            "description": tool.description,
                            "parameters": tool.inputSchema
                        }
                        functions.append(function)
    
                    messages = [{
                        "role": "system",
                        "content": (
                            "You are a specialized assistant that supports tool use for interacting with a BOC metamodel and data repository. "
                            "Only use general knowledge if no suitable tool is available."
                            "IMPORTANT: If you respond using general knowledge and not a tool, explicitly state this at the beginning of your reply "
                            "by saying: 'Answer based on general knowledge — no tool was used.'")}]
    
                    while True:
                        user_input = input("User: ")
                        if user_input.strip().lower() == "exit":
                            print("Terminating the conversation...")
                            break
                        messages.append({"role": "user", "content": user_input})
    
                        max_chain = 5
                        chain_count = 0
    
                        while chain_count < max_chain:
                            try:
                                response = await openai_client.chat.completions.create(
                                    model="gpt-4o",
                                    messages=messages,
                                    functions=functions,
                                    function_call="auto"
                                )
                            except Exception as e:
                                logging.error("Unexpected error during OpenAI call: %s", e)
                                break
    
                            message = response.choices[0].message
    
                            if message.function_call:
                                try:
                                    function_name = message.function_call.name
                                    arguments = json.loads(message.function_call.arguments)
    
                                    logging.info("Calling function: %s with arguments: %s", function_name, arguments)
                                    print(f"Calling function: {function_name} with arguments: {arguments}")
                                    result = await session.call_tool(function_name, arguments)
    
                                    if not result or not result.content or not result.content[0].text:
                                        print(f"Tool '{function_name}' returned an empty result.")
                                        break
    
                                    messages.append({
                                        "role": "assistant",
                                        "content": None,
                                        "function_call": {
                                            "name": function_name,
                                            "arguments": json.dumps(arguments)
                                        }
                                    })
                                    content_text = result.content[0].text
                                    messages.append({
                                        "role": "function",
                                        "name": function_name,
                                        "content": content_text
                                    })
                                    with open(messages_filename, "w", encoding="utf-8") as f:
                                        json.dump(messages, f, ensure_ascii=False, indent=4)
    
                                    chain_count += 1
                                except json.JSONDecodeError:
                                    logging.error("Invalid JSON in function call arguments: %s", message.function_call.arguments)
                                    print("Tool call failed dur to invalid arguments.")
                                    break
                                except Exception as e:
                                    logging.error("Error calling function %s : %s", function_name, e)
                                    print(f"Error calling function '{function_name}': {e}")
                                    break
                            else:
                                print(f"Assistant: {message.content}")
                                messages.append({"role": "assistant", "content": message.content})
                                with open(messages_filename, "w", encoding="utf-8") as f:
                                    json.dump(messages, f, ensure_ascii=False, indent=4)
                                break
    
                        if chain_count >= max_chain:
                            logging.info("Reached maximum function call chain depth. Conversation halted.")
                            print("Reached maximum function call chain depth. Conversation halted.")

            except Exception as e:
                logging.error("Session management error: %s", e)
                print(f"Error during session management: {e}")
 
    except Exception as e:
        logging.error("Error during connecting to the server: %s", e)
        print(f"Error during connecting to the server: {e}")
 
try:
    asyncio.run(main())
except Exception as e:
    logging.error("An error occurred during agent execution: %s", e)
