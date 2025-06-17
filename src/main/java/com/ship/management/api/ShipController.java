package com.ship.management.api;

import com.ship.management.dto.EditShipUserDTO;
import com.ship.management.dto.ShipDTO;
import com.ship.management.dto.UserDTO;
import com.ship.management.service.ShipService;
import lombok.RequiredArgsConstructor;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.data.web.PagedModel;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/ships")
@RequiredArgsConstructor
public class ShipController {

    private final ShipService shipService;

    @GetMapping
    public ResponseEntity<PagedModel<ShipDTO>> getAllShips(
            @PageableDefault(size = 10, sort = "id") Pageable pageable,
            @RequestParam(required = false, defaultValue = "false") Boolean strict) {
        Page<ShipDTO> ships = strict ? shipService.getAllShipsStrict(pageable) : shipService.getAllShips(pageable);
        return ResponseEntity.ok(new PagedModel<>(ships));
    }
    @GetMapping("company/{companyId}")
    public ResponseEntity<List<ShipDTO>> getShipsByCompanyId(
            @PathVariable Long companyId, @RequestParam(required = false) Boolean strict) {
        List<ShipDTO> ships = strict ? shipService.getShipsByCompanyIdStrict(companyId) : shipService.getShipsByCompanyId(companyId);
        return ResponseEntity.ok(ships);

    }

    @GetMapping("/{id}")
    public ResponseEntity<ShipDTO> getShipById(@PathVariable Long id) {
        return shipService.getShipById(id)
                .map(ship -> ResponseEntity.ok(ship))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/name/{name}")
    public ResponseEntity<ShipDTO> getShipByName(@PathVariable String name) {
        return shipService.getShipByName(name)
                .map(ship -> ResponseEntity.ok(ship))
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<ShipDTO> createShip(@Valid @RequestBody ShipDTO shipDTO) {
        ShipDTO createdShip = shipService.createShip(shipDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdShip);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ShipDTO> updateShip(@PathVariable Long id, 
                                              @Valid @RequestBody ShipDTO shipDTO) {
        return shipService.updateShip(id, shipDTO)
                .map(ship -> ResponseEntity.ok(ship))
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteShip(@PathVariable Long id) {
        if (shipService.deleteShip(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping("/{id}/edit-users")
    public ResponseEntity<Void> editShipUsers(@PathVariable Long id, @Valid @RequestBody EditShipUserDTO editShipUserDTO) {
        shipService.editShipUsers(editShipUserDTO);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{id}/users")
    public ResponseEntity<List<UserDTO>> getUsersByShipId(@PathVariable Long id) {
        List<UserDTO> users = shipService.getUsersByShipId(id);
        return ResponseEntity.ok(users);
    }
}
