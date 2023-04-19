import pandas as pd
import numpy as np
import json
import csv
import os


class Generator(object):

    def __init__(self, path: str) -> None:
        self.langCodes: list = []
        self.path: str = path

    def loadLang(self) -> None:
        with open(self.path) as csv_file:
            reader = pd.read_csv(csv_file, header=None)
            self.languages: list = reader.iloc[:, 0].values
            self.langCodes: list = reader.iloc[:, 1].values

    def toPrint(self) -> None:
        for code in self.langCodes:
            print("Locale('"+code+"'),")

    def deleteUnsupported(self) -> None:
        # index: int = 0
        for code in self.langCodes:
            # print(str(index)+' '+ code)
            # index += 1
            if code not in self.supportedLangs:
                code = code.replace('[', '')
                code = code.replace(']', '')
                code = code.replace("'", '')
                try:
                    print('El archivo '+code+'.json'+' se borro.')
                except:
                    print('El archivo '+code+'.json'+' no existe.')


if __name__ == '__main__':
    gr = Generator(
        '/Users/alejandro/Desktop/Apps/Walpy/Translator/supportedLanguages.csv')
    gr.loadLang()
    gr.toPrint()
