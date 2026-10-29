-- FIXTURES (idempotente: ON CONFLICT DO NOTHING)
INSERT INTO utilizatori (id, username, email, parola_hash, rol) VALUES
 (1,'admin','admin@winglog.ro','$2a$10$PLACEHOLDER_HASH','admin'),
 (2,'dr_ornito','validator@winglog.ro','$2a$10$PLACEHOLDER_HASH','validator'),
 (3,'ana','ana@winglog.ro','$2a$10$PLACEHOLDER_HASH','observator'),
 (4,'mihai','mihai@winglog.ro','$2a$10$PLACEHOLDER_HASH','observator')
ON CONFLICT DO NOTHING;

INSERT INTO familii (id, nume, ordin) VALUES
 (1,'Corvidae','Passeriformes'),
 (2,'Ciconiidae','Ciconiiformes'),
 (3,'Pelecanidae','Pelecaniformes'),
 (4,'Otididae','Otidiformes'),
 (5,'Anatidae','Anseriformes'),
 (6,'Ardeidae','Pelecaniformes')
ON CONFLICT DO NOTHING;

INSERT INTO specii (id, nume_comun, nume_stiintific, familie_id, status_conservare) VALUES
 (1,'Cioară grivă','Corvus cornix',1,'LC'),
 (2,'Barză albă','Ciconia ciconia',2,'LC'),
 (3,'Pelican creț','Pelecanus crispus',3,'NT'),
 (4,'Pelican comun','Pelecanus onocrotalus',3,'LC'),
 (5,'Dropie','Otis tarda',4,'VU'),
 (6,'Lebădă de iarnă','Cygnus cygnus',5,'LC'),
 (7,'Egretă mare','Ardea alba',6,'LC'),
 (8,'Stârc cenușiu','Ardea cinerea',6,'LC')
ON CONFLICT DO NOTHING;

INSERT INTO locatii (id, nume, judet, habitat, latitudine, longitudine) VALUES
 (1,'Pădurea Letea (Delta Dunării)','Tulcea','deltă',45.30000,29.55000),
 (2,'Lacul Techirghiol','Constanța','lac sărat',44.05000,28.60000),
 (3,'Parcul Natural Văcărești','București','zonă umedă',44.40000,26.13000),
 (4,'Lacul Brateș','Galați','lac',45.47000,28.00000),
 (5,'Câmpia Tisei','Satu Mare','câmpie',47.90000,22.90000)
ON CONFLICT DO NOTHING;

INSERT INTO expeditii (id, titlu, data, locatie_id, organizator_id) VALUES
 (1,'Ieșire de toamnă în Deltă','2026-10-03',1,3),
 (2,'Numărătoarea păsărilor de apă','2026-10-17',4,4)
ON CONFLICT DO NOTHING;

INSERT INTO expeditie_participanti (expeditie_id, utilizator_id) VALUES
 (1,3),(1,4),(2,4),(2,3)
ON CONFLICT DO NOTHING;

INSERT INTO observatii (id, utilizator_id, specie_id, locatie_id, expeditie_id, data_observatie, nr_exemplare, comportament, status) VALUES
 (1,3,3,1,1,'2026-10-03 08:15',12,'hrănire în apă mică','validata'),
 (2,3,7,1,1,'2026-10-03 09:40',5,'zbor','validata'),
 (3,4,2,4,2,'2026-10-17 10:05',3,'în cuib','validata'),
 (4,4,6,4,2,'2026-10-17 11:30',9,'odihnă pe apă','in_asteptare'),
 (5,3,5,5,NULL,'2026-10-20 07:50',2,'deplasare pe câmp','in_asteptare'),
 (6,4,1,3,NULL,'2026-10-21 16:20',14,'căutare hrană','validata'),
 (7,3,4,2,NULL,'2026-10-22 12:00',30,'stol în zbor','in_asteptare'),
 (8,4,8,4,2,'2026-10-17 10:45',1,'la pândă','respinsa')
ON CONFLICT DO NOTHING;

INSERT INTO validari (id, observatie_id, validator_id, decizie, comentariu) VALUES
 (1,1,2,'validata','Identificare corectă, poză clară'),
 (2,2,2,'validata',NULL),
 (3,8,2,'respinsa','Poza nu permite identificarea')
ON CONFLICT DO NOTHING;

-- resetăm secvențele după inserările cu id explicit
SELECT setval(pg_get_serial_sequence('utilizatori','id'),(SELECT MAX(id) FROM utilizatori));
SELECT setval(pg_get_serial_sequence('familii','id'),(SELECT MAX(id) FROM familii));
SELECT setval(pg_get_serial_sequence('specii','id'),(SELECT MAX(id) FROM specii));
SELECT setval(pg_get_serial_sequence('locatii','id'),(SELECT MAX(id) FROM locatii));
SELECT setval(pg_get_serial_sequence('expeditii','id'),(SELECT MAX(id) FROM expeditii));
SELECT setval(pg_get_serial_sequence('observatii','id'),(SELECT MAX(id) FROM observatii));
SELECT setval(pg_get_serial_sequence('validari','id'),(SELECT MAX(id) FROM validari));
