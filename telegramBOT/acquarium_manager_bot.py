from functools import wraps
import logging, requests, io
from datetime import datetime
from telegram import ReplyKeyboardMarkup, Update
from telegram.ext import (Application, CommandHandler, ContextTypes, ConversationHandler, MessageHandler, filters)
import matplotlib.pyplot as plt
from config import *
import numpy as np

logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO
)
logger = logging.getLogger(__name__)

reply_keyboard = [
    ["Temperatura", "Media del giorno"],
    ["Storico 24h"]
]

markup = ReplyKeyboardMarkup(reply_keyboard)

CHOOSING = range(1)

def restricted(func):
    @wraps(func)
    async def wrapped(update, context, *args, **kwargs):
        user_id = update.effective_user.id
        if user_id not in allowed_chats:
            logger.info(f"Unauthorize user try to use me! {update.effective_user}")
            await update.message.reply_text("I think <a href='https://en.wikiquote.org/wiki/Time'>this</a> is what you are looking for!", parse_mode='HTML', disable_web_page_preview=True,reply_markup=markup)
            return
        return await func(update, context, *args, **kwargs)    
    return wrapped

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> int:
    await update.message.reply_text("Ciao, cosa vuoi sapere?",reply_markup=markup)
    return CHOOSING

async def temperatura_choice(update: Update, context: ContextTypes.DEFAULT_TYPE) -> int:
    response = get_temperatura()
    await update.message.reply_text(f"{response}",reply_markup=markup)
    return CHOOSING

async def media_giorno_choice(update: Update, context: ContextTypes.DEFAULT_TYPE) -> int:
    response = f"{get_media_giorno()}\n{get_temperatura_max()}\n{get_temperatura_min()}"
    await update.message.reply_text(f"{response}",reply_markup=markup)
    return CHOOSING

async def storico_24_h_choice(update: Update, context: ContextTypes.DEFAULT_TYPE) -> int:
    image_buffer = get_storico_24_h()
    await update.message.reply_photo(image_buffer,reply_markup=markup)
    return CHOOSING     

async def random_choice(update: Update, context: ContextTypes.DEFAULT_TYPE) -> int:
    await update.message.reply_text("Non ci siamo, riprova!", parse_mode='HTML', disable_web_page_preview=True,reply_markup=markup)
    return CHOOSING

def get_api_response(ation_url):
    url = f"{service_url}/{ation_url}"
    response = requests.get(url).json()
    return response

def format_created_at(created_at):
    try:
        datetime_obj = datetime.strptime(created_at, "%Y-%m-%dT%H:%M:%S.%f%z")
        formatted_created_at = datetime_obj.strftime("%d/%m/%Y alle %H:%M")
        return formatted_created_at
    except ValueError:
        return None

def extract_single_temperature_data(response):
    if response:
        temperature = response[0].get('value')
        created_at = response[0].get('created_at')
        return temperature, created_at
    return None, None

def extract_average_temperature(response):
    if response:
        print(response)
        temperatures = [float(data['value']) for data in response]
        total = sum(temperatures)
        average = total / len(temperatures)
        return round(average, 2)
    return None

def get_temperatura():
    response = get_api_response("alexa/getLastTemperature")
    temperature, created_at = extract_single_temperature_data(response)
    if temperature and created_at:
        formatted_created_at = format_created_at(created_at)
        return f"Temperatura: {temperature}.\nRegistrata il {formatted_created_at}."
    return "Nessuna temperatura disponibile."

def get_temperatura_max():
    response = get_api_response("alexa/getMaxTemperatureToday")
    temperature, created_at = extract_single_temperature_data(response)
    if temperature and created_at:
        formatted_created_at = format_created_at(created_at)
        return f"Temperatura massima: {temperature}.\nRegistrata il {formatted_created_at}."
    return "Nessuna temperatura massima di oggi disponibile."

def get_temperatura_min():
    response = get_api_response("alexa/getMinTemperatureToday")
    temperature, created_at = extract_single_temperature_data(response)
    if temperature and created_at:
        formatted_created_at = format_created_at(created_at)
        return f"Temperatura minima: {temperature}.\nRegistrata il {formatted_created_at}."
    return "Nessuna temperatura minima di oggi disponibile."

def get_media_giorno():
    response = get_api_response("alexa/getHistoryDay")
    temperature = extract_average_temperature(response)
    return f"Temperatura media: {temperature}"

def get_storico_24_h():
    response = get_api_response("alexa/getHistory")
    if response:
        return get_graph(response)
    return None

def get_graph(response):
    filtered_response = [entry for entry in response if entry["value"] is not None]
    y_values = [float(entry["value"]) for entry in filtered_response]
    x_values = [entry["created_at"] for entry in filtered_response]
    plt.figure(figsize=(12, 6))
    y_range = np.arange(24.5, 29.5, 0.5)
    for y_value in y_range:
        plt.axhline(y=y_value, color='gray', linestyle='--')
    plt.axhline(y=27, color='red', linestyle='--')
    plt.xlabel("Orario")
    plt.ylabel("Temperatura")
    plt.plot(x_values, y_values, marker='o')
    plt.ylim(24, 29)
    plt.xticks(range(0, len(x_values), 4), rotation=45)
    plt.tight_layout()
    buffer = io.BytesIO()
    plt.savefig(buffer, format='png')
    buffer.seek(0)
    plt.close()
    return buffer

def main() -> None:
    if(bot_id == ""):
        logger.error("Bot id is missing.")
        return

    application = Application.builder().token(bot_id).build()

    conv_handler = ConversationHandler(
        entry_points=[CommandHandler("start", start)],
        states={
            CHOOSING: [
                MessageHandler(filters.Regex("^(Temperatura)$"), temperatura_choice),
                MessageHandler(filters.Regex("^(Media del giorno)$"), media_giorno_choice),
                MessageHandler(filters.Regex("^(Storico 24h)$"), storico_24_h_choice),
                MessageHandler(filters.Regex("(.*?)"), random_choice),
            ],
        },
        fallbacks=[MessageHandler(filters.Regex("^Stop$"), None)],
    )
    
    application.add_handler(conv_handler)
    application.run_polling()

if __name__ == "__main__":
    main()