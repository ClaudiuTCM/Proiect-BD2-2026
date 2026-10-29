# WingLog

Proiect la Baze de date avansate.

## Descriere
WingLog este o aplicatie pentru pasionatii de pasari. Utilizatorii pot adauga observatii
(ce pasare au vazut, unde si cand), iar un validator verifică dacă observația e corectă.

## Pornire
1. Cu PostgreSQL creez o baza de date numita `winglog` (utilizator `winglog`, parola `winglog`).
2. Deschid proiectul in IntelliJ si rulez `Application.java`.
3. Intru in browser la `http://localhost:8080`.

Tabelele si datele de test se creeaza singure la pornire.

## Tabelele
- **utilizatori** – contrile (rol: observator, validator sau admin)
- **familii** – familiile de pasari (ex. Corvidae)
- **specii** – speciile de pasari, legate de o familie
- **locatii** – locurile unde se fac observații
- **expeditii** – iesirile organizate de utilizatori
- **expeditie_participanti** – cine a participat la fiecare expeditie
- **observatii** – ce a vazut un utilizator, intr-o locație, la o data anume
- **validari** – decizia validatorului pentru o observatie

## Relatiile
- o familie are mai multe specii
- o specie si o locatie au mai multe observatii
- un utilizator face mai multe observatii
- o observatie poate avea mai multe validari
- o expeditie are mai multi participanti, iar un utilizator poate merge la mai multe expeditii

## Reguli in baza de date
- numarul de exemplare trebuie sa fie mai mare decat 0
- rolul poate fi doar observator, validator sau admin
- statusul unei observații poate fi doar in asteptare, validata sau respisa
- username-ul si email-ul sunt unice
- un validator poate valida o observatie o singura data

## Indecsi
- pe observatii, dupa specie si data
- pe observatii, dupa locatie
- pe observatiile care asteapta validare

## Paginile aplicatiei
1. **Observatii** – lista observatiilor, cu optiune de stergere
2. **Adauga** – formular pentru o observatie noua
3. **Validare** – observatiile care asteapta, cu butoane de validare sau respingere
4. **Specii** – lista speciilor
5. **Locatii** – lista locatiilor
6. **Top** – cele mai observate specii

## Operații CRUD
Pentru fiecare tabel exista:
- `GET /api/{tabel}` – lista
- `GET /api/{tabel}/{id}` – un singur rând
- `POST /api/{tabel}` – adăugare
- `PUT /api/{tabel}/{id}` – modificare
- `DELETE /api/{tabel}/{id}` – ștergere

Tabelele sunt: utilizatori, familii, specii, locatii, expeditii, observatii, validari.

## Ce mai este de facut
- autentificare (login cu parola)
- teste cu multe date si verificarea indecsilor
- load test
- rapoarte PDF/CSV
- sa fie aplicatie mobile
