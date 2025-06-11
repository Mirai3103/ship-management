package com.ship.management.dto;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;

@Data
public class LoginRequestDTO {
    
    @NotBlank(message = "Email là bắt buộc")
    private String email;
    
    @NotBlank(message = "Mật khẩu là bắt buộc")
    private String password;
    
    private boolean remember = false;
} 