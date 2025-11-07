import os
import json
import logging
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(filename='/workspace/prayai/log.txt', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

DATABASE_FILE = "/workspace/prayai/database.json"

def load_database():
    """
    Loads the database from the database.json file.

    Returns:
        A list of prayers.
    """
    with open(DATABASE_FILE, "r", encoding="utf-8") as f:
        return json.load(f)

def save_database(database):
    """
    Saves the database to the database.json file.

    Args:
        database: The database to save.
    """
    with open(DATABASE_FILE, "w", encoding="utf-8") as f:
        json.dump(database, f, indent=4, ensure_ascii=False)

def summarize_text(text):
    """
    Summarizes the given text using the Gemini API.

    Args:
        text: The text to summarize.

    Returns:
        A summary of the text.
    """
    model = genai.GenerativeModel('gemini-pro-latest')
    response = model.generate_content(f"다음 텍스트를 10개 이하의 키워드로 요약해 주세요: {text}", generation_config=genai.types.GenerationConfig(temperature=0))
    return response.text

def create_prayer(keywords):
    """
    Creates a prayer based on the given keywords using the Gemini API.

    Args:
        keywords: The keywords to use to create the prayer.

    Returns:
        A prayer.
    """
    model = genai.GenerativeModel('gemini-pro-latest')
    response = model.generate_content(f"다음 키워드를 바탕으로 기도문을 작성해 주세요: {keywords}")
    return response.text

def generate_prayer(user_input):
    """
    Generates a prayer based on user input.

    Args:
        user_input: The user's input.

    Returns:
        A prayer.
    """
    logging.info(f"User input: {user_input}")
    keywords = summarize_text(user_input)
    logging.info(f"Keywords: {keywords}")

    database = load_database()

    for prayer in database:
        if prayer["keywords"] == keywords:
            logging.info("Prayer found in database.")
            return prayer["prayer"]

    logging.info("Prayer not found in database. Generating a new prayer.")
    new_prayer = create_prayer(keywords)
    database.append({"keywords": keywords, "prayer": new_prayer})
    save_database(database)
    logging.info("New prayer saved to database.")

    return new_prayer

if __name__ == "__main__":
    user_input = "가족의 건강과 시험 합격을 위해 기도하고 싶습니다."
    prayer = generate_prayer(user_input)
    print(prayer)