package com.ship.management.dto;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;

@Data
public class CompanyDTO {
    private Long id;
    
    @NotBlank(message = "Tên công ty là bắt buộc")
    @Size(min = 1, max = 100, message = "Tên công ty phải từ 1 đến 100 ký tự")
    private String name;
    
    @NotBlank(message = "Địa chỉ là bắt buộc")
    @Size(min = 1, max = 255, message = "Địa chỉ phải từ 1 đến 255 ký tự")
    private String address;
    
    @NotBlank(message = "Số điện thoại là bắt buộc")
    @Size(min = 10, max = 15, message = "Số điện thoại phải từ 10 đến 15 ký tự")
    private String phone;
    
    @NotBlank(message = "Email là bắt buộc")
    @Email(message = "Email không hợp lệ")
    @Size(max = 100, message = "Email không được quá 100 ký tự")
    private String email;
} 