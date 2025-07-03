package com.ship.management.api;

import com.ship.management.dto.UserDTO;
import com.ship.management.dto.ChangePasswordDTO;
import com.ship.management.dto.AssignRoleDTO;
import com.ship.management.service.UserService;
import com.ship.management.service.RoleService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final RoleService roleService;

    @GetMapping
    public ResponseEntity<Page<UserDTO>> getAllUsers(
            @PageableDefault(size = 10, sort = "id") Pageable pageable,
            @RequestParam(required = false, defaultValue = "") String search) {
        Page<UserDTO> users = userService.getAllUsers(pageable, search);
        return ResponseEntity.ok(users);
    }

    @GetMapping("/company/{companyId}")
    public ResponseEntity<List<UserDTO>> getUsersByCompanyId(@PathVariable Long companyId) {
        List<UserDTO> users = userService.getUsersByCompanyId(companyId);
        return ResponseEntity.ok(users);
    }

    @GetMapping("/ship/{shipId}")
    public ResponseEntity<List<UserDTO>> getUsersByShipId(@PathVariable Long shipId) {
        List<UserDTO> users = userService.getUsersByShipId(shipId);
        return ResponseEntity.ok(users);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> getUserById(@PathVariable Long id) {
        return userService.getUserById(id)
                .map(user -> ResponseEntity.ok(user))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/email/{email}")
    public ResponseEntity<UserDTO> getUserByEmail(@PathVariable String email) {
        return userService.getUserByEmail(email)
                .map(user -> ResponseEntity.ok(user))
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<?> createUser(@Valid @RequestBody UserDTO userDTO) {
        try {
            UserDTO createdUser = userService.createUser(userDTO);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Tạo người dùng thành công. Mật khẩu mặc định: 123456");
            response.put("user", createdUser);
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("error", e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Long id, 
                                       @Valid @RequestBody UserDTO userDTO) {
        try {
            return userService.updateUser(id, userDTO)
                    .map(user -> ResponseEntity.ok(user))
                    .orElse(ResponseEntity.notFound().build());
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("error", "Lỗi hệ thống"));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        if (userService.deleteUser(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping("/{id}/change-password")
    public ResponseEntity<?> changePassword(@PathVariable Long id, 
                                           @Valid @RequestBody ChangePasswordDTO changePasswordDTO) {
        try {
            boolean success = userService.changePassword(id, changePasswordDTO);
            if (success) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("message", "Đổi mật khẩu thành công");
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(new ErrorResponse("error", "Không thể đổi mật khẩu"));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("error", e.getMessage()));
        }
    }

    @PostMapping("/{id}/assign-role")
    public ResponseEntity<?> assignRole(@PathVariable Long id, 
                                       @Valid @RequestBody AssignRoleDTO assignRoleDTO) {
        try {
            boolean success = userService.assignRole(id, assignRoleDTO);
            if (success) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("message", "Gán vai trò thành công");
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(new ErrorResponse("error", "Không thể gán vai trò"));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("error", e.getMessage()));
        }
    }

    @GetMapping("/roles")
    public ResponseEntity<?> getAllRoles() {
        try {

            var roles = roleService.getAllRoles(Pageable.unpaged());
            return ResponseEntity.ok(roles.getContent());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("error", "Không thể tải danh sách vai trò"));
        }
    }

    @PatchMapping("/{id}/order-no")
    public ResponseEntity<Void> updateUserOrderNo(@PathVariable Long id, @RequestBody Map<String, Integer> requestBody) {
        userService.updateUserOrderNo(id, requestBody.get("orderNo"));
        return ResponseEntity.noContent().build();
    }


    public static class ErrorResponse {
        public String status;
        public String message;

        public ErrorResponse(String status, String message) {
            this.status = status;
            this.message = message;
        }
    }
} 