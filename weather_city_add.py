#!/usr/bin/env python3

import math
import os
import shutil
import requests
from urllib.parse import quote
from typing import Tuple, Optional, Dict


def is_installed(cmd: str) -> bool:
    """
    Sprawdza, czy dane polecenie jest dostępne w systemie.

    :param cmd: Nazwa polecenia, które chcesz sprawdzić.
    :type cmd: str
    :return: True, jeśli polecenie jest dostępne, False w przeciwnym przypadku.
    :rtype: bool
    """
    return shutil.which(cmd) is not None


def check_gnome_weather_installed() -> Tuple[bool, bool]:
    """
    Sprawdza, czy aplikacja GNOME Weather jest zainstalowana jako aplikacja systemowa lub pakiet Snap.

    :return: Krotka dwóch wartości logicznych:
             - Pierwsza wartość oznacza instalację jako aplikacja systemowa.
             - Druga wartość oznacza instalację jako pakiet Snap.
    :rtype: tuple(bool, bool)
    """
    system1 = is_installed('gnome-weather')
    snap = is_installed('snap') and 'org.gnome.Weather' in os.popen('snap list').read()

    if not system1 and not snap:
        print("GNOME Weather nie jest zainstalowane.")
        exit()

    return system1, snap


def get_language() -> str:
    """
    Pobiera kod języka ustawionego w systemie.

    :return: Kod języka, np. "pl" lub "en".
    :rtype: str
    """
    locale = os.environ.get("LANG", "en")
    return locale.split('_')[0]


def get_location_query() -> str:
    """
    Pobiera nazwę lokalizacji od użytkownika i formatuje ją do użycia w zapytaniu URL.

    :return: Nazwa lokalizacji w formacie odpowiednim dla zapytania URL.
    :rtype: str
    """
    query1 = input("Podaj nazwę lokalizacji, którą chcesz dodać do GNOME Weather: ")
    return query1.replace(" ", "+")


def fetch_location(city_name: str, language1: str = "pl") -> Optional[Dict]:
    """
    Pobiera szczegóły lokalizacji dla podanej nazwy miejscowości.

    :param city_name: Nazwa miejscowości.
    :type city_name: str
    :param language1: Kod języka, np. "pl". Domyślnie ustawiony na "pl".
    :type language1: str
    :return: Słownik z danymi lokalizacji, jeśli znaleziono; w przeciwnym razie None.
    :rtype: dict lub None
    """
    url = "https://nominatim.openstreetmap.org/search"
    query_encoded = quote(city_name)
    params = {
        "q": query_encoded,
        "format": "json",
        "limit": 1
    }
    headers = {
        "Accept-Language": language1,
        "User-Agent": "curl/7.68.0"
    }

    try:
        response = requests.get(url, params=params, headers=headers)
        response.raise_for_status()  # Sprawdza błędy HTTP
        data = response.json()

        if data:
            return data[0]  # Zwraca szczegóły pierwszej lokalizacji
        else:
            print("Nie znaleziono lokalizacji. Spróbuj użyć innych kryteriów wyszukiwania.")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Błąd podczas komunikacji z API: {e}")
        return None


def confirm_location(location1: Dict) -> None:
    """
    Pyta użytkownika o potwierdzenie dodania lokalizacji do GNOME Weather.

    :param location1: Szczegóły lokalizacji do potwierdzenia.
    :type location1: dict
    :raises SystemExit: Jeśli użytkownik nie chce dodać lokalizacji.
    """
    display_name = location1.get("display_name", "")
    answer = input(f"Czy chcesz dodać lokalizację {display_name}? [y/n]: ")
    if answer.lower() != 'y':
        print("Lokalizacja nie została dodana.")
        exit()
    print("Dodawanie lokalizacji...")


def convert_coordinates(lat1: str, lon1: str) -> Tuple[float, float]:
    """
    Konwertuje współrzędne geograficzne (szerokość i długość geograficzną) na radiany.

    :param lat1: Szerokość geograficzna w stopniach.
    :type lat1: str
    :param lon1: Długość geograficzna w stopniach.
    :type lon1: str
    :return: Szerokość i długość geograficzna w radianach.
    :rtype: tuple(float, float)
    """
    lat_rad = math.radians(float(lat1))
    lon_rad = math.radians(float(lon1))
    return lat_rad, lon_rad


def update_gnome_weather_locations(system1: bool, snap: bool, name1: str, lat1: float, lon1: float) -> None:
    """
    Aktualizuje lokalizacje w GNOME Weather, dodając nową lokalizację.

    :param system1: Czy GNOME Weather jest zainstalowane jako aplikacja systemowa.
    :type system1: bool
    :param snap: Czy GNOME Weather jest zainstalowane jako pakiet Snap.
    :type snap: bool
    :param name1: Nazwa lokalizacji.
    :type name1: str
    :param lat1: Szerokość geograficzna w radianach.
    :type lat1: float
    :param lon1: Długość geograficzna w radianach.
    :type lon1: float
    """
    location2 = f"<(uint32 2, <('{name1}', '', false, [({lat1}, {lon1})], @a(dd) [])>)>"

    if system1:
        locations = os.popen('gsettings get org.gnome.Weather locations').read().strip()
        if "@av []" not in locations:
            new_locations = locations[:-1] + f", {location2}]"
        else:
            new_locations = f"[{location2}]"
        os.system(f'gsettings set org.gnome.Weather locations "{new_locations}"')
    elif snap:
        locations = os.popen(
            'snap run gsettings get org.gnome.Weather locations').read().strip()
        if "@av []" not in locations:
            new_locations = locations[:-1] + f", {location2}]"
        else:
            new_locations = f"[{location2}]"
        os.system(f'snap run gsettings set org.gnome.Weather locations "{new_locations}"')


if __name__ == "__main__":
    system, flatpak = check_gnome_weather_installed()
    language = get_language()
    query = get_location_query()
    location = fetch_location(query, language)

    if location:
        confirm_location(location)
        lat, lon = convert_coordinates(location["lat"], location["lon"])
        name = location.get("display_name", "")
        update_gnome_weather_locations(system, flatpak, name, lat, lon)
