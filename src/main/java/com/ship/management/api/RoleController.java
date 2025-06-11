package com.ship.management.api;

import com.ship.management.dto.RoleDTO;
import com.ship.management.service.RoleService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.data.web.PagedModel;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/roles")
@RequiredArgsConstructor
public class RoleController {

    private final RoleService roleService;

    @GetMapping
    public ResponseEntity<PagedModel<RoleDTO>> getAllRoles(
            @PageableDefault(size = 10, sort = "id") Pageable pageable) {
        Page<RoleDTO> roles = roleService.getAllRoles(pageable);
        return ResponseEntity.ok(new PagedModel<>(roles));
    }

    @GetMapping("/{id}")
    public ResponseEntity<RoleDTO> getRoleById(@PathVariable Long id) {
        return roleService.getRoleById(id)
                .map(role -> ResponseEntity.ok(role))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/name/{name}")
    public ResponseEntity<RoleDTO> getRoleByName(@PathVariable String name) {
        return roleService.getRoleByName(name)
                .map(role -> ResponseEntity.ok(role))
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<?> createRole(@Valid @RequestBody RoleDTO roleDTO) {
        try {
            RoleDTO createdRole = roleService.createRole(roleDTO);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdRole);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("error", e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateRole(@PathVariable Long id, 
                                       @Valid @RequestBody RoleDTO roleDTO) {
        try {
            return roleService.updateRole(id, roleDTO)
                    .map(role -> ResponseEntity.ok(role))
                    .orElse(ResponseEntity.notFound().build());
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("error", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteRole(@PathVariable Long id) {
        try {
            if (roleService.deleteRole(id)) {
                return ResponseEntity.noContent().build();
            }
            return ResponseEntity.notFound().build();
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("error", e.getMessage()));
        }
    }

    // Error response class
    public static class ErrorResponse {
        public String status;
        public String message;

        public ErrorResponse(String status, String message) {
            this.status = status;
            this.message = message;
        }
    }
} 