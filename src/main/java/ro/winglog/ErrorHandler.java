package ro.winglog;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;

@RestControllerAdvice
class ErrorHandler {
    @ExceptionHandler(DataIntegrityViolationException.class)
    ResponseEntity<Map<String, String>> integrity(DataIntegrityViolationException e) {
        // constrângeri CHECK / FK / UNIQUE încălcate
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(Map.of("error", "Constrângere încălcată: " + e.getMostSpecificCause().getMessage()));
    }
    @ExceptionHandler(EmptyResultDataAccessException.class)
    ResponseEntity<Map<String, String>> empty(EmptyResultDataAccessException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "Nu există"));
    }
    @ExceptionHandler(ResponseStatusException.class)
    ResponseEntity<Map<String, String>> status(ResponseStatusException e) {
        return ResponseEntity.status(e.getStatusCode()).body(Map.of("error", String.valueOf(e.getReason())));
    }
}
