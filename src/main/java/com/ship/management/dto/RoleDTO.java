package com.ship.management.dto;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

import com.ship.management.entity.Role;
import com.ship.management.entity.RolePermission;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

@Data
public class RoleDTO {
    private Long id;
    
    @NotBlank(message = "Tên vai trò là bắt buộc")
    @Size(min = 1, max = 50, message = "Tên vai trò phải từ 1 đến 50 ký tự")
    private String name;

    private Integer orderNo = 99;
    
    @NotBlank(message = "Mô tả là bắt buộc")
    @Size(min = 1, max = 255, message = "Mô tả phải từ 1 đến 255 ký tự")
    private String description;

    @NotNull(message = "Vai trò gốc là bắt buộc")
    private Role.RootRole rootRole;

    private List<RolePermission.Permission> permissions = new ArrayList<>();
} 