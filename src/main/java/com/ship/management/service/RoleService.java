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
import java.util.Collections;
import java.util.Comparator;
import java.util.Objects;
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

        if (roleRepository.findByName(roleDTO.getName()).isPresent()) {
            throw new RuntimeException("Tên vai trò đã tồn tại");
        }
        
        Role role = convertToEntity(roleDTO);
        role.setId(null); // Ensure it's a new entity
        Role savedRole = roleRepository.save(role);
        this.updateRoleOrderNo(savedRole.getId(), 999);
        return convertToDTO(savedRole);
    }

    public Optional<RoleDTO> updateRole(Long id, RoleDTO roleDTO) {
        return roleRepository.findById(id)
                .map(existingRole -> {

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
    

    @Transactional
    public boolean deleteRole(Long id) {
        roleRepository.deleteById(id);
        return true;
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

    @Transactional
    public void updateRoleOrderNo(Long id, Integer orderNo) {
        // Lấy toàn bộ roles theo thứ tự
        var allRoles = roleRepository.findAllByOrderByOrderNoAsc();
        allRoles.stream().forEach(role -> role.setOrderNo(Objects.isNull(role.getOrderNo()) ? 0 : role.getOrderNo()));
        
        // Tìm role cần thay đổi
        var role = allRoles.stream()
                .filter(item -> item.getId().equals(id))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Role not found"));
    
        int currentOrder = Objects.isNull(role.getOrderNo()) ? 0 : role.getOrderNo();
        int newOrder = orderNo;
    
        // Giới hạn newOrder hợp lý
        if (newOrder < 1) newOrder = 1;
        if (newOrder > allRoles.size()) newOrder = allRoles.size();
    
        if (newOrder == currentOrder) return; // Không cần xử lý nếu không thay đổi
    
        for (var item : allRoles) {
            // Di chuyển lên trên danh sách
            if (newOrder < currentOrder) {
                if (item.getOrderNo() >= newOrder && item.getOrderNo() < currentOrder) {
                    item.setOrderNo(item.getOrderNo() + 1);
                }
            }
            // Di chuyển xuống dưới danh sách
            else {
                if (item.getOrderNo() <= newOrder && item.getOrderNo() > currentOrder) {
                    item.setOrderNo(item.getOrderNo() - 1);
                }
            }
        }
    
        // Cập nhật order cho role cần di chuyển
        role.setOrderNo(newOrder);
    
        // Lưu toàn bộ danh sách (có thể tối ưu chỉ lưu những item thực sự thay đổi)
        // then re generate orderNo for all items start from 1
        Collections.sort(allRoles, Comparator.comparingInt(Role::getOrderNo));
        for(int i = 0; i < allRoles.size(); i++){
            allRoles.get(i).setOrderNo(i+1);
        }
        roleRepository.saveAll(allRoles);
    }
} 