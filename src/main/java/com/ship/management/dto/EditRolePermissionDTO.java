package com.ship.management.dto;

import java.util.List;

import com.ship.management.entity.RolePermission;

import lombok.Data;

@Data
public class EditRolePermissionDTO {
    private Long roleId;
    private List<RolePermission.Permission> permissions;
}
