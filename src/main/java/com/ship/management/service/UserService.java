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
import com.ship.management.repository.ShipRepository;
import com.ship.management.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService implements UserDetailsService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final CompanyRepository companyRepository;
    private final ShipRepository shipRepository;
    private final ModelMapper modelMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        return userRepository.findByEmail(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));
    }

    public Page<UserDTO> getAllUsers(Pageable pageable, String search) {
        Page<User> users = userRepository.findAllBySearch(search, pageable);
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

        if (userRepository.existsByEmail(userDTO.getEmail())) {
            throw new Exception("Email đã tồn tại");
        }


        Role role = roleRepository.findById(userDTO.getRoleId())
                .orElseThrow(() -> new Exception("Vai trò không tồn tại"));
        
        Company company = companyRepository.findById(userDTO.getCompanyId())
                .orElseThrow(() -> new Exception("Công ty không tồn tại"));


        User user = User.builder()
                .email(userDTO.getEmail())
                .fullName(userDTO.getFullName())
                .company(company)
                .hashedPassword(passwordEncoder.encode("123456")) // Default password
                .role(role)
                .build();

        User savedUser = userRepository.save(user);
        this.updateUserOrderNo(savedUser.getId(), 999);
        return convertToDTO(savedUser);
    }

    public Optional<UserDTO> updateUser(Long id, UserDTO userDTO) throws Exception {
        return userRepository.findById(id)
                .map(existingUser -> {

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


        if (!passwordEncoder.matches(changePasswordDTO.getCurrentPassword(), user.getHashedPassword())) {
            throw new Exception("Mật khẩu hiện tại không đúng");
        }


        if (!changePasswordDTO.getNewPassword().equals(changePasswordDTO.getConfirmNewPassword())) {
            throw new Exception("Mật khẩu xác nhận không khớp");
        }


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

        if (userRepository.existsByEmail(registrationDTO.getEmail())) {
            throw new Exception("Email đã tồn tại");
        }


        if (!registrationDTO.getPassword().equals(registrationDTO.getConfirmPassword())) {
            throw new Exception("Mật khẩu xác nhận không khớp");
        }


        Role userRole = roleRepository.findByName("USER")
                .orElseThrow(() -> new Exception("Default role not found"));

       


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

    public List<UserDTO> getUsersByCompanyId(Long companyId) {
        return userRepository.findByCompanyId(companyId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<UserDTO> getUsersByShipId(Long shipId) {
        return shipRepository.findUsersByShipId(shipId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public User getCurrentUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return null;
        }
    
        Object principal = authentication.getPrincipal();
        if (principal instanceof UserDetails) {
            return ((User) principal);
        } else {
            return null;
        }
    }
    public Role.RootRole getCurrentUserRootRole() {
        var currentUser = getCurrentUser();
        if(currentUser == null) {
            return null;
        }
        return currentUser.getRole().getRootRole();
    }

    @Transactional
    public void updateUserOrderNo(Long id, Integer orderNo) {
        // Lấy toàn bộ users theo thứ tự
        var allUsers = userRepository.findAllByOrderByOrderNoAsc();
        allUsers.stream().forEach(user -> user.setOrderNo(Objects.isNull(user.getOrderNo()) ? 0 : user.getOrderNo()));
        
        // Tìm user cần thay đổi
        var user = allUsers.stream()
                .filter(item -> item.getId().equals(id))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("User not found"));
    
        int currentOrder = Objects.isNull(user.getOrderNo()) ? 0 : user.getOrderNo();
        int newOrder = orderNo;
    
        // Giới hạn newOrder hợp lý
        if (newOrder < 1) newOrder = 1;
        if (newOrder > allUsers.size()) newOrder = allUsers.size();
    
        if (newOrder == currentOrder) return; // Không cần xử lý nếu không thay đổi
    
        for (var item : allUsers) {
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
    
        // Cập nhật order cho user cần di chuyển
        user.setOrderNo(newOrder);
    
        // Lưu toàn bộ danh sách (có thể tối ưu chỉ lưu những item thực sự thay đổi)
        // then re generate orderNo for all items start from 1
        Collections.sort(allUsers, Comparator.comparingInt(User::getOrderNo));
        for(int i = 0; i < allUsers.size(); i++){
            allUsers.get(i).setOrderNo(i+1);
        }
        userRepository.saveAll(allUsers);
    }
} 