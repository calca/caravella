"""Generate a Caravella backup JSON with demo groups for store screenshots."""
import json
import random
import sys
import uuid
from datetime import datetime, timedelta

random.seed(7)
NOW = datetime(2026, 10, 15, 13, 0)
PHOTO_DIR = "/storage/emulated/0/Android/data/io.caravella.egm/files/demo"


def iso(d):
    return d.strftime("%Y-%m-%dT%H:%M:%S.000")


def uid():
    return str(uuid.uuid4())


def people(*names):
    return [{"id": uid(), "name": n, "createdAt": iso(NOW - timedelta(days=30))} for n in names]


def cats(*names):
    return [{"id": uid(), "name": n, "createdAt": iso(NOW - timedelta(days=30))} for n in names]


def group(title, gtype, ppl, categories, expenses, start, end, photo=None, color=None,
          pinned=False, sync=False, ts_days=0):
    by_name = {p["name"]: p for p in ppl}
    cat_by_name = {c["name"]: c for c in categories}
    exp = []
    for name, cat, amount, payer, days_ago, hour, place in expenses:
        e = {
            "id": uid(),
            "name": name,
            "category": cat_by_name[cat],
            "amount": amount,
            "paidBy": by_name[payer],
            "date": iso((NOW - timedelta(days=days_ago)).replace(hour=hour, minute=random.randint(0, 59))),
            "note": None,
        }
        if place:
            e["location"] = place
        exp.append(e)
    g = {
        "id": uid(),
        "title": title,
        "expenses": exp,
        "participants": ppl,
        "startDate": iso(start),
        "endDate": iso(end),
        "currency": "€",
        "categories": categories,
        "timestamp": iso(NOW - timedelta(days=ts_days)),
        "pinned": pinned,
        "archived": False,
        "file": f"{PHOTO_DIR}/{photo}" if photo else None,
        "color": color,
        "notificationEnabled": False,
        "groupType": gtype,
        "autoLocationEnabled": False,
        "syncEnabled": sync,
    }
    return g


def loc(name, locality, country, iso_cc, lat, lng):
    return {"name": name, "locality": locality, "country": country, "isoCountryCode": iso_cc,
            "latitude": lat, "longitude": lng, "address": f"{name}, {locality}, {country}"}


norway_people = people("Anna", "Marco", "Sofia", "Luca")
norway_cats = cats("Food", "Accommodation", "Transport", "Activities", "Groceries")
norway = group(
    "Norway Road Trip", "travel", norway_people, norway_cats,
    [
        ("Ferry to Lysefjord", "Transport", 86.00, "Marco", 0, 10, loc("Stavanger ferry terminal", "Stavanger", "Norway", "NO", 58.973, 5.733)),
        ("Fish soup & bread", "Food", 54.50, "Anna", 0, 13, loc("Fisketorget", "Bergen", "Norway", "NO", 60.395, 5.325)),
        ("Preikestolen parking", "Transport", 25.00, "Luca", 1, 8, loc("Preikestolen", "Strand", "Norway", "NO", 58.986, 6.190)),
        ("Cabin by the fjord", "Accommodation", 312.00, "Sofia", 1, 19, loc("Lysefjord cabins", "Forsand", "Norway", "NO", 58.905, 6.105)),
        ("Supermarket", "Groceries", 68.40, "Anna", 2, 18, None),
        ("Kayak rental", "Activities", 120.00, "Marco", 2, 11, loc("Fjord Kayak", "Flåm", "Norway", "NO", 60.862, 7.113)),
        ("Flåm railway tickets", "Transport", 196.00, "Sofia", 3, 9, loc("Flåm station", "Flåm", "Norway", "NO", 60.863, 7.114)),
        ("Pizza night", "Food", 72.00, "Luca", 3, 20, None),
        ("Fuel", "Transport", 81.30, "Marco", 4, 16, None),
        ("Hotel in Bergen", "Accommodation", 268.00, "Anna", 5, 21, loc("Bryggen", "Bergen", "Norway", "NO", 60.397, 5.324)),
        ("Fløibanen funicular", "Activities", 48.00, "Sofia", 5, 15, loc("Fløibanen", "Bergen", "Norway", "NO", 60.396, 5.328)),
        ("Coffee & cinnamon buns", "Food", 23.60, "Luca", 6, 10, None),
    ],
    NOW - timedelta(days=6), NOW + timedelta(days=3), photo="norway.jpg", pinned=True, sync=True,
)

bruges = group(
    "Weekend in Bruges", "travel", people("Anna", "Giulia", "Pietro"), cats("Food", "Accommodation", "Transport", "Activities"),
    [
        ("Canal boat tour", "Activities", 36.00, "Giulia", 12, 11, None),
        ("Belgian waffles", "Food", 14.50, "Anna", 12, 16, None),
        ("B&B two nights", "Accommodation", 240.00, "Pietro", 13, 18, None),
        ("Train from Brussels", "Transport", 51.60, "Anna", 13, 9, None),
        ("Dinner at the Markt", "Food", 96.00, "Giulia", 13, 20, None),
    ],
    NOW - timedelta(days=13), NOW - timedelta(days=11), photo="bruges.jpg", ts_days=11,
)

ski = group(
    "Ski Week Dolomites", "travel", people("Anna", "Marco", "Elena", "Davide", "Chiara"), cats("Ski pass", "Accommodation", "Food", "Transport"),
    [
        ("Ski pass 6 days", "Ski pass", 1450.00, "Davide", 40, 9, None),
        ("Chalet deposit", "Accommodation", 600.00, "Anna", 45, 12, None),
    ],
    NOW + timedelta(days=60), NOW + timedelta(days=67), photo="ski.jpg", ts_days=2,
)

flat = group(
    "Flat 3B", "family", people("Anna", "Tom", "Lea"), cats("Rent", "Bills", "Groceries", "Cleaning"),
    [
        ("October rent", "Rent", 1350.00, "Anna", 14, 9, None),
        ("Electricity", "Bills", 92.40, "Tom", 9, 18, None),
        ("Internet", "Bills", 29.90, "Lea", 8, 10, None),
        ("Weekly groceries", "Groceries", 74.20, "Lea", 3, 19, None),
        ("Cleaning supplies", "Cleaning", 18.70, "Tom", 2, 17, None),
    ],
    NOW - timedelta(days=15), NOW + timedelta(days=15), color=3, ts_days=1,
)

chicago = group(
    "Chicago Conference", "personal", people("Anna"), cats("Hotel", "Meals", "Taxi"),
    [
        ("Hotel 3 nights", "Hotel", 642.00, "Anna", 25, 22, None),
        ("Team dinner", "Meals", 88.00, "Anna", 24, 20, None),
        ("Airport taxi", "Taxi", 46.50, "Anna", 25, 15, None),
    ],
    NOW - timedelta(days=26), NOW - timedelta(days=23), photo="chicago.jpg", ts_days=20,
)

json.dump([norway, bruges, ski, flat, chicago], sys.stdout, ensure_ascii=False, indent=1)
