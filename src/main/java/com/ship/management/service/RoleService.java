package com.ship.management.service;

import com.ship.management.dto.EditRolePermissionDTO;
import com.ship.management.dto.RoleDTO;
import com.ship.management.entity.Role;
import com.ship.management.entity.RolePermission;
import com.ship.management.repository.RolePermissionRepository;
import com.ship.management.repository.RoleRepository;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.val;

import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class RoleService {

    private final RoleRepository roleRepository;
    private final ModelMapper modelMapper;
    private final RolePermissionRepository rolePermissionRepository;
    public Page<RoleDTO> getAllRoles(Pageable pageable) {
        Page<Role> roles = roleRepository.findAll(pageable);
        return roles.map(this::convertToDTO);
    }

    public Optional<RoleDTO> getRoleById(Long id) {
        var role = roleRepository.findById(id);
        role.ifPresent(r->r.getRolePermissions().size()); // force load role permissions
        return role.map(this::convertToDTO);
    }

    public Optional<RoleDTO> getRoleByName(String name) {
        var role = roleRepository.findByName(name);
        role.ifPresent(r->r.getRolePermissions().size()); // force load role permissions
        return  role
                .map(this::convertToDTO);
    }

    public RoleDTO createRole(RoleDTO roleDTO) {
        // Check if role name already exists
        if (roleRepository.findByName(roleDTO.getName()).isPresent()) {
            throw new RuntimeException("Tên vai trò đã tồn tại");
        }
        
        Role role = convertToEntity(roleDTO);
        role.setId(null); // Ensure it's a new entity
        Role savedRole = roleRepository.save(role);

        return convertToDTO(savedRole);
    }

    public Optional<RoleDTO> updateRole(Long id, RoleDTO roleDTO) {
        return roleRepository.findById(id)
                .map(existingRole -> {
                    // Check if the new name conflicts with another role
                    Optional<Role> roleWithSameName = roleRepository.findByName(roleDTO.getName());
                    if (roleWithSameName.isPresent() && !roleWithSameName.get().getId().equals(id)) {
                        throw new RuntimeException("Tên vai trò đã tồn tại");
                    }
                    
                    existingRole.setName(roleDTO.getName());
                    existingRole.setDescription(roleDTO.getDescription());
                    existingRole.setRootRole(roleDTO.getRootRole());
            
                    Role updatedRole = roleRepository.save(existingRole);
                    return convertToDTO(updatedRole);
                });
    }
    @org.springframework.transaction.annotation.Transactional
    public Optional<RoleDTO> editRolePermission(Long id, EditRolePermissionDTO editRolePermissionDTO) {
        return roleRepository.findById(id)
                .map(existingRole -> {
                    rolePermissionRepository.deleteByRoleId(existingRole.getId());
                    rolePermissionRepository.saveAll(editRolePermissionDTO.getPermissions().stream().map(p->{
                        RolePermission rolePermission = new RolePermission();
                        rolePermission.setRole(existingRole);
                        rolePermission.setPermission(p);
                        return rolePermission;
                    }).toList());
                    return convertToDTO(existingRole);
                });
    }
    

    public boolean deleteRole(Long id) {
        if (roleRepository.existsById(id)) {
            // Check if role is being used by users
            Optional<Role> role = roleRepository.findById(id);
            if (role.isPresent() && role.get().getUsers() != null && !role.get().getUsers().isEmpty()) {
                throw new RuntimeException("Không thể xóa vai trò đang được sử dụng");
            }
            
            roleRepository.deleteById(id);
            return true;
        }
        return false;
    }

    private RoleDTO convertToDTO(Role role) {
        var dto= modelMapper.map(role, RoleDTO.class);
        dto.setPermissions(new ArrayList<>());
        role.getRolePermissions().forEach(rp->dto.getPermissions().add(rp.getPermission()));
        return dto;
    }

    private Role convertToEntity(RoleDTO roleDTO) {
        return modelMapper.map(roleDTO, Role.class);
    }
} 