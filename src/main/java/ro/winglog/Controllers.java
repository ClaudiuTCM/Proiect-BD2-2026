package ro.winglog;

import org.springframework.http.HttpStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

@RestController @RequestMapping("/api/utilizatori")
class UtilizatoriController extends CrudBase {
    protected String table() { return "utilizatori"; }
    protected List<String> cols() { return List.of("username", "email", "parola_hash", "rol"); }
}

@RestController @RequestMapping("/api/familii")
class FamiliiController extends CrudBase {
    protected String table() { return "familii"; }
    protected List<String> cols() { return List.of("nume", "ordin"); }
}

@RestController @RequestMapping("/api/specii")
class SpeciiController extends CrudBase {
    protected String table() { return "specii"; }
    protected List<String> cols() { return List.of("nume_comun", "nume_stiintific", "familie_id", "status_conservare"); }
}

@RestController @RequestMapping("/api/locatii")
class LocatiiController extends CrudBase {
    protected String table() { return "locatii"; }
    protected List<String> cols() { return List.of("nume", "judet", "habitat", "latitudine", "longitudine"); }
}

@RestController @RequestMapping("/api/expeditii")
class ExpeditiiController extends CrudBase {
    protected String table() { return "expeditii"; }
    protected List<String> cols() { return List.of("titlu", "data", "locatie_id", "organizator_id"); }
}

@RestController @RequestMapping("/api/validari")
class ValidariController extends CrudBase {
    protected String table() { return "validari"; }
    protected List<String> cols() { return List.of("observatie_id", "validator_id", "decizie", "comentariu"); }
}

@RestController @RequestMapping("/api/observatii")
class ObservatiiController extends CrudBase {
    protected String table() { return "observatii"; }
    protected List<String> cols() {
        return List.of("utilizator_id", "specie_id", "locatie_id", "expeditie_id",
                       "data_observatie", "nr_exemplare", "comportament", "status");
    }

    /** Listă cu JOIN-uri, filtrabilă după status (folosește indecșii din schema.sql). */
    @GetMapping("/detalii")
    public List<Map<String, Object>> detalii(@RequestParam(required = false) String status) {
        String sql = """
            SELECT o.id, o.data_observatie, o.nr_exemplare, o.comportament, o.status,
                   s.nume_comun, s.nume_stiintific, l.nume AS locatie, u.username
            FROM observatii o
            JOIN specii s ON s.id = o.specie_id
            JOIN locatii l ON l.id = o.locatie_id
            JOIN utilizatori u ON u.id = o.utilizator_id
            """ + (status != null ? " WHERE o.status = ?" : "")
            + " ORDER BY o.data_observatie DESC LIMIT 100";
        return status != null ? db.queryForList(sql, status) : db.queryForList(sql);
    }

    /** Validare: doar rolurile validator/admin; inserare + schimbare status într-o singură tranzacție. */
    @PostMapping("/{id}/valideaza") @Transactional
    public Map<String, Object> valideaza(@PathVariable int id, @RequestBody Map<String, Object> b) {
        int validatorId = ((Number) b.get("validator_id")).intValue();
        String decizie = (String) b.get("decizie");
        String rol = db.queryForObject("SELECT rol FROM utilizatori WHERE id = ?", String.class, validatorId);
        if (!"validator".equals(rol) && !"admin".equals(rol))
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Doar validatorii pot valida observații");
        db.update("INSERT INTO validari (observatie_id, validator_id, decizie, comentariu) VALUES (?,?,?,?)",
                  id, validatorId, decizie, b.get("comentariu"));
        db.update("UPDATE observatii SET status = ? WHERE id = ?", decizie, id);
        return get(id);
    }
}

@RestController @RequestMapping("/api/statistici")
class StatisticiController extends CrudBase {
    protected String table() { return "observatii"; }
    protected List<String> cols() { return List.of(); }

    /** Top specii cu funcție window (RANK). */
    @GetMapping("/top-specii")
    public List<Map<String, Object>> topSpecii() {
        return db.queryForList("""
            SELECT s.nume_comun, COUNT(*) AS observatii, SUM(o.nr_exemplare) AS exemplare,
                   RANK() OVER (ORDER BY COUNT(*) DESC) AS pozitie
            FROM observatii o JOIN specii s ON s.id = o.specie_id
            WHERE o.status = 'validata'
            GROUP BY s.id, s.nume_comun
            ORDER BY pozitie, s.nume_comun
            """);
    }
}
