package ro.winglog;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

/** CRUD generic peste o tabelă; coloanele permise sunt whitelisted (fără SQL injection). */
public abstract class CrudBase {
    @Autowired protected JdbcTemplate db;

    protected abstract String table();
    protected abstract List<String> cols();

    @GetMapping
    public List<Map<String, Object>> list() {
        return db.queryForList("SELECT * FROM " + table() + " ORDER BY id");
    }

    @GetMapping("/{id}")
    public Map<String, Object> get(@PathVariable int id) {
        var r = db.queryForList("SELECT * FROM " + table() + " WHERE id = ?", id);
        if (r.isEmpty()) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Nu există");
        return r.get(0);
    }

    @PostMapping @ResponseStatus(HttpStatus.CREATED)
    public Map<String, Object> create(@RequestBody Map<String, Object> body) {
        var c = cols().stream().filter(body::containsKey).toList();
        String sql = "INSERT INTO " + table() + " (" + String.join(",", c) + ") VALUES ("
                + String.join(",", Collections.nCopies(c.size(), "?")) + ") RETURNING *";
        return db.queryForMap(sql, c.stream().map(body::get).toArray());
    }

    @PutMapping("/{id}")
    public Map<String, Object> update(@PathVariable int id, @RequestBody Map<String, Object> body) {
        var c = cols().stream().filter(body::containsKey).toList();
        if (c.isEmpty()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Nimic de actualizat");
        String set = String.join(",", c.stream().map(x -> x + "=?").toList());
        List<Object> args = new ArrayList<>(c.stream().map(body::get).toList());
        args.add(id);
        var r = db.queryForList("UPDATE " + table() + " SET " + set + " WHERE id=? RETURNING *", args.toArray());
        if (r.isEmpty()) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Nu există");
        return r.get(0);
    }

    @DeleteMapping("/{id}") @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable int id) {
        if (db.update("DELETE FROM " + table() + " WHERE id = ?", id) == 0)
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Nu există");
    }
}
