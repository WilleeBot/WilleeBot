# WilleeBot P-agent-IC

This is the project for the P-agent-IC which uses a layered architecture to implement various functionalities.

## Project Structure

```plaintext
src/
├── __init__.py
├── config.py
├── logger.py
├── llm_backends/
│   ├── __init__.py
│   ├── llm_backend1.py
│   └── llm_backend2.py
├── agent/
│   ├── __init__.py
│   ├── agent_implementation.py
│   └── agent_utils.py
├── telegram_handler/
│   ├── __init__.py
│   └── telegram_bot.py
└── bot.py
requirements.txt
.env.example
.gitignore
README.md
``` 

## Layered Architecture Overview
1. **Config** (`config.py`): Configuration settings for the bot.
2. **Logger** (`logger.py`): Logging implementation for tracking events.
3. **LLM Backends**: Contains files to interface with various LLM backends.
4. **Agent**: Implementation details of the bot agent and utilities.
5. **Telegram Handler**: Manages interactions with the Telegram API.
6. **Entry Point** (`bot.py`): The entry point for running the bot.

## Installation
To install the required packages, run:
```
pip install -r requirements.txt
```

## Usage
Ensure your Telegram bot token is set in the `.env` file, then run:
```
python src/bot.py
```
