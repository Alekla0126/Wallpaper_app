#
# ▄▄▄█████▓ ██░ ██ ▓█████     ▄▄▄       ██▓     ▄████▄   ██░ ██ ▓█████  ███▄ ▄███▓ ██▓  ██████ ▄▄▄█████▓
# ▓  ██▒ ▓▒▓██░ ██▒▓█   ▀    ▒████▄    ▓██▒    ▒██▀ ▀█  ▓██░ ██▒▓█   ▀ ▓██▒▀█▀ ██▒▓██▒▒██    ▒ ▓  ██▒ ▓▒
# ▒ ▓██░ ▒░▒██▀▀██░▒███      ▒██  ▀█▄  ▒██░    ▒▓█    ▄ ▒██▀▀██░▒███   ▓██    ▓██░▒██▒░ ▓██▄   ▒ ▓██░ ▒░
# ░ ▓██▓ ░ ░▓█ ░██ ▒▓█  ▄    ░██▄▄▄▄██ ▒██░    ▒▓▓▄ ▄██▒░▓█ ░██ ▒▓█  ▄ ▒██    ▒██ ░██░  ▒   ██▒░ ▓██▓ ░
#   ▒██▒ ░ ░▓█▒░██▓░▒████▒    ▓█   ▓██▒░██████▒▒ ▓███▀ ░░▓█▒░██▓░▒████▒▒██▒   ░██▒░██░▒██████▒▒  ▒██▒ ░
#   ▒ ░░    ▒ ░░▒░▒░░ ▒░ ░    ▒▒   ▓▒█░░ ▒░▓  ░░ ░▒ ▒  ░ ▒ ░░▒░▒░░ ▒░ ░░ ▒░   ░  ░░▓  ▒ ▒▓▒ ▒ ░  ▒ ░░
#     ░     ▒ ░▒░ ░ ░ ░  ░     ▒   ▒▒ ░░ ░ ▒  ░  ░  ▒    ▒ ░▒░ ░ ░ ░  ░░  ░      ░ ▒ ░░ ░▒  ░ ░    ░
#   ░       ░  ░░ ░   ░        ░   ▒     ░ ░   ░         ░  ░░ ░   ░   ░      ░    ▒ ░░  ░  ░    ░
#           ░  ░  ░   ░  ░         ░  ░    ░  ░░ ░       ░  ░  ░   ░  ░       ░    ░        ░
#                                              ░
from deep_translator import GoogleTranslator
import pandas as pd
import collections
import json
import csv


# A simple program to translate the JSON files of my Flutter apps.
class Translator(object):

    # Function: to initialize and construct the class.
    # Parameters: JSON to translate: str,
    # output path where the JSON files will be store: str,
    # supported languages of the flutter framework: str.
    # Returns: None
    def __init__(self, file_path: str, output_path: str, supported_path: str) -> None:
        with open(file_path, 'r') as f:
            self.data: dict = json.load(f)
        self.supported_path: str = supported_path
        self.output_path: str = output_path
        self.googleLanguages: list = []
        self.supportedNames: dict = []
        self.translation: list = []
        self.sentences: list = []
        self.langCode: list = []
        self.loadLang()

    # Function: to extract the language supported by the Flutter framework and Google translate.
    # Parameters: None.
    # Returns: None.
    def loadLang(self) -> None:
        # Supported languages by Google translate.
        reader: dict = GoogleTranslator(source='auto', target='en').get_supported_languages(as_dict=True) 
        self.googleLanguages: list = list(reader.values())
        # The keys with the language are inverted to contain the language code.
        self.supportedNames: dict = dict((v, k) for k, v in reader.items())
        # Supported languages by the Flutter framework.
        supportedLangs = pd.read_csv(self.supported_path, header=None)
        self.langCode: list = supportedLangs.iloc[:, 0].values

    # Function: to read self.data and extract the strings.
    # Parameters: None.
    # Returns: None.
    def read(self) -> None:
        # The elements contain the labels of the JSON.
        for element in self.data:
            # Just the elements with sentences are extracted.
            if (type(self.data[element]) == type(str())):
                self.sentences.append(self.data[element])
            else:
                # The rest of the elements inside of a list. The value contains the labels inside of the list.
                for value in self.data[element]:
                    self.sentences.append(self.data[element][value])

    # Function: translate the data and save in a JSON.
    # Parameters: None.
    # Returns: None.
    def translate(self) -> None:
        supportedLabels: list = []
        supportedCode: list = []
        supportedName: list = []
        for language in self.langCode:
            # It the languages supported by Flutter are inside the list of languages supportted by Google Translate.
            if language in self.googleLanguages:
                self.translation: list = []
                for words in self.sentences:
                    self.translation.append(GoogleTranslator(
                        'auto', language).translate(words).capitalize())
                self.saveJson(language)
                supportedCode.append(language)
                # The format of the labels is processed to fit with the requirements of the JSON file.
                self.supportedNames[language].replace('(', '')
                self.supportedNames[language].replace(')', '')
                self.supportedNames[language].replace(' ', '_')
                supportedName.append(
                    self.supportedNames[language].capitalize())
                supportedLabels.append(self.supportedNames[language].lower())
        # The list of languages and their corresponding code are saved in a CSV and JSON file.
        self.saveLanguages(supportedCode, supportedName, supportedLabels)

    # Function: save the generated files.
    # Parameters: a language to save: str.
    # Returns: None.
    def saveJson(self, language: str) -> None:
        index: int = 0
        for element in self.data:
            if (type(self.data[element]) == type(str())):
                self.data[element] = self.translation[index].capitalize()
                index += 1
            else:
                for value in self.data[element]:
                    self.data[element][value] = self.translation[index].capitalize()
                    index += 1
        with open(self.output_path +
                  language +
                  '.json',
                  'w',
                  encoding='utf-8'
                  ) as f:
            json.dump(self.data, f, ensure_ascii=False, indent=4)
        print(language+' was saved.')

    # Function: save the supported languages in a JSON and CSV files.
    # Parameters: the languages codes: list, the supported languages: list.
    # Returns: None.
    def saveLanguages(self, supportedCode: list, supportedLabels: list, supportedName: list) -> None:
        # The language code and name are saved in a dictionary.
        supportedLanguages: dict = dict(zip(supportedName, supportedCode))
        # The language label and name are saved in a dictionary.
        labels: dict = dict(zip(supportedName, supportedLabels))
        # The languages are saved in a JSON for personal use in your project.
        with open("supportedLanguages.json", "w") as outfile:
            json.dump(labels, outfile)
        # The language code and name are saved in a CSV for the consulting and corroborating.
        with open('supportedLanguages.csv', 'w') as f:
            for key in supportedLanguages.keys():
                f.write("%s,%s\n" % (key, supportedLanguages[key]))


if __name__ == '__main__':
    # Function: instantiate the class.
    # Parameters: path: str, output path: str and supported languages path: str.
    translator = Translator(
        '/Users/alejandro/Desktop/Life/Apps/Walpy/wallpaper_app/assets/translations/en-US.json',
        '/Users/alejandro/Desktop/Life/Apps/Walpy/wallpaper_app/assets/translations',
        '/Users/alejandro/Desktop/Life/Apps/Walpy/Translator/Supported_languages.csv'
    )
    # Function to read the json file, it can be change according to the needs.
    translator.read()
    # Function to translate and store the json files. It also saves a list of languages ​​and codes in CSV and JSON format.
    translator.translate()