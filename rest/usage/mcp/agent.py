import asyncio
import json
from openai import AsyncOpenAI
from mcp import StdioServerParameters, ClientSession
from mcp.client.stdio import stdio_client
from dotenv import load_dotenv
import logging
import os
from datetime import datetime

load_dotenv() # Make sure to fill your credentials in the .env.template file and rename to .env
server = os.environ.get('adoxx_server_file') # Path to server file (relative to agent's working directory or absolute)

start_time = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
log_directory = "logs" # Path to the folder to save logs in
os.makedirs(log_directory, exist_ok=True)
log_filename = os.path.join(log_directory, f"agent_{start_time}.log")
messages_filename = os.path.join(log_directory, f"messages_{start_time}.json")
logging.basicConfig(
    filename=log_filename,
    filemode='w',
    format='%(asctime)s - %(levelname)s - %(message)s',
    level=logging.INFO)


async def main():
    try:
        openai_client = AsyncOpenAI()
        server_file_exists = os.path.isfile(server)
        if not server_file_exists:
            logging.error("Make sure the server file exists: %s", server)

        server_params = StdioServerParameters(
            command="python",
            args=[server])
        
        logging.info("Server parameters: %s", server_params)
        
    except Exception as e:
        logging.error("An unexpected error occurred: %s", e)
        print(f"Error initializing server: {e}")
 
    try:
        async with stdio_client(server_params) as (reader, writer):
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
                            "You are an assistant that can use tools (functions) for interacting with a repository of graphical models (e.g. BPMN, ArchiMate, etc.). "
                            "If the user is asking a general question about a process or an act, try to use the provided tools (functions). "
                            "You should always rather use the available tools over answering from your own general knowledge."
                            "Only use general knowledge if a tool is not suitable or available. "
                            "IMPORTANT: If you respond using general knowledge and not a tool, explicitly state this at the beginning of your reply "
                            "by saying: 'Answer based on general knowledge — no tool was used.'")}]
    
                    while True:
                        user_input = input("User: ")
                        # logging.info("User input: %s", user_input)
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
        logging.error("Error initializing agent: %s", e)
        print(f"Error initializing agent: {e}")
 
try:
    asyncio.run(main())
except Exception as e:
    logging.error("An error occurred during agent execution: %s", e)
