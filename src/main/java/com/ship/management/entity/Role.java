package com.ship.management.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "roles")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Role {
    public enum RootRole {
        ADMIN,
        SHIP,
        COMPANY,
    }
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "order_no", nullable = true)
    @Builder.Default
    private Integer orderNo = 0;
    
    private String name;
    private String description;
    private RootRole rootRole;
    @OneToMany(mappedBy = "role")
    private List<User> users;
    @OneToMany(mappedBy = "role",fetch = FetchType.EAGER)
    @Builder.Default
    private List<RolePermission> rolePermissions=new ArrayList<>();
}
