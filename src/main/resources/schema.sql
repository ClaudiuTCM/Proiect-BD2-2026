CREATE TABLE IF NOT EXISTS utilizatori (
  id          SERIAL PRIMARY KEY,
  username    VARCHAR(50)  NOT NULL UNIQUE,
  email       VARCHAR(100) NOT NULL UNIQUE,
  parola_hash VARCHAR(100) NOT NULL,
  rol         VARCHAR(20)  NOT NULL CHECK (rol IN ('observator','validator','admin')),
  creat_la    TIMESTAMP    NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS familii (
  id    SERIAL PRIMARY KEY,
  nume  VARCHAR(60) NOT NULL UNIQUE,
  ordin VARCHAR(60) NOT NULL
);

CREATE TABLE IF NOT EXISTS specii (
  id                 SERIAL PRIMARY KEY,
  nume_comun         VARCHAR(80)  NOT NULL,
  nume_stiintific    VARCHAR(100) NOT NULL UNIQUE,
  familie_id         INT NOT NULL REFERENCES familii(id),
  status_conservare  CHAR(2) NOT NULL DEFAULT 'LC' CHECK (status_conservare IN ('LC','NT','VU','EN','CR'))
);

CREATE TABLE IF NOT EXISTS locatii (
  id         SERIAL PRIMARY KEY,
  nume       VARCHAR(100) NOT NULL,
  judet      VARCHAR(40)  NOT NULL,
  habitat    VARCHAR(40)  NOT NULL,
  latitudine  NUMERIC(8,5) NOT NULL CHECK (latitudine  BETWEEN -90  AND 90),
  longitudine NUMERIC(8,5) NOT NULL CHECK (longitudine BETWEEN -180 AND 180)
);

CREATE TABLE IF NOT EXISTS expeditii (
  id            SERIAL PRIMARY KEY,
  titlu         VARCHAR(120) NOT NULL,
  data          DATE NOT NULL,
  locatie_id    INT NOT NULL REFERENCES locatii(id),
  organizator_id INT NOT NULL REFERENCES utilizatori(id)
);

-- many-to-many: expediții <-> utilizatori
CREATE TABLE IF NOT EXISTS expeditie_participanti (
  expeditie_id INT NOT NULL REFERENCES expeditii(id) ON DELETE CASCADE,
  utilizator_id INT NOT NULL REFERENCES utilizatori(id) ON DELETE CASCADE,
  PRIMARY KEY (expeditie_id, utilizator_id)
);

CREATE TABLE IF NOT EXISTS observatii (
  id              SERIAL PRIMARY KEY,
  utilizator_id   INT NOT NULL REFERENCES utilizatori(id),
  specie_id       INT NOT NULL REFERENCES specii(id),
  locatie_id      INT NOT NULL REFERENCES locatii(id),
  expeditie_id    INT REFERENCES expeditii(id) ON DELETE SET NULL,
  data_observatie TIMESTAMP NOT NULL,
  nr_exemplare    INT NOT NULL CHECK (nr_exemplare > 0),
  comportament    VARCHAR(200),
  status          VARCHAR(20) NOT NULL DEFAULT 'in_asteptare'
                  CHECK (status IN ('in_asteptare','validata','respinsa'))
);

CREATE TABLE IF NOT EXISTS validari (
  id            SERIAL PRIMARY KEY,
  observatie_id INT NOT NULL REFERENCES observatii(id) ON DELETE CASCADE,
  validator_id  INT NOT NULL REFERENCES utilizatori(id),
  decizie       VARCHAR(20) NOT NULL CHECK (decizie IN ('validata','respinsa')),
  comentariu    VARCHAR(300),
  data          TIMESTAMP NOT NULL DEFAULT now(),
  UNIQUE (observatie_id, validator_id)
);

-- Indecși (de justificat cu EXPLAIN ANALYZE înainte/după)
CREATE INDEX IF NOT EXISTS idx_obs_specie_data ON observatii (specie_id, data_observatie);
CREATE INDEX IF NOT EXISTS idx_obs_locatie     ON observatii (locatie_id);
CREATE INDEX IF NOT EXISTS idx_obs_asteptare   ON observatii (data_observatie) WHERE status = 'in_asteptare';
