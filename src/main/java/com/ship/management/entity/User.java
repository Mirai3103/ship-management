package com.ship.management.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "order_no", nullable = true)
    @Builder.Default
    private Integer orderNo = 0;
    
    private String fullName;
    private String email;
    private String hashedPassword;
    @ManyToOne
    @JoinColumn(name = "role_id", referencedColumnName = "id")
    private Role role;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "company_id", referencedColumnName = "id",nullable = true)
    private Company company;





    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        var permissions = new ArrayList<>(role.getRolePermissions().stream().map((p)->new SimpleGrantedAuthority(p.getPermission().name())).toList());
        permissions.add(new SimpleGrantedAuthority("ROLE_"+role.getName()));
        permissions.add(new SimpleGrantedAuthority("ROLE_"+role.getRootRole().name()));
        return permissions;
    }

    public List<String> getListAuthorities(){
        var permissions = new ArrayList<>(role.getRolePermissions().stream().map((p)-> p.getPermission().name()).toList());
        permissions.add("ROLE_"+role.getName());
        permissions.add("ROLE_"+role.getRootRole().name());
        return permissions;
    }

    @Override
    public String getPassword() {
        return hashedPassword;
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
}
