package com.ship.management.service;

import com.ship.management.dto.UserRegistrationDTO;
import com.ship.management.entity.Role;
import com.ship.management.entity.User;
import com.ship.management.repository.RoleRepository;
import com.ship.management.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserService implements UserDetailsService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        return userRepository.findByEmail(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));
    }

    public User registerUser(UserRegistrationDTO registrationDTO) throws Exception {
        // Check if user already exists
        if (userRepository.existsByEmail(registrationDTO.getEmail())) {
            throw new Exception("Email đã tồn tại");
        }

        // Check if passwords match
        if (!registrationDTO.getPassword().equals(registrationDTO.getConfirmPassword())) {
            throw new Exception("Mật khẩu xác nhận không khớp");
        }

        // Get default role (USER)
        Role userRole = roleRepository.findByName("USER")
                .orElseThrow(() -> new Exception("Default role not found"));

        // Generate new user ID

        // Create new user
        User user = User.builder()
                .email(registrationDTO.getEmail())
                .fullName(registrationDTO.getFullName())
                .hashedPassword(passwordEncoder.encode(registrationDTO.getPassword()))
                .role(userRole)
                .build();

        return userRepository.save(user);
    }

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public boolean validatePassword(String rawPassword, String encodedPassword) {
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }

   
} 