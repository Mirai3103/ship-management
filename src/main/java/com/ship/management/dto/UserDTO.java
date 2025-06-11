package com.ship.management.dto;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;

@Data
public class UserDTO {
    private Long id;
    
    @NotBlank(message = "Họ và tên là bắt buộc")
    @Size(min = 1, max = 100, message = "Họ và tên phải từ 1 đến 100 ký tự")
    private String fullName;
    
    @NotBlank(message = "Email là bắt buộc")
    @Email(message = "Email không hợp lệ")
    @Size(max = 100, message = "Email không được quá 100 ký tự")
    private String email;
    
    private Long roleId;
    private String roleName;
} 