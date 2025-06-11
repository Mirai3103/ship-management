package com.ship.management.dto;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.Email;

@Data
public class UserRegistrationDTO {
    
    @NotBlank(message = "Tên là bắt buộc")
    @Size(min = 3, max = 100, message = "Tên phải từ 3 đến 100 ký tự")
    private String fullName;

    @NotBlank(message = "Email là bắt buộc")
    @Email(message = "Email không hợp lệ")
    @Size(max = 100, message = "Email không được quá 100 ký tự")
    private String email;
    
    @NotBlank(message = "Mật khẩu là bắt buộc")
    @Size(min = 6, max = 100, message = "Mật khẩu phải từ 6 đến 100 ký tự")
    private String password;
    
    @NotBlank(message = "Xác nhận mật khẩu là bắt buộc")
    private String confirmPassword;
} 