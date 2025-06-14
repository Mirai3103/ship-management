package com.ship.management.service;

import com.ship.management.dto.RoleDTO;
import com.ship.management.entity.Role;
import com.ship.management.repository.RoleRepository;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class RoleService {

    private final RoleRepository roleRepository;
    private final ModelMapper modelMapper;
    public Page<RoleDTO> getAllRoles(Pageable pageable) {
        Page<Role> roles = roleRepository.findAll(pageable);
        return roles.map(this::convertToDTO);
    }

    public Optional<RoleDTO> getRoleById(Long id) {
        return roleRepository.findById(id)
                .map(this::convertToDTO);
    }

    public Optional<RoleDTO> getRoleByName(String name) {
        return roleRepository.findByName(name)
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
        return modelMapper.map(role, RoleDTO.class);
    }

    private Role convertToEntity(RoleDTO roleDTO) {
        return modelMapper.map(roleDTO, Role.class);
    }
} 