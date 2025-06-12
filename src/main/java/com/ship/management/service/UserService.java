package com.ship.management.service;

import com.ship.management.dto.UserRegistrationDTO;
import com.ship.management.dto.UserDTO;
import com.ship.management.dto.ChangePasswordDTO;
import com.ship.management.dto.AssignRoleDTO;
import com.ship.management.entity.Company;
import com.ship.management.entity.Role;
import com.ship.management.entity.User;
import com.ship.management.repository.CompanyRepository;
import com.ship.management.repository.RoleRepository;
import com.ship.management.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
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
    private final CompanyRepository companyRepository;
    private final ModelMapper modelMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        return userRepository.findByEmail(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));
    }

    public Page<UserDTO> getAllUsers(Pageable pageable) {
        Page<User> users = userRepository.findAll(pageable);
        return users.map(this::convertToDTO);
    }

    public Optional<UserDTO> getUserById(Long id) {
        return userRepository.findById(id)
                .map(this::convertToDTO);
    }

    public Optional<UserDTO> getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .map(this::convertToDTO);
    }

    public UserDTO createUser(UserDTO userDTO) throws Exception {
        // Check if user already exists
        if (userRepository.existsByEmail(userDTO.getEmail())) {
            throw new Exception("Email đã tồn tại");
        }

        // Get role
        Role role = roleRepository.findById(userDTO.getRoleId())
                .orElseThrow(() -> new Exception("Vai trò không tồn tại"));
        
        Company company = companyRepository.findById(userDTO.getCompanyId())
                .orElseThrow(() -> new Exception("Công ty không tồn tại"));

        // Create new user with default password
        User user = User.builder()
                .email(userDTO.getEmail())
                .fullName(userDTO.getFullName())
                .company(company)
                .hashedPassword(passwordEncoder.encode("123456")) // Default password
                .role(role)
                .build();

        User savedUser = userRepository.save(user);
        return convertToDTO(savedUser);
    }

    public Optional<UserDTO> updateUser(Long id, UserDTO userDTO) throws Exception {
        return userRepository.findById(id)
                .map(existingUser -> {
                    // Check if the new email conflicts with another user
                    Optional<User> userWithSameEmail = userRepository.findByEmail(userDTO.getEmail());
                    if (userWithSameEmail.isPresent() && !userWithSameEmail.get().getId().equals(id)) {
                        throw new RuntimeException("Email đã tồn tại");
                    }

                    existingUser.setFullName(userDTO.getFullName());
                    existingUser.setEmail(userDTO.getEmail());
                    Company company = companyRepository.findById(userDTO.getCompanyId()).orElseThrow(() -> new RuntimeException("Công ty không tồn tại"));
                    existingUser.setCompany(company);
                    User updatedUser = userRepository.save(existingUser);
                    return convertToDTO(updatedUser);
                });
    }

    public boolean deleteUser(Long id) {
        if (userRepository.existsById(id)) {
            userRepository.deleteById(id);
            return true;
        }
        return false;
    }

    public boolean changePassword(Long userId, ChangePasswordDTO changePasswordDTO) throws Exception {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new Exception("Người dùng không tồn tại"));

        // Verify current password
        if (!passwordEncoder.matches(changePasswordDTO.getCurrentPassword(), user.getHashedPassword())) {
            throw new Exception("Mật khẩu hiện tại không đúng");
        }

        // Check if new passwords match
        if (!changePasswordDTO.getNewPassword().equals(changePasswordDTO.getConfirmNewPassword())) {
            throw new Exception("Mật khẩu xác nhận không khớp");
        }

        // Update password
        user.setHashedPassword(passwordEncoder.encode(changePasswordDTO.getNewPassword()));
        userRepository.save(user);
        
        return true;
    }

    public boolean assignRole(Long userId, AssignRoleDTO assignRoleDTO) throws Exception {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new Exception("Người dùng không tồn tại"));

        Role role = roleRepository.findById(assignRoleDTO.getRoleId())
                .orElseThrow(() -> new Exception("Vai trò không tồn tại"));

        user.setRole(role);
        userRepository.save(user);
        
        return true;
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

    private UserDTO convertToDTO(User user) {
        UserDTO userDTO = modelMapper.map(user, UserDTO.class);
        if (user.getRole() != null) {
            userDTO.setRoleId(user.getRole().getId());
            userDTO.setRoleName(user.getRole().getName());
        }
        return userDTO;
    }
} 