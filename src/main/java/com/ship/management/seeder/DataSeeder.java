package com.ship.management.seeder;

import java.util.List;

import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.ship.management.entity.Role;
import com.ship.management.entity.User;
import com.ship.management.repository.RoleRepository;
import com.ship.management.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class DataSeeder {
    private final RoleRepository roleRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @EventListener(ApplicationReadyEvent.class)
    public void seedData() {
        if (roleRepository.count() == 0) {
            // (admin, CAP, C/E, TEC, COM)
            Role admin = Role.builder()
                .name("ADMIN")
                .description("Administrator")
                .rootRole(Role.RootRole.ADMIN)
                .build();  
            Role cap = Role.builder()
                .name("CAP")
                .description("Captain")
                .rootRole(Role.RootRole.SHIP)
                .build();
            Role ce = Role.builder()
                .name("C/E")
                .description("Chief Engineer")
                .rootRole(Role.RootRole.SHIP)
                .build();
            Role tec = Role.builder()
                .name("TEC")
                .description("Technical")
                .rootRole(Role.RootRole.COMPANY)
                .build();
            Role com = Role.builder()
                .name("COM")
                .description("Communication")
                .rootRole(Role.RootRole.SHIP)
                .build();
     
            roleRepository.saveAll(List.of(admin, cap, ce, tec, com));
        }
        if (userRepository.count() == 0) {
            User admin = User.builder()
                .email("admin@gmail.com")
                .fullName("Admin")
                .hashedPassword(passwordEncoder.encode("admin"))
                .role(roleRepository.findByName("ADMIN").orElseThrow())
                .build();
            userRepository.save(admin); 
        }
    }
}
